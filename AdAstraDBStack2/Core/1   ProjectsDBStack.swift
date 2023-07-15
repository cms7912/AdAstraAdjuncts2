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
import CloudKit

// import Project_Ladder
// import SFSafeSymbols
import AdAstraExtensions
import AALogger
import AAFileManager

// import AdAstraBridgingByShim
// Folder Structure:
// - appGroupDocumentsDirectory
//		/CurrentData
//            / "ProjectsDB"
//                    / "PrivateStore"
//                          / "projectPrivateDB.sqlite"
//                          / projectPrivateDB.sqlite-hlm
//                          / projectPrivateDB.sqlite-wal
//		          	   / "SharedStore"
// 				    		          / "projectSharedDB.sqlite"
//                          / projectSharedDB.sqlite-hlm
//                          / projectSharedDB.sqlite-wal
//

protocol PerProjectsDBStackProtocol { }


// public protocol ProjectsDBStackProtocol{
//     // class var shared: ProjectsDBStackProtocol { get }
//     var CloudKitContainerIdentifier: String { get }
//     var managedObjectModel: NSManagedObjectModel { get }
//     var container: NSPersistentCloudKitContainer { get }
//     var sharedPersistentStore: NSPersistentStore? { get }
//     var viewContext: NSManagedObjectContext { get }
//     init?(inTempFolderTesting: Bool,
//           syncingAvailable: Bool,
//        sharingAvailable: Bool,
//        projectFolder: URL?,
//        completionHandler: @escaping (ProjectsDBStackProtocol,
//        Error) -> Void )
// }

open class ProjectsDBStack: NSObject, ObservableObject // , ProjectsDBStackProtocol
{
  // static func llog(_ string: String = "", function: String = #function) {
  // 	super.llog("🥞 \(string)", function: function)
  // }
  // func llog(_ string: String = "", function: String = #function) {
  // 	super.llog("🥞 \(string)", function: function)
  // }
  override open class func llogPrefix() -> String? { "🥞" }
  override open func llogPrefix() -> String? { "🥞" }

  public static var shared_: ProjectsDBStack?
  // subclasses need to assign 'ProjectsDBStack' to have this shared instance so that other users of ProjectsDBStack.shared will get to this same shared stack


  open class var shared: ProjectsDBStack? { Self.shared_ }
  // public static var shared: ProjectsDBStackProtocol { Self.shared_

  // ProjectsDBStack(inTempFolderTesting: true)!


  // public static var shared: ProjectsDBStackProtocol = {
  // fatalError("? This should never be called ?")
  // }()



  open class var ModelBundle: Bundle { Bundle.main }

  open class var ModelPackageName: String { "projectDB" }
  open class var ModelPackageFilenamesInSequence: [String]? { nil }
  open class var ModelMigrationMappings: [MallardMigration2.MigrationMappingCard] {
    [MallardMigration2.MigrationMappingCard]()
  }

  public var modernManagedObjectModel: NSManagedObjectModel
  // open class var ProjectListingType: NSManagedObject.Type?
  // open class var ProjectListingEntityName: String?

  open class var AudienceUsher_ParentProjectEntityName: String? { nil }

  // open var CloudKitContainerIdentifier = "iCloud.App.AdAstra.ProjectLadder"
  open class var CloudKitContainerIdentifier: String {
//    CrashDuringDebug🛑("unexpected access in ProjectsDBStack")
      assertionFailure()
    return ""
  }

  open var AppTransactionAuthorName: String { "App.AdAstra.app" }



  open class var PrivateDBFilename: String { "projectPrivateDB.sqlite" }
  open class var SharedDBFilename: String { "projectSharedDB.sqlite" }


  public static func BuildPrivateDBLocation(within projectDBFolder: URL) -> URL {
    return projectDBFolder
      .appendingPathComponent("PrivateStore")
      .appendingPathComponent(Self.PrivateDBFilename)
  }

  public static func BuildSharedDBLocation(within projectDBFolder: URL) -> URL {
    return projectDBFolder
      .appendingPathComponent("SharedStore")
      .appendingPathComponent(Self.SharedDBFilename)
  }

  var privateDBLocation: URL {
    Self.BuildPrivateDBLocation(within: projectDBFolder)
  }

  var sharedDBLocation: URL {
    Self.BuildSharedDBLocation(within: projectDBFolder)
  }

  open var projectDBFolder: URL
  lazy var projectDBCurrentDataFolder: URL = projectDBFolder.appendingPathComponent("CurrentData")


  open var container: NSPersistentCloudKitContainer

  open var initializeCloudKitSchemaOptions: NSPersistentCloudKitContainerSchemaInitializationOptions { [
    // .dryRun, // - validates the model and generates the records, but doesn’t upload them to CloudKit.
    // .printSchema // - Prints the generated records to the console.
    // (also check subclasses whether this is overridden)
  ] }
  open var initializeCloudKitSchema: Bool { false }

