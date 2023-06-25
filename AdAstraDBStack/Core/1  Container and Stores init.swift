//
//  File.swift
//
//
//  Created by cms on 6/30/22.
//

import Foundation
import CloudKit
import CoreData

extension ProjectsDBStack {
  static func SetupModernModel() throws -> NSManagedObjectModel {
    let myself = Bundle.module
    let modelURL = ModelBundle.url(forResource: Self.ModelPackageName, withExtension: "momd")!
    // let modelURLs = Bundle.allBundles.compactMap{
    // $0.url(forResource: Self.ModelPackageName, withExtension: "momd") }
    llog("-- modelURLs: -- ")
    llog(modelURL)
    // llog(modelURLs)
    // assert(modelURLs.count == 1)
    // let modelURL = modelURLs.first!

    // Setup Model
    //    guard let modelURL = Bundle.module.url(forResource: Self.ModelPackageName, withExtension: "momd") else {
    //      llog("Unable to Find CoreData modelURL at: \(Bundle.main.bundleURL)")
    //   throw MyError.NoDestinationModelFound
    // }


    // automatically pulls the current model via '.xccurrentversion'

    guard let primaryManagedObjectModel = NSManagedObjectModel(contentsOf: modelURL, addVerionID: true) else {
      llog("Unable to Load CoreData managedObjectModel")
      throw MyError.NoDestinationModelFound
    }
    // if let AudienceUsher_ParentProjectEntityName = Self.AudienceUsher_ParentProjectEntityName {
    //    // will add AudienceUsher
    //    return AudienceUsher.AppendAudienceUsherModel(
    //       into: primaryManagedObjectModel, ParentProjectEntityName: AudienceUsher_ParentProjectEntityName)
    // }

    return primaryManagedObjectModel
  }

  static func InitContainer(
    inTempFolderTesting: Bool,
    syncingAvailable: Bool,
    sharingAvailable: Bool,
    readOnlyStack: Bool,
    projectDBFolder: URL,
    modernManagedObjectModel: inout NSManagedObjectModel
  ) throws -> NSPersistentCloudKitContainer {
    // Build Persistent Store Container
    // let newContainer = NSPersistentCloudKitContainer(
    let newContainer = ProjectsDBStackContainer(
      name: Self.ModelPackageName,
      managedObjectModel: modernManagedObjectModel,
      bundle: Bundle.module
    )
    // Setup Private Store
    guard let privateStoreDescription = newContainer.persistentStoreDescriptions.first else { throw MyError.MissingStore }
    // privateStoreDescription.configuration = "Default"
    if !readOnlyStack {
      privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
      privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    }

    // container.persistentStoreDescriptions = [privateStoreDescription] // replace

    // Setup Shared Store
    guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
      fatalError("Copying the private store description returned an unexpected value.")
    }

    // sharedStoreDescription.configuration = "Default"
    privateStoreDescription.url = Self.BuildPrivateDBLocation(within: projectDBFolder)
    sharedStoreDescription.url = sharingAvailable ? Self.BuildSharedDBLocation(within: projectDBFolder) : nil

    if inTempFolderTesting {
      privateStoreDescription.cloudKitContainerOptions = nil
      sharedStoreDescription.cloudKitContainerOptions = nil
    } else {
      guard projectDBFolder != Self.inMemoryLocation else {
        fatalError("unexpectedly trying to use inMemoryLocation  on in-memory container")
      }
      if readOnlyStack {
        // privateStoreDescription.options =
        // [NSReadOnlyPersistentStoreOption : NSNumber(false) ]
        privateStoreDescription.setOption(NSNumber(true), forKey: NSReadOnlyPersistentStoreOption)
        sharedStoreDescription.setOption(NSNumber(true), forKey: NSReadOnlyPersistentStoreOption)
      } else {
        if syncingAvailable {
          let privateCloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Self.CloudKitContainerIdentifier) // setting container identifier can also be used to access multiple containers from different apps
          privateStoreDescription.cloudKitContainerOptions = privateCloudKitContainerOptions

          if sharingAvailable {
            let sharedCloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Self.CloudKitContainerIdentifier)
            sharedStoreDescription.cloudKitContainerOptions = sharedCloudKitContainerOptions
          }
        } else {
          privateStoreDescription.cloudKitContainerOptions = nil
          sharedStoreDescription.cloudKitContainerOptions = nil
        }
      }

      newContainer.persistentStoreDescriptions = [privateStoreDescription] // replace

      #if !DebugWithoutCloudKit
      // #if false
      if sharingAvailable {
        if #available(macCatalyst 15, iOS 15, macOS 12, *) {
          privateStoreDescription.cloudKitContainerOptions?.databaseScope = .private
          sharedStoreDescription.cloudKitContainerOptions?.databaseScope = .shared
          // container.persistentStoreDescriptions.append(sharedStoreDescription)
          newContainer.persistentStoreDescriptions = [privateStoreDescription, sharedStoreDescription]
        }
      }
      #endif
    }

    return newContainer
  }
}

public final class ProjectsDBStackContainer: NSPersistentCloudKitContainer {
  public init(name: String,
              managedObjectModel: NSManagedObjectModel,
              bundle _: Bundle = .main,
              inMemory _: Bool = false)
  {
    // guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
    // fatalError("Failed to create mom") }
    super.init(name: name, managedObjectModel: managedObjectModel)
  }
  // https://useyourloaf.com/blog/testing-core-data-in-a-swift-package/
}
