//
//  File.swift
//  
//
//  Created by cms on 6/30/22.
//

import Foundation
import CoreData
import AdAstraExtensions

extension ProjectsDBStack {

	func loadThePersistentStores( _ loadCompletionHandler: @escaping (ProjectsDBStack?, Error?) -> Void = {_, _ in } ) throws {
		try Self.MigrationCheck(
			storePaths: container.persistentStoreDescriptions.map{$0.url},
			modernModel: modernManagedObjectModel )

		
		llog("container.loadPersistentStores starting")
		container.loadPersistentStores(completionHandler: { [self] (loadedStoreDescription, error) in

			llog("container.loadPersistentStores completionHandler returning after attempting to load:")
			llog(loadedStoreDescription.url ?? "-error-")
			if let loadError = error as NSError? {
//				CrashDuringDebug🛑("###\(#function): Failed to load persistent stores:\(loadError)")
                assertionFailure()
			}

			if loadedStoreDescription.url!.lastPathComponent.hasSuffix(Self.PrivateDBFilename) {
				llog("loadPersistentStores completed for _privatePersistentStore")
				self._privatePersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
				Self.UpdateMetaDataWithVersionIDsIn(model: container.managedObjectModel, store: _privatePersistentStore!)

			} else if loadedStoreDescription.url!.lastPathComponent.hasSuffix(Self.SharedDBFilename) {
				llog("loadPersistentStores completed for _sharedPersistentStore")
				self._sharedPersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
				Self.UpdateMetaDataWithVersionIDsIn(model: container.managedObjectModel, store: _sharedPersistentStore)

				// startAudienceUsherIfCompatable()
			}


			llog("load persistent stores completion handler finished")


			// Finished
			loadCompletionHandler(self, error)

		})
	}


	public func disconnectPersistentStores(skipSave: Bool = false){
		if skipSave.isFalse { saveAllContexts() }
		let psCoordinator = container.persistentStoreCoordinator
		psCoordinator.persistentStores.forEach{store in
			try? psCoordinator.remove(store)
		}
		_privatePersistentStore = nil
		_sharedPersistentStore = nil
	}

	public func reconnectPersistentStores (
		reconnectCompletionHandler: @escaping (ProjectsDBStack?, Error?) -> Void = {_, _ in }
	) throws {
		try loadThePersistentStores(reconnectCompletionHandler)
	}


	public func duplicatePrivateStore(to url: URL) throws  {
		guard let privatePersistentStore else { throw MyError.MissingStore }
		try self.container.persistentStoreCoordinator.migratePersistentStore(
			privatePersistentStore,
			to: url, withType: NSSQLiteStoreType )
	}

	public func importReplacementStore(
		from replacementStoreURL: URL,
		importCompletionHandler: @escaping (ProjectsDBStack?, Error?) -> Void = {_, _ in }
	) throws {
		disconnectPersistentStores(skipSave: true)

		try self.container.persistentStoreCoordinator.destroyPersistentStore(
			at: self.sharedDBLocation,
			ofType: NSSQLiteStoreType)

		try self.container.persistentStoreCoordinator.replacePersistentStore(
			at: privateDBLocation,
			withPersistentStoreFrom: replacementStoreURL,
			ofType: NSSQLiteStoreType)

		try loadThePersistentStores(importCompletionHandler)
	}

}