  internal var _privatePersistentStore: NSPersistentStore?
  public var privatePersistentStore: NSPersistentStore? { return _privatePersistentStore }
  internal var _sharedPersistentStore: NSPersistentStore?
  public var sharedPersistentStore: NSPersistentStore? { return _sharedPersistentStore }



  public static let inMemoryLocation: URL = AdAstraFM_NEW.createTempFolder()
  #if DEBUG
  open var insertInMemoryPlaceholderData: () -> Void { { } }
  open var insertSavedPlaceholderData: () -> Void { { } }
  open var placeholderFirstProject: AAProjectListingProtocol?
  #endif

  public static var InTempFolderTesting: Bool = false
  public required init?(
    inTempFolderTesting: Bool,
    syncingAvailable: Bool = true,
    sharingAvailable: Bool = true,
    readOnlyStack: Bool = false,
    projectFolder: URL, // leaving without default, too easy to call with optional and accidentally duplicate whole db by importing it again
    // completionHandler: @escaping (ProjectsDBStackProtocol, Error) -> Void = {_, _ in }
    initialLoadCompletionHandler: @escaping (ProjectsDBStack?, Error?) -> Void = {_, _ in }
  ) throws {
    projectDBFolder = projectFolder

    // NSDictionaryValueTransformer.register()


    modernManagedObjectModel = try Self.SetupModernModel()

    container = try Self.InitContainer(
      inTempFolderTesting: inTempFolderTesting,
      syncingAvailable: syncingAvailable,
      sharingAvailable: sharingAvailable,
      readOnlyStack: readOnlyStack,
      projectDBFolder: projectDBFolder,
      modernManagedObjectModel: &modernManagedObjectModel
    )

    super.init()


    try loadThePersistentStores(initialLoadCompletionHandler)


    #if DEBUG
    #if !DebugWithoutCloudKit

    if syncingAvailable {
      if initializeCloudKitSchema {
        // Only initialize the schema when building the app with the Debug build configuration.
        llog("v--- initializeCloudKitSchema ---v")
        do {
          // Use the container to initialize the development schema.
          try container.initializeCloudKitSchema(options: initializeCloudKitSchemaOptions)
        } catch {
//          CrashDuringDebug🛑("### Failed to initializeCloudKitSchema. (It's probably already initialized--turn off ' initializeCloudKitSchema'.)  Error = \(error)")
            assertionFailure()
          return nil
          // Handle any errors.
        }
        llog("^--- initializeCloudKitSchema ---^")
      }
    }
    #endif
    #endif


    // "NSPersistentStoreDescription has a flag called shouldAddStoreAsynchronously, which defaults to false" -- if needed, can make stores load asynchronously

    container.viewContext.perform {
      self.container.viewContext.name = "ViewContextOfContainerOfProjectsDBStack"
      self.container.viewContext.transactionAuthor = self.AppTransactionAuthorName
      self.container.viewContext.automaticallyMergesChangesFromParent = true
      self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      // Set the Query generation to .current. for dynamically updating views from CloudKit
      if ((try? self.container.viewContext.setQueryGenerationFrom(.current)) == nil) {
//        CrashDuringDebug🛑("??? why would this ever fail?")
          assertionFailure()
      }
    }

    contextsRegisterNotifications()
    if syncingAvailable {
        #if Disabled
      saveContextsPulseHeartbeat.scheduleNextBeat()
        #endif
    }

    // Observe Core Data remote change notifications.
    // NotificationCenter.default.addObserver(self,
    //                                        selector: #selector(storeRemoteChange(_:)),
    //                                        name: .NSPersistentStoreRemoteChange,
    //                                        object: container.persistentStoreCoordinator)

    // #if DEBUG
    // 		if inTempFolderTesting {
    // 			insertInMemoryPlaceholderData()
    // 		}
    // 		insertSavedPlaceholderData()
    // #endif
  }

  deinit { }


  // MARK: - - Extension Reference--

  /// these have to be in main class declaration


  // MARK: - Contexts

  // public lazy var __primaryContext: NSManagedObjectContext = buildPrimaryContext()

  public lazy var viewContext: NSManagedObjectContext = {
    let context = container.viewContext
    context.automaticallyMergesChangesFromParent = true
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // if user have changes in viewContext, prioritize them.
    return context
  }()

  weak var _rootBackgroundContext: NSManagedObjectContext?
  public lazy var rootBackgroundContext: NSManagedObjectContext = _rootBackgroundContext ?? { () -> NSManagedObjectContext in
    llog("buildCxt rootBackgroundContext")
    if DebugWithSingleContext { return container.viewContext }
    let context = container.newBackgroundContext()
    context.name = "ProjectsDBStack_RootBackgroundContext"
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.automaticallyMergesChangesFromParent = true
    _rootBackgroundContext = context
    return context
  }()

