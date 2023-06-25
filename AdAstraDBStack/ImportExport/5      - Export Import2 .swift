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
// import SFSafeSymbols
import AdAstraExtensions
//import AdAstraBridgingByShim
import AAFileManager
import Zip
import AdAstraDBStackCore


extension ProjectsDBStack {
   public typealias TransitionCompletionHandler = (Bool, Error?) -> Void
   // public typealias TransitionCompletionHandlerThrows = (Bool, Error?) throws -> Void
   public typealias TransitionCompletionHandlerWithURL = (URL?, Error?) -> Void
   // public typealias TransitionCompletionHandlerWithURLThrows = (URL?, Error?) throws -> Void
	public typealias TransferRootObjectCompletionHandler = (NSManagedObjectID?, Error?) -> Void
public typealias TransferHandlerWithStack = (ProjectsDBStack) -> Void

	func duplicate(_ objectID: NSManagedObjectID,
				   completionHandler: @escaping (Bool, Error?) -> Void = {_, _ in }
	){
	}
    
    
    
    
    
    // MARK: - Import/Export -

    // Duplicate given project
     func duplicateProject(_ objectID: NSManagedObjectID, completionHandler: @escaping (Bool, Error?) -> Void = {_, _ in }) { duplicate(objectID, completionHandler: completionHandler) }
      
    /// Called on external sourceStack before it is imported to destinationStack
     func preImportProcessing() {
      // before importing this stack instance, do these things
    }

    /// Called on external destinationStack after successfully exporting from sourceStack
     func postExportProcessing() {
      // after export, do these things on this exported stack instance
    }



}




// MARK: - Exporting

extension ProjectsDBStack {

	/// Exports from given source stack using ExportProjectsDBStackManager
	class func ExportProjectsDBStack(
		from sourceStack: ProjectsDBStack,
		onlyRootObjects rootObjectIDs: [NSManagedObjectID],
		perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
		completionHandler: @escaping TransitionCompletionHandlerWithURL
		// no default handlers to ensure convenience functions will pass in their values
	) {

		let tempStoreLocation = AdAstraFM_NEW.createTempFolder()

		// let DBStack = type(of: sourceStack)
    let destinationStack = try? Self.init(inTempFolderTesting: false,
                                          syncingAvailable: false,
                                          sharingAvailable: false,
                                          readOnlyStack: true,
                                          projectFolder: tempStoreLocation){ returnedDestinationStack, error in
			guard let returnedDestinationStack = returnedDestinationStack,
				  error == nil else { completionHandler(nil, error); return }
			conductExport(returnedDestinationStack)
			returnedDestinationStack.postExportProcessing()
		}

		if destinationStack == nil {
			llog("failed to create destinationStack")
			completionHandler(nil, MyError.MissingStack)
		}
		func conductExport(_ destinationStack: ProjectsDBStack) {
			do {
        try Self.ConductTransfer(object: rootObjectIDs,
                                 from: sourceStack,
                                 to: destinationStack,
                                 savingPlan: .saveOnlyAfterFullySuccessful,
                                 perRootObjectCompletionHandler: perRootObjectCompletionHandler)
				completionHandler(tempStoreLocation, nil)
			} catch  {
				completionHandler(tempStoreLocation, error)
			}
		}
	}
	/// convenience function for exporting from this ProjectsDBStack instance
	func export(
		onlyRootObjects rootObjectIDs: [NSManagedObjectID],
		perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler = {_, _ in },
		completionHandler: @escaping TransitionCompletionHandlerWithURL = {_, _ in }
	) throws {
		try Self.ExportProjectsDBStack(from: self,
								   onlyRootObjects: rootObjectIDs,
								   perRootObjectCompletionHandler: perRootObjectCompletionHandler,
								   completionHandler: completionHandler
		)
	}

	// Exports from given source stack and Zips
	static func ExportProjectsDBStackAndZip(
		from sourceStack: ProjectsDBStack,
		onlyRootObjects rootObjectIDs: [NSManagedObjectID],
		exportedFilenameAndExtension: String,
		perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
		completionHandler: @escaping TransitionCompletionHandlerWithURL
	) {

		 ExportProjectsDBStack(from: sourceStack,
							  onlyRootObjects: rootObjectIDs,
							  perRootObjectCompletionHandler: perRootObjectCompletionHandler
		){ url, error in
			guard let path = url, error == nil
			else { completionHandler(nil, error); return }
			Zipper(path,
				   exportedFilenameAndExtension: exportedFilenameAndExtension,
				   completionHandler: completionHandler)
		}
	}
	/// convenience function for exporting from this instance
	public func exportProjectsDBStackAndZip(
		onlyRootObjects rootObjectIDs: [NSManagedObjectID],
		exportedFilenameAndExtension: String,
		perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler ,
		completionHandler: @escaping TransitionCompletionHandlerWithURL
	){
		Self.ExportProjectsDBStackAndZip(from: self,
										 onlyRootObjects: rootObjectIDs, exportedFilenameAndExtension: exportedFilenameAndExtension,
										 perRootObjectCompletionHandler: perRootObjectCompletionHandler,
										 completionHandler: completionHandler
		)
	}
}



