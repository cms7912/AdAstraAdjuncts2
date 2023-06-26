//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
// import SwiftUI
// import UIKit
import CoreData
import AdAstraDBStackCore
// import SFSafeSymbols
// import AdAstraExtensions
//import AdAstraBridgingByShim


// Importing & Exporting are asynchronous operations. This is because .loadPersistentStores is async, so all transfer operations have to run after that returns, so Import & Export calls will return before operations complete.
// - per-root-object transfer does call a completion handler for every object attempted. This will happen before the synchronous call returns
// if multiple root objects attempt transfer, the ConductTransfer will never throw an error but individual root object completion handlers can return with errors. If single root object attempt to transfer, then ConductTransfer can through an error if encountered

extension ProjectsDBStack {
	
	private static func ConductTransferOfSingle(rootObject rootObjectID: NSManagedObjectID,
																							from sourceStack: ProjectsDBStack,
																							to destinationStack: ProjectsDBStack,
                                              savingPlan: TransferSaving,
																							perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler
	) throws {
		
		// New background contexts
		let sourceContext = sourceStack.newBackgroundContext(
			named: "ProjectsDBStack_ConductTransferSourceContext",
			automaticallyMergesChangesFromParent: false)
		let destinationContext = destinationStack.newBackgroundContext(
			named: "ProjectsDBStack_ConductTransferDestinationContext",
			automaticallyMergesChangesFromParent: false)
		defer {
			// clear out contexts to save memory
			sourceContext.saveAndRefresh()
			destinationContext.saveAndRefresh()
		}
		// Attempt the transfer
    try sourceContext.performWhileWaiting("ConductTransferOf1-\(sourceStack.projectDBFolder.lastPathComponent)"){ sourceContext in
			
			// Get root object
			let sourceObject = sourceContext.object(with: rootObjectID)
			
			do {
				// Copy all the root object's graph of relationships and objects, getting the destinationStack's clonedObject if successful
        let clonedObject = try sourceObject.copyEntireObjectGraph(to: destinationContext, savingPlan: savingPlan)
				
				destinationContext.saveContextsWhileWaiting() // need to wait around for saving, otherwise defer's destinationContext.refreshAllObjects() gets called before saved
				perRootObjectCompletionHandler(clonedObject.objectID, nil)
			} catch {
        if case .saveOnlyAfterFullySuccessful = savingPlan {
          destinationContext.reset() // disregard changes, without saving them
        } else {
          destinationContext.saveContextsWhileWaiting()
        }
				perRootObjectCompletionHandler(nil, error)
				throw error
			}
		}
	}
	
  public enum TransferSaving {
    case savingAfterEveryOneToManyRelationship
    case savingAtDepth(Int) // depth=1, after every object one level below rootObject finishes, a save is conducted
    // case savingAferEveryEntity(String)
    // case savingPeriodicallyEvery(seconds: Int)
    case saveOnlyAfterFullySuccessful
  }
	static func ConductTransfer(object objectIDs: [NSManagedObjectID],
															from sourceStack: ProjectsDBStack,
															to destinationStack: ProjectsDBStack,
                              savingPlan: TransferSaving,
															perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler
	) throws {

		defer {
			sourceStack.saveAndRefreshAllContexts()
			destinationStack.saveAndRefreshAllContexts()
		}
		for objectID in objectIDs {
			do {
				llog("will attempt to transfer objectID \(objectID)")
				try Self.ConductTransferOfSingle(rootObject: objectID,
																				 from: sourceStack,
																				 to: destinationStack,
                                         savingPlan: savingPlan,
																				 perRootObjectCompletionHandler: perRootObjectCompletionHandler)
				llog("successfully transferred objectID \(objectID)")
			} catch {
				llog("error while transferring objectID \(objectID)")
				if objectIDs.count == 1 {
					llog("single object in transfer, will return with error")
					throw error
				} else {
					llog("multiple object transfer attempts, will continue with next object")
				}
			}
		}
		
	}
	
}


extension NSManagedObject {
	// https://stackoverflow.com/questions/2730832/how-can-i-duplicate-or-copy-a-core-data-managed-object