  // weak var _rootBackgroundContext: NSManagedObjectContext?
  // public var rootBackgroundContext: NSManagedObjectContext {
  // 	return _rootBackgroundContext ?? {
  // 		_rootBackgroundContext = self.newBackgroundContext(named: "DBStack_MnBgCxt")
  // 		return _rootBackgroundContext!
  // 	}()
  // }


  weak var _mainBackgroundContext: NSManagedObjectContext?
  public var mainBackgroundContext: NSManagedObjectContext {
    return _mainBackgroundContext ?? {
      llog("buildCxt mainBackgroundContext")
      let _mainBackgroundContext = self.newBackgroundContext(named: "DBStack_MnBgCxt")
//        _mainBackgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
//        _mainBackgroundContext.automaticallyMergesChangesFromParent = true
      self._mainBackgroundContext = _mainBackgroundContext
      return _mainBackgroundContext
    }()
  }

  weak var _utilityBackgroundContext: NSManagedObjectContext?
  public var utilityBackgroundContext: NSManagedObjectContext {
    return _utilityBackgroundContext ?? {
      llog("buildCxt utilityBackgroundContext")
      let _utilityBackgroundContext = self.newBackgroundContext(named: "utilityBgCxt")
//        _utilityBackgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
//        _utilityBackgroundContext.automaticallyMergesChangesFromParent = true
      self._utilityBackgroundContext = _utilityBackgroundContext
      return _utilityBackgroundContext
    }()
  }

  // public lazy var utilityBackgroundContext: NSManagedObjectContext =
  // newBackgroundContext(named: "utilityBgCxt")

  // public lazy var backgroundBackgroundContext: NSManagedObjectContext =
  // newBackgroundContext(named: "backgroundBgCxt")
  //
  //  public lazy var userInitiatedBackgroundContext: NSManagedObjectContext =
  // newBackgroundContext(named: "userInitBgCxt")
  //
  //  public lazy var userInteractiveBackgroundContext: NSManagedObjectContext =
  // newBackgroundContext(named: "userInterBgCxt")


  public var backgroundContextsDistributedLibrary = NSHashTable<NSManagedObjectContext>(options: .weakMemory)
  // public var backgroundContextsDistributedLibrary = NSHashTable<NSManagedObjectContext>()

  // public var  backgroundContextsDistributedLibrary = Array<NSManagedObjectContext>()
  // public var backgroundContextsDistributedLibrary.allObjects: Array<NSManagedObjectContext> { backgroundContextsDistributedLibrary }

  // var backgroundContextDistributedLibraryNames: [String?] {
  // 	var list: [String?] = []
  // 	for ctx in backgroundContextsDistributedLibrary.allObjects {
  // 		ctx.performAndWait({
  // 			list.append(ctx.name)
  // 		})
  // 	}
  // 	return list
  // }

    #if Disabled
  public lazy var saveContextsPulseHeartbeat =
    AdAstraHeartbeat(interval: 60,
                     beatNoMoreThanInterval: true,
                     startOnAwake: false,
                     pauseWhileBackgrounded: true,
                     beatWhenBackgrounded: true,
                     beatWhenForegrounded: false,
                     name: "SaveContextsPulse") { [weak self] in
      guard let self = self else { return }
      self.pulseSave()
    }
    #endif
    
  // MARK: - Transaction History -

  /// Track the last history token processed for a store, and write its value to file.
  /// The historyQueue reads the token when executing operations, and updates it after processing is complete.

  var lastHistoryToken: NSPersistentHistoryToken? {
    didSet { saveTokenFile() }
  }

  /// The file URL for persisting the persistent history token.
  lazy var tokenFile: URL = buildTokenFile()

  lazy var historyQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.qualityOfService = .userInitiated
    // https://stackoverflow.com/questions/59778113/bug-check-cloudkit-maccatalyst-didreceiveremotenotification
    return queue
  }()

  lazy var historyTransactionContext: NSManagedObjectContext = {
    let context = self.newBackgroundContext(named: "BackgroundContextOfHistoryTransactions")
    return context
  }()



  public enum MyError: Error {
    case IncompatibleModels
    case InvalidMetadata
    case NoDestinationModelFound
    case MissingPath
    case MissingStack
    case MissingStore
  }
  
  
  
  
  
  
  // MARK: - Import/Export -

  open func duplicate(_ objectID: NSManagedObjectID,
                      completionHandler: @escaping (Bool, Error?) -> Void = {_, _ in }
  ){
  }
  
  // Duplicate given project
  open func duplicateProject(_ objectID: NSManagedObjectID, completionHandler: @escaping (Bool, Error?) -> Void = {_, _ in }) { duplicate(objectID, completionHandler: completionHandler) }
  
  /// Called on external sourceStack before it is imported to destinationStack
  open func preImportProcessing() {
    // before importing this stack instance, do these things
  }
  
  /// Called on external destinationStack after successfully exporting from sourceStack
  open func postExportProcessing() {
    // after export, do these things on this exported stack instance
  }
  

}

