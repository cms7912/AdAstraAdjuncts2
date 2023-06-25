//
//  Mallard Migration.swift
//  Caleo
//
//  Created by cms on 1/15/22.
//  Copyright © 2022 CMS. All rights reserved.
//

import Foundation
import CoreData
// import AdAstraDBStack
import AdAstraExtensions
import os.log
import AAFileManager

public class MallardMigration2: NSObject {
   
   public override func llogPrefix() -> String? { "🦆" }
   
   var tempFolderList: [URL] = [URL]()
   func cleanupTempFolders() {
      for eachFolder in tempFolderList {
         llog("will attempt clean up")
         _ = try? FileManager.default.removeItem(at: eachFolder)
      }
   }

   public struct ManagedObjectModelCard: Equatable { //}: Comparable {
      // let version: ModelVersion
      let url: URL
      let model: NSManagedObjectModel
      
      // static func < (lhs: ManagedObjectModelCard, rhs: ManagedObjectModelCard) -> Bool {
      //    // lhs.version < rhs.version
      //    Self.ModelCardsSequence.firstIndex(of: lhs)! <
      //       Self.ModelCardsSequence.firstIndex(of: rhs)!
      // }
      
      public static func == (lhs: ManagedObjectModelCard, rhs: ManagedObjectModelCard) -> Bool {
         return lhs.url == rhs.url
      }
   }
   var modelCardsSequence: [ManagedObjectModelCard] = [ManagedObjectModelCard]()
   
   public struct MigrationMappingCard {
      public init(
         sourceModelFilename: String,
         destinationModelFilename: String,
         mappingStore: NSMappingModel? = nil,
         mappingFilename: String? = nil,
         mappingInferred: Bool = false
      ) {
            self.sourceModelFilename = sourceModelFilename
            self.destinationModelFilename = destinationModelFilename
            self.mappingStore = mappingStore
         self.mappingFilename = mappingFilename
         self.mappingInferred = mappingInferred
         }
      
      var sourceModelFilename: String
      var destinationModelFilename: String
      
     var mapping: NSMappingModel? {
             mappingStore ?? mappingFromFilename
      }
      var mappingStore: NSMappingModel?

      var mappingFilename: String?
		 var mappingFromFilename: NSMappingModel? { NSMappingModel(contentsOf: Bundle.main.url(forResource: mappingFilename, withExtension: "cdm")) }

      var mappingInferred: Bool = false
   }
   var migrationMappingCards: [MigrationMappingCard] = [MigrationMappingCard]()
   
   func add(_ card: MigrationMappingCard){
      migrationMappingCards.append(card)
   }
   func add(_ cards: [MigrationMappingCard]){
      migrationMappingCards.append(contentsOf: cards)
   }
   
   var managedObjectModelsPackageName: String?
   
   init(managedObjectModelsPackageName: String? = nil,
        ModelPackageFilenameSequence: [String]? = nil
   ) throws {
      super.init()
      
      // construct 'modelCardsSequence' from given parameters, if possible
      if let packageName = managedObjectModelsPackageName,
         let filenameSequence = ModelPackageFilenameSequence {
         // given both the package and the filename sequence. Will construct 'ModelCardsSequence'.
         
         guard let fileURLs = Self.GetMOMsFileURLsFrom(packageName) else {
            Logger.llog("failed to GetMOMsFileURLsFrom \(packageName)")
            throw MigrationError.FailedToInit
         }
         
         // in filenameSequence order, find
         self.modelCardsSequence = filenameSequence.compactMap{eachName in
            
            // in sequencial order, find given filename's fileURL
            let fileURL = fileURLs.first(where: {url in
               let name = url.deletingPathExtension().lastPathComponent
               return (name == eachName)
            })
            
            // attempt to build a model card from fileURL
            if let card = Self.BuildManagedObjectModelCard(from: fileURL) {
               return card
            } else {
               llog("error, could not construct model card from given model name \(eachName)")
               return nil
            }
         }
      } else if let packageName = managedObjectModelsPackageName {
         self.managedObjectModelsPackageName = packageName
         
         // fall back to automated  build sequence
         if let seq = automatedCardSequenceFromModelsFound() {
            self.modelCardsSequence = seq
         } else {
            llog("error, could not construct any modelCardsSequence")
            throw MigrationError.FailedToInit
         }
      }
      
   }
   