// MARK: - Importing

public extension ProjectsDBStack {
  
  /// imports from provided URL that has an exported set of files
  static func ImportProjectDBStack(
    from sourceProjectFolder: URL,
    rootObjectsInEntityNamed rootEntityName: String,
    to destinationStack: ProjectsDBStack,
    savingPlan: ProjectsDBStack.TransferSaving,
    preImportHandler: @escaping TransferHandlerWithStack,
    perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
    completionHandler: @escaping TransitionCompletionHandler
    // no default handlers to ensure convenience functions will pass in their values
  ) {
    
    // Create standalone sourceStack
    // - any heavy migrations will happen during Self.init's opening the dbPath
    // - (because Self is the app's subclass of ProjectDBStack)
    
    let sourceStack = try? Self.init(
      inTempFolderTesting: false,
      syncingAvailable: false,
      sharingAvailable: false,
      readOnlyStack: false, // need to be able to write for the preImportHandler
      projectFolder: sourceProjectFolder){returnedSourceStack, error in
        guard let returnedSourceStack = returnedSourceStack,
              error == nil else { completionHandler(false, error); return }
				// after successfully opened, then...
        returnedSourceStack.preImportProcessing()
        preImportHandler(returnedSourceStack) // this must be synchronous
        conductImport(returnedSourceStack)
      }
    
    if sourceStack == nil {
      completionHandler(false, MyError.MissingStack)
    }
    
    func conductImport(_ sourceStack: ProjectsDBStack) {
      
      // Find and list the root entity objects to import
      var rootObjectIDs = [NSManagedObjectID]()
      sourceStack.rootBackgroundContext.performWhileWaiting("conductImport: \(sourceStack.projectDBFolder.lastPathComponent)"){sourceContext in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: rootEntityName)
        
        if let rootObjects: [NSManagedObject] = try? sourceContext.fetch(fetchRequest) as? [NSManagedObject]  {
          rootObjectIDs = rootObjects.map{ $0.objectID }
        }
        // -^-^-end of sourceContext thread-^-^-
      }
      if rootObjectIDs.isEmpty {
        llog("importing found no rootObjects to transfer", .error)
      }
      // conduct import
      do {
        try Self.ConductTransfer(object: rootObjectIDs,
                                 from: sourceStack,
                                 to: destinationStack,
                                 savingPlan: .savingAfterEveryOneToManyRelationship,
                                 perRootObjectCompletionHandler: perRootObjectCompletionHandler)
        completionHandler(true, nil)
      } catch  {
        completionHandler(false, error)
      }
    }
    
  }
  /// convenience function for importing to this instance
  func importProjectDBStack(
    // from sourceStack: [URL],
    from sourceProjectFolder: URL,
    rootObjectsInEntityNamed rootObjectName: String,
    savingPlan: ProjectsDBStack.TransferSaving,
    preImportHandler: @escaping TransferHandlerWithStack,
    perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
    completionHandler: @escaping TransitionCompletionHandler
  ) throws {
    try Self.ImportProjectDBStack(from: sourceProjectFolder,
                                  rootObjectsInEntityNamed: rootObjectName,
                                  to: self,
                                  savingPlan: savingPlan,
                                  preImportHandler: preImportHandler,
                                  perRootObjectCompletionHandler: perRootObjectCompletionHandler,
                                  completionHandler: completionHandler)
  }
  
  
  /// imports from provided URL that has a
  class func ImportProjectDBStackFromZip(
    from givenPath: URL,
    rootObjectsInEntityNamed rootObjectName: String,
    to destinationStack: ProjectsDBStack,
    savingPlan: ProjectsDBStack.TransferSaving,
    postUnzipHandler: @escaping (URL) -> Bool,
    preImportHandler: @escaping TransferHandlerWithStack,
    perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
    completionHandler: @escaping TransitionCompletionHandler) {
      Self.Unzipper(givenPath){ url, error in
        // After unzipping, then import & postUnzipHandler success, or else error:
        guard let path = url, error == nil, postUnzipHandler(path)
        else { completionHandler(false, error); return }
        
        
        
        Self.ImportProjectDBStack(from: path,
                                  rootObjectsInEntityNamed: rootObjectName,
                                  to: destinationStack,
                                  savingPlan: savingPlan,
                                  preImportHandler: preImportHandler,
                                  perRootObjectCompletionHandler: perRootObjectCompletionHandler,
                                  completionHandler: completionHandler)
      }
    }
  /// convenience function for importing to this instance
  func importProjectDBStackFromZip(
    from givenPath: URL,
    rootObjectsInEntityNamed rootObjectName: String,
    savingPlan: ProjectsDBStack.TransferSaving,
    postUnzipHandler: @escaping (URL) -> Bool = {_ in return true},
    preImportHandler: @escaping TransferHandlerWithStack,
    perRootObjectCompletionHandler: @escaping TransferRootObjectCompletionHandler,
    completionHandler: @escaping TransitionCompletionHandler
  ) {
    Self.ImportProjectDBStackFromZip(from: givenPath,
                                     rootObjectsInEntityNamed: rootObjectName,
                                     to: self, // this instance
                                     savingPlan: savingPlan,
                                     postUnzipHandler: postUnzipHandler,
                                     preImportHandler: preImportHandler,
                                     perRootObjectCompletionHandler: perRootObjectCompletionHandler,
                                     completionHandler: completionHandler)
  }
  
}




