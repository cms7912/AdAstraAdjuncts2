//
//  Swift File.swift
//  Swift File
//
//  Created by CMRS on __/__/__.
//

import Foundation
// import Caleo
// import SwiftUI
// import UIKit
// import CoreData
// import SFSafeSymbols
import os.log

public protocol AdAstraFM_ProjectSpecificProtocol {
    static var AppGroupFolderName: String { get }
}

public class AdAstraFM_NEW: NSObject {
    static let shared = AdAstraFM_NEW()
    
    public static let appTargetDocumentsRootFolder: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }()
    
    private static let appGroupDocumentsRootFolder: URL = {
        // var appGroup: String = "group.app.adastra.projectladder"
        var appGroup: String = {
            var appGroup = ""
            if let P = AdAstraFM_NEW.self as? AdAstraFM_ProjectSpecificProtocol.Type {
                appGroup = P.AppGroupFolderName
                // appGroup = P.self.AppGroupFolderName
            } else {
                CrashAfterUserAlert("No app group found.")
            }
            return appGroup
        }()
        
        guard var fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        // fileContainer.relativePath
        return fileContainer
    }()
    
    
    public static let CurrentDataFolderInAppGroup: URL = {
        guard let cdd = getFolder(at: appGroupDocumentsRootFolder.appendingPathComponent("CurrentData") ) else {
            fatalError("Unable to create CurrentData folder")
        }
        return cdd
    }()
    
    public static let ArchiveDataFolderInAppGroup: URL = {
        guard let cdd = getFolder(at: appGroupDocumentsRootFolder.appendingPathComponent("ArchiveData") ) else {
            fatalError("Unable to create ArchiveData folder")
        }
        return cdd
    }()
    
}

public extension AdAstraFM_NEW {
  static func getFolder(at folder: URL) -> URL? {
		if FileManager.default.fileExists(atPath: folder.relativePath) {
			return folder
    } else {
			do {
				try FileManager.default.createDirectory(atPath: folder.relativePath, withIntermediateDirectories: true, attributes: nil)
				return folder
			} catch CocoaError.fileWriteFileExists {
				// folder already exists
				return folder
			} catch {
				print(error.localizedDescription)
				return nil
			}
		}
	}

  static func getFolderContents(of folder: URL) -> [URL]? {
		var items: [URL] = [URL]()
		do {
			items = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
		} catch {
			print(error.localizedDescription)
			return nil
		}
		return items
	}


  static func createTempFolder() -> URL {
		let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent( (ProcessInfo().globallyUniqueString) )
		guard let newFolder = self.getFolder(at: tempDir) else {
			// NSObject.CrashAfterUserAlert("Unexpectedly cannot create temp folder")

			fatalError("Unexpectedly cannot create temp folder")
		}

		if FileManager.default.fileExists(atPath: newFolder.relativePath) {
			return newFolder
		} else {
			do {
				try FileManager.default.createDirectory(atPath: newFolder.relativePath, withIntermediateDirectories: true, attributes: nil)
				return newFolder
			} catch CocoaError.fileWriteFileExists {
				// folder already exists
				return newFolder
			} catch {
				print(error.localizedDescription)
				fatalError("Unexpectedly cannot create temp folder")
			}
		}
		return newFolder
	}
  static func createTempFolder( _ addToList: inout [URL] ) -> URL {
      let newFolder = createTempFolder()
      addToList.append(newFolder)
      return newFolder
   }

  static func traverseContentsOfFolder(path: URL) -> String {
		var textContents: String = path.absoluteString + "\n"
		if let contents = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: []) {
			for eachItem in contents {
				textContents.append(
					traverseContentsOfFolder(path: eachItem)
				)
			}
		}
		return textContents
	}
}


public extension AdAstraFM_NEW {
   static func contentsOf(directory: URL) -> [URL]? {
      try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
   }
   

   static func itemExists(atPath path: URL, isDirectory isDirObjcBool: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool {
      FileManager.default.fileExists(atPath: path.relativePath, isDirectory: isDirObjcBool)
   }
   
   
   static func moveOrCopy(onlyMove: Bool, formerItem: URL, newItem: URL, canOverwrite: Bool = false) throws {
      Logger.llog()
      
      let itemName = formerItem.lastPathComponent
      
      var formerItemIsDirectoryAsObjcCBool: ObjCBool = false
      var formerItemIsDirectory: Bool {
         formerItemIsDirectoryAsObjcCBool.boolValue
      }
      var formerItemIsFile: Bool { !formerItemIsDirectory }
      guard itemExists(atPath: formerItem, isDirectory: &formerItemIsDirectoryAsObjcCBool) else {
         Logger.llog("no source \(itemName) to move/copy")
         return
      }
      Logger.llog("source \(itemName) item exist")
      
      // ensure a parent directory exists
      let newParentDirectory = newItem.deletingLastPathComponent()
      if !itemExists(atPath: newParentDirectory) {
         Logger.llog("will try creating newItem \(itemName).")
         try FileManager.default.createDirectory(at: newParentDirectory, withIntermediateDirectories: true)
      }
      
      var newItemIsFile: Bool { !newItemIsDirectory }
      var newItemIsDirectory: Bool {
         newItemIsDirectoryAsObjcCBool.boolValue
      }
      var newItemIsDirectoryAsObjcCBool: ObjCBool = false
      if itemExists(atPath: newItem, isDirectory: &newItemIsDirectoryAsObjcCBool) {
         Logger.llog(" an item exists in newItem's destination ")
         
         if canOverwrite {
            Logger.llog("canOverwrite allowed, will remove existing item")
            try FileManager.default.removeItem(at: newItem)
            
         } else {
            if newItemIsFile {
               Logger.llog("⚠️ error: new item would replace existing file \(itemName).")
               throw NSError(domain: "error: new item would replace existing file", code: -7912, userInfo: nil)
            } else {
               // new item is directory
               if let contents = try? FileManager.default.contentsOfDirectory(at: newItem, includingPropertiesForKeys: nil, options: []) ,
                  contents.isEmpty {
                  
                  Logger.llog("new folder exists but is empty, will remove and allow move/copy to replace \(itemName).")
                  try FileManager.default.removeItem(at: newItem)
                  
               } else {
                  Logger.llog("⚠️ error: new item would replace existing folder \(itemName).")
                  throw NSError(domain: "error: new item would replace existing folder", code: -7912, userInfo: nil)
                  
               }
            }
         }
      }
      
      
      // begin move/copy
      Logger.llog("begin")
      // Logger.llog("\(itemName) ready")
      do {
         if onlyMove {
            Logger.llog("will move \(itemName)")
            try FileManager.default.moveItem(atPath: formerItem.relativePath, toPath: newItem.relativePath)
         } else {
            Logger.llog("will copy \(itemName)")
            try FileManager.default.copyItem(atPath: formerItem.relativePath, toPath: newItem.relativePath)
         }
      } catch let error {
         Logger.llog("error in moving/copying of \(itemName): \(error.localizedDescription) ")
         throw error
      }
      Logger.llog("successfully moved/copied \(itemName)")
   }
   static func move(formerItem: URL, newItem: URL) throws {
      Logger.llog()
      try moveOrCopy(onlyMove: true, formerItem: formerItem, newItem: newItem)
   }
   static func copy(formerItem: URL, newItem: URL) throws {
      Logger.llog()
      try moveOrCopy(onlyMove: false, formerItem: formerItem, newItem: newItem)
   }


}