   static func GetMOMsFileURLsFrom(_ momdPackageName: String?) -> [URL]? {
      guard let documentsBaseURL = Bundle.main.resourceURL else { return nil }
      guard let packageName = momdPackageName else { return nil }
      var projectDB_URL = documentsBaseURL
      projectDB_URL.appendPathComponent("\(packageName).momd/")
      
      // Get .moms
      guard let fileURLs: [URL] = AdAstraFM_NEW.contentsOf(directory: projectDB_URL) else { return nil }
      
      return fileURLs
   }
   
   static func BuildManagedObjectModelCard(from modelURL: URL?) -> ManagedObjectModelCard? {
      guard let modelURL = modelURL else { return nil }
      guard modelURL.pathExtension == "mom" else {
         llog("Failed pathExtension test, looking for 'mom' but found '\(modelURL.pathExtension)'")
         return nil } // '.xcdatamodel' is converted into '.mom'
      
      guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
         llog("Unable to Load Find \(modelURL.lastPathComponent) managedObjectModel")
         return nil
      }
      
      llog("loaded model \(modelURL.lastPathComponent)")
      return ManagedObjectModelCard(url: modelURL, model: managedObjectModel)

   }
   /// generates sequence in alphabetical order of found models' filenames. This may not be desired order by the app. Instead supply a ManagedObjectModelCard sequence during init.
   func automatedCardSequenceFromModelsFound() -> [ManagedObjectModelCard]? {
      
      guard let fileURLs = Self.GetMOMsFileURLsFrom(self.managedObjectModelsPackageName)
          else { return nil }
          
      
      // loop through all fileURLs and build a [ManagedObjectModelCard]
      var modelCards: [ManagedObjectModelCard] = fileURLs.compactMap { modelURL -> ManagedObjectModelCard? in
         
         return Self.BuildManagedObjectModelCard(from: modelURL)
      }
      
      // put models in order for comparison
      modelCards.sort {
         $0.url.lastPathComponent < $1.url.lastPathComponent
      }
      
      return modelCards
   }
   
   static func ReplacePerisistentStore(using modelCard: ManagedObjectModelCard, from sourceStoreURL: URL, to destStoreURL: URL) throws {
      
      let psc = NSPersistentStoreCoordinator(managedObjectModel: modelCard.model)
      llog("will attempt .replacePersistentStore")
      try psc.replacePersistentStore(
         at: destStoreURL,
         destinationOptions: nil,
         withPersistentStoreFrom: sourceStoreURL,
         sourceOptions: nil,
         ofType: NSSQLiteStoreType
      )
		 llog("finished .replacePersistentStore")

      ProjectsDBStack.UpdateMetaDataWithVersionIDsIn(model: modelCard.model, store: psc.persistentStore(for: destStoreURL))
   }
   
   // this finds the first historical model that is compatible with persistentStore's model
   func findFirstCompatibleModelCard(for storeURL: URL, using models: [ManagedObjectModelCard]) throws -> ManagedObjectModelCard {
      llog()
      var metadata: [String: Any] = [String: Any]()
      do {
         metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL)
      } catch {
         llog("meta data extraction failed for \(storeURL)")
         throw MigrationError.InvalidMetadata
      }
      
      
      // Highlight's Example Projects need special handling:
      if let index = metadata.index(forKey: "modifiedTimestamp"),
         let modifiedTimestamp = metadata[index].value as? Date {
         
         let components = Calendar.current.dateComponents([.year, .month, .day], from: modifiedTimestamp)
         
         if components.year == 2020,
            components.month == 8,
            components.day == 14 {
            llog("--processing as an example project--")
            // assume this is an Example Project and process it anyway
            
            // return idx
            // return -1 // used to indicate Example Project
            // return 0
            return models[0] // hard coded to return the base original model
         }
      }
      
      // use ModelVersionIDsKey that ProjectDBStack adds to metadate as a quick hint
      if let versionID = metadata[ProjectsDBStack.ModelVersionIDsKey] as? String,
         let model = models.first(where: {modelCard in
            modelCard.url.lastPathComponent == versionID
         }) {
         return model
      }
      
      // finds first model that is compatible with extracted metadata
      guard let index = models.firstIndex(where: { modelCard in
         // let finalModel = HighlightDBStack.AppendAudenceUsher(
         //    to: modelCard.model,
         //    ifFoundIn: metadata)
         
         return  modelCard.model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
         
      }) else {
         llog("no initial compatible model found")
         throw MigrationError.IncompatibleModels
      }
      return models[index]
   }

   
   // Here’s the first function that loops through the object models.
   // models: [model_v1, model_v2, ... , model_vN]
   func progressivelyMigrate(store originalStoreURL: URL) throws {
      /// this function could be used to migrate only to a subset of models, but currently not used--simply passed Self.AllManagedObjectModels
      defer { cleanupTempFolders() }
      
      let modelCards = self.modelCardsSequence
      if modelCards.isEmpty {
         llog("no modelCardsSequence found")
         throw MigrationError.IncompatibleModels
      }
      
      llog("Will search for compatible model among these, in order:")
      llog(modelCards.map {$0.url.lastPathComponent}.joined(separator: "\n") )
      
      var currentSourceModelCard = try findFirstCompatibleModelCard(for: originalStoreURL, using: modelCards)
      
      if currentSourceModelCard == modelCards[0] {
         llog("Will first handle Example Project ")
         let usingModel = modelCards[0].model
         
         try autoreleasepool {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: usingModel)
            let newStore = try psc.addPersistentStore(
               ofType: NSSQLiteStoreType,
               configurationName: nil,
               at: originalStoreURL,
               options: [NSMigratePersistentStoresAutomaticallyOption: true,
                               NSInferMappingModelAutomaticallyOption: true]
            )
            try psc.remove(newStore)
         }
      }
      
		 llog("Move data to temp folder for migrations in case they fail")
      let workingStoreURL = AdAstraFM_NEW.createTempFolder( &tempFolderList )
         .appendingPathComponent(originalStoreURL.lastPathComponent)
      try Self.ReplacePerisistentStore(
         using: currentSourceModelCard,
         from: originalStoreURL,
         to: workingStoreURL)
      
      
      // cycle through until current model is the last model
      while currentSourceModelCard != modelCards.last {
         
         // find remaining models after current source
         let currentSourceIndex = modelCards.firstIndex(of: currentSourceModelCard)!
         let nextSourceIndex = modelCards.index(after: currentSourceIndex)
         let modelCardsAfterSourceModelCard: ArraySlice<ManagedObjectModelCard> = modelCards.suffix(from: nextSourceIndex )
         
         // Loops over the subsequent models testing if it can migrate
         for testDestinationModelCard in modelCardsAfterSourceModelCard {
            do {
               try attemptMigration(on: workingStoreURL, from: currentSourceModelCard, to: testDestinationModelCard)
               // successfully migrated if try succeeded
               llog("🎉 successfully migrated from: \(currentSourceModelCard.url.lastPathComponent)   to: \(testDestinationModelCard.url.lastPathComponent) ")
               
               currentSourceModelCard = testDestinationModelCard // if this is the last model, the while loop will exit
               break
            } catch {
               if testDestinationModelCard == modelCards.last {
                  // tested last possible destination model, failed to find a model
                  llog("reached last model without successfully migrating, will exit with error")
                  throw MigrationError.NoDestinationModelFound
               } else {
                  llog("migration failed, but not at last model, will continue trying next model")
               }
               // try failed, but not at last model, let for loop continue
            }
         }
         // while loop will repeat unless currentSourceModel is now the last model
      }
      
      llog("🎉 successfully migrated to last model 🎉")
      
      
      llog("Will put store back in original location")
      try Self.ReplacePerisistentStore(using: currentSourceModelCard, from: workingStoreURL, to: originalStoreURL)
      
      llog("Successfully completed migration. ✅")
      
   }
   
   func test () {
   }
   
   // perform actual migration
	func attemptMigration(on workingStoreURL: URL, from sourceModelCard: ManagedObjectModelCard, to destinationModelCard: ManagedObjectModelCard) throws {

		llog("from: \(sourceModelCard.url.lastPathComponent)   to: \(destinationModelCard.url.lastPathComponent) ")

		// Prepare temp directory
		let tempFolder = AdAstraFM_NEW.createTempFolder( &tempFolderList )

		llog("will attempt to find a mapping between the two models given")
		let mapping: NSMappingModel = try findMappingBetweeenModels(
			from: sourceModelCard,
			to: destinationModelCard)
		let tempDestURL = tempFolder.appendingPathComponent(workingStoreURL.lastPathComponent)

		let migrationManager = NSMigrationManager(
			sourceModel: sourceModelCard.model,
			destinationModel: destinationModelCard.model)
		do {
			try autoreleasepool {
				llog("will attempt migrateStore")
				try migrationManager.migrateStore(
					from: workingStoreURL,
					sourceType: NSSQLiteStoreType,
					options: nil,
					with: mapping,
					toDestinationURL: tempDestURL,
					destinationType: NSSQLiteStoreType,
					destinationOptions: nil
				)
				llog("finished NSMigrationManager.migrateStore")
			}
		} catch {
         print(error)
//			CrashDuringDebug🛑("migrationManager.migrateStore failed")
            assertionFailure()
			throw error
		}

		do {
			// Replace source store
			// The last step where we replace the source store is very important. otherwise migrated store stays in temp folder at destURL
			try Self.ReplacePerisistentStore(
				using: destinationModelCard,
				from: tempDestURL,
				to: workingStoreURL)
		} catch {
//			CrashDuringDebug🛑("Replace source store failed")
            assertionFailure()
			throw error

		}
	}
   

   
   /// Returns NSMappingModel, either a  known '.xcmappingmodel' or an inferred mapping
   /// but this throws error if even an inferred mapping cannot be created
   func findMappingBetweeenModels(from sourceModel: ManagedObjectModelCard, to destinationModel: ManagedObjectModelCard) throws -> NSMappingModel {
      llog()
      
      if false {
         // look for custom mapping:
         // this search in Bundle.allBundles seems to take ~12 seconds in the simulator
         if let mapping = NSMappingModel(from: Bundle.allBundles, forSourceModel: sourceModel.model, destinationModel: destinationModel.model) {
            return mapping // found custom mapping
         }
      }
      
      /*
      if sourceModel.version == .v20200730Original &&
            destinationModel.version == .v20211110Highlight {
         llog("providing known mapping")
         let knownMapping = NSMappingModel(contentsOf: Bundle.main.url(forResource: "projectDB_20200730ToHighlight20211110 4", withExtension: "cdm"))!
         return knownMapping
      }
      */
      
      // Searh 'migrationMappingCards' for a known mapping
      if let knownMappingCard = migrationMappingCards.first(where: { card in
         card.sourceModelFilename == sourceModel.url.lastPathComponent &&
         card.destinationModelFilename == destinationModel.url.lastPathComponent
      }) {
         llog("Found knownMappingCard")
         if let knownMapping = knownMappingCard.mapping {
            return knownMapping
         } else if knownMappingCard.mappingInferred {
            return try self.attemptInferredMapping(source: sourceModel, dest: destinationModel)
				 } else {
//					 CrashDuringDebug🛑("unexpected outcome")
                     assertionFailure()
				 }
      }
      
      
      // for entity: (key: String, value:  NSEntityDescription) in sourceModel.model.entitiesByName {
      // entity.name == destinationModel.model.entitiesByName
      // for attr in entity.key {
      // let destAttrValue = destinationModel.model.value(forKey: key)
      // }
      // }
      llog("no known mappings, will try to infer")
      return try attemptInferredMapping(source: sourceModel, dest: destinationModel)
   }
   
   func attemptInferredMapping(source: ManagedObjectModelCard, dest: ManagedObjectModelCard) throws -> NSMappingModel {
      llog("will attempt NSMappingModel.inferredMappingModel")
      return try NSMappingModel.inferredMappingModel(forSourceModel: source.model, destinationModel: dest.model)
   }
   
   // Core Data forces us to use Swift exceptions so we just go with it
   enum MigrationError: Error {
      case IncompatibleModels
      case InvalidMetadata
      case NoDestinationModelFound
      case FailedToInit
   }

   
   // adapted from: https://kean.blog/post/core-data-progressive-migrations
}
