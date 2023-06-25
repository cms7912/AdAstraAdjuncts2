//
//  File.swift
//  
//
//  Created by cms on 1/7/22.
//

import Foundation
import CoreData
import AdAstraExtensions
import AAFileManager

extension ProjectsDBStack {
	// keeps in store's metadata the store's models used via the models' versionIDs. (merged models compine these id sets)
	public static let ModelVersionIDsKey: String = "ModelVersionIDsKey"
	public static func UpdateMetaDataWithVersionIDsIn(model: NSManagedObjectModel, store: NSPersistentStore?){
		guard let store = store,
					let ids: Set<String> = model.versionIdentifiers as? Set<String> else { return }
		try? store.loadMetadata()
		if var metadata = store.metadata {
			metadata.updateValue(Array(ids), forKey: Self.ModelVersionIDsKey)
			store.metadata = metadata
			llog("\(store.url?.lastPathComponent)'s updated metadata: \(store.metadata)")
		}
	}

}

extension NSManagedObjectModel {
   convenience init?(contentsOf url: URL,
        addVerionID: Bool = true
   ){
      self.init(contentsOf: url)
      
      let ids: [AnyHashable] = self.versionIdentifiers.compactMap{
         if let v = $0 as? String {
            return v.asNilIfEmpty
         }
         return $0
      }
      
      if ids.isNotEmpty {
//         CrashAfterUserAlert🛑("unexpectedly found non-empty versionIdentifiers when opening \(url.lastPathComponent) full path: \(url)")
          assertionFailure()
          fatalError()
      }
      let filename = url.deletingPathExtension().lastPathComponent
      
      _ = self.versionIdentifiers.insert(filename)
      
      llog("🥞 Loaded \(filename), model versionIdentifiers: /n \(self.versionIdentifiers)")
      
   }
}



extension ProjectsDBStack {
   static func MigrationCheck(storePaths: [URL?], modernModel: NSManagedObjectModel ) throws {
      
		 for checkingStorePath in storePaths {
			 Self.llog("migration check for: \(checkingStorePath)")
			 guard let checkingStorePath = checkingStorePath,
						 AdAstraFM_NEW.itemExists(atPath: checkingStorePath) else { continue }
			 // Check if store exists (not a new install) and if migration is needed


			 // Test whether existing store is a modernModel and migrate if needed
			 var currentStoreIsModern: Bool = false
			 do {
				 let metadata: [String:Any] = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: checkingStorePath)

				 currentStoreIsModern = modernModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)

				 Self.llog("currentStoreIsModern \(currentStoreIsModern)")
			 } catch {
				 Self.llog("⚠️ Testing for currentStoreIsModern failed try to get metadata")
//				 CrashDuringDebug🛑()
                 assertionFailure()
				 currentStoreIsModern = true
			 }



          guard !currentStoreIsModern else { return }
          // store was not modern, will attempt to migrate

			 Self.llog("will need migration, starting")
			 do {
				 // Conduct any old-to-current db migration

				 let mallard = try MallardMigration2(
					managedObjectModelsPackageName: Self.ModelPackageName,
					ModelPackageFilenameSequence: Self.ModelPackageFilenamesInSequence)

				 mallard.add(Self.ModelMigrationMappings)

				 try mallard.progressivelyMigrate(store: checkingStorePath)

			 } catch {
				 Self.llog("⚠️ MallardMigration failed ")
//				 CrashDuringDebug🛑("MigrationCheck failed to migrate")
                 assertionFailure()
//				 ToDo(.releasable, "Add user alert to failed migration")
				 // CrashAfterUserAlert🛑("Incompatible model found. Remove Caleo then download again, or contact the developer for debugging assistance.")
				 throw error
			 }

		 }
      
      
      
      
      
   }
}