  func copyEntireObjectGraph(to destinationContext: NSManagedObjectContext, savingPlan: ProjectsDBStack.TransferSaving) throws -> NSManagedObject {
    
		var cache = Dictionary<NSManagedObjectID, NSManagedObject>()
		return try cloneObject(to: destinationContext, cache: &cache, depth: 1, savingPlan: savingPlan)

	}

  func cloneObject(to destinationContext: NSManagedObjectContext, cache alreadyCopied: inout Dictionary<NSManagedObjectID, NSManagedObject>, depth: Int, savingPlan: ProjectsDBStack.TransferSaving) throws -> NSManagedObject {
    
    guard let entityName = self.entity.name else {
      llog("source.entity.name == nil")
      throw ProjectsDBStack.MyError.MissingStack
    }
    
    if let storedCopy = alreadyCopied[self.objectID] {
      return storedCopy
    }
    
    let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into: destinationContext)
    alreadyCopied[self.objectID] = cloned // CMRS - interesting, this caches the enclosing managedObject's id as key and caches the new cloned object as the value (should be from their respective contexts)
    
    if let attributes = NSEntityDescription.entity(forEntityName: entityName, in: destinationContext)?.attributesByName {
      // CMRS - fetches the destination entity's attributes (could skip a source entity's attribute if not in destination entity)
      
      for key in attributes.keys {
        
        // first confirm that awakeFromInsert didn't inject a value that should be used instead of source value
        if cloned.value(forKey: key) == nil {
          cloned.setValue(self.value(forKey: key), forKey: key)
        }
      }
      
    }
    
    if let relationships = NSEntityDescription.entity(forEntityName: entityName, in: destinationContext)?.relationshipsByName {
      
      for (key, value) in relationships {
        
        if value.isToMany {
          
          if let sourceSet = self.value(forKey: key) as? NSMutableOrderedSet {
            
            guard let clonedSet = cloned.value(forKey: key) as? NSMutableOrderedSet else {
              llog("Could not cast relationship \(key) to an NSMutableOrderedSet")
              throw ProjectsDBStack.MyError.MissingStack
            }
            
            let enumerator = sourceSet.objectEnumerator()
            
            var nextObject = enumerator.nextObject() as? NSManagedObject
            
            while let relatedObject = nextObject {
              
              let clonedRelatedObject = try relatedObject.cloneObject(to: destinationContext, cache: &alreadyCopied, depth: depth+1, savingPlan: savingPlan)
              clonedSet.add(clonedRelatedObject)
              nextObject = enumerator.nextObject() as? NSManagedObject
              
            }
						cloned.setValue(clonedSet, forKey: key)

          } else if let sourceSet = self.value(forKey: key) as? NSMutableSet {
            
            guard let clonedSet = cloned.value(forKey: key) as? NSMutableSet else {
              llog("Could not cast relationship \(key) to an NSMutableSet")
              throw ProjectsDBStack.MyError.MissingStack
            }
            
            let enumerator = sourceSet.objectEnumerator()
            
            var nextObject = enumerator.nextObject() as? NSManagedObject
            
            while let relatedObject = nextObject {
              
              let clonedRelatedObject = try relatedObject.cloneObject(to: destinationContext, cache: &alreadyCopied, depth: depth+1, savingPlan: savingPlan)
              clonedSet.add(clonedRelatedObject)
              nextObject = enumerator.nextObject() as? NSManagedObject
              
            }
						cloned.setValue(clonedSet, forKey: key)
          }
          
          if case .savingAfterEveryOneToManyRelationship = savingPlan {
            // context.saveAndRefresh()
						self.managedObjectContext?.saveAndRefresh()
						// destinationContext.saveAndRefresh()
          }
          
        } else {
          // when .isToMany == false
          if let relatedObject = self.value(forKey: key) as? NSManagedObject {
            
            let clonedRelatedObject = try relatedObject.cloneObject(to: destinationContext, cache: &alreadyCopied, depth: depth+1, savingPlan: savingPlan)
            cloned.setValue(clonedRelatedObject, forKey: key)
            
          }
          
        }
        
      }
      
    }
    
    if case let .savingAtDepth(savingDepth) = savingPlan,
       savingDepth == depth {
			self.managedObjectContext?.saveAndRefresh()
      destinationContext.saveAndRefresh()
    }
    return cloned
    
  }

}