// MARK: - Zipping
extension ProjectsDBStack {
// https://github.com/marmelroy/Zip

	/// Structure plan:
	/// Import/Export/Zipping passes around only url that points to projectFolder
	/// zipping pulls out projectFolder's contents and creates archive of those
	/// unzipping will put contents into a new temp folder that becomes the projectFolder and is passed around

	/// Zip the paths
	static func Zipper(_ projectFolder: URL,
					   exportedFilenameAndExtension: String,
					   completionHandler: @escaping TransitionCompletionHandlerWithURL)
	{
    Self.shared?.mainBackgroundContext.performWithoutWaiting("Zipper: \(exportedFilenameAndExtension)"){context in

			var finishedExportURL: URL?
			var thrownError: Error?
			defer {
				completionHandler(finishedExportURL, thrownError)
			}

			do {
				// Setup export folder
				let exportZipURL = AdAstraFM_NEW.createTempFolder().appendingPathComponent(exportedFilenameAndExtension)
				guard let projectFolderContents = AdAstraFM_NEW.getFolderContents(of: projectFolder) else { return }

				Zip.addCustomFileExtension(exportZipURL.pathExtension)
				try Zip.zipFiles(paths: projectFolderContents,
								 zipFilePath: exportZipURL,
								 password: nil,
								 compression: .BestSpeed,
								 progress: nil)
				llog("🟩 Finished export archive contents:")
				for entry in projectFolderContents {
					llog(entry.path)
				}

				finishedExportURL = exportZipURL
			} catch {
				thrownError = error
				llog("🛑 \(#function)  Creating of ZIP archive failed with error:\(error)")
				return
			}
		}
	}

	class func Unzipper(_ url: URL,
						completionHandler: @escaping TransitionCompletionHandlerWithURL){
    Self.shared?.mainBackgroundContext.performWithoutWaiting("Unzipper: \(url.lastPathComponent)"){context in
			var unzippedPath: URL?
			var thrownError: Error?
			defer {
				completionHandler(unzippedPath, thrownError)
				Self.shared?.mainBackgroundContext.saveAndRefresh()
			}

			let tempFolder = AdAstraFM_NEW.createTempFolder()
			llog("\(#function) resultURL: \(tempFolder)")
			// Unzip
			do {
				// Zip.addCustomFileExtension("caleo")
				DispatchQueue.main.sync{
					Zip.addCustomFileExtension(url.pathExtension)
					// attempting to work around a crashing race condition when multiple imports access Zip's 'customFileExtensions' static variable at the same time from different queues. 
				}
				try Zip.unzipFile(url, destination: tempFolder, overwrite: true, password: nil)
				llog("🟩 Finished import archive contents")
				unzippedPath = tempFolder
			} catch {
				thrownError = error
				llog("🛑 Extraction of ZIP archive failed with error:\(error)")
				return
			}



		}
	}

}




