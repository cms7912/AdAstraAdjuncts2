//
//  ProjectsDBStack Contexts  .swift
//  AdAstraAdjuncts
//
//  Created by cms on 11/7/21.
//

import Foundation
import CoreData

// import UIKit
import AdAstraExtensions
//import AdAstraBridgingByShim

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


/*

 Goal of ProjectsDBStack's ManagedObjectsContexts
 -- have a root context in the background that communicates with the persistentStoreCoordinator
 -- have a single viewContext on the main thread that handles UI, connects directly to store
 -- have factory for generating backgroundContexts, all child contexts of rootContext
 -- future implementation: if backgroundContexts are ever nested within each other, then in places 'backgroundContextsDistributedLibrary.allObjects' is referenced, check whether it needs reverse ordered at each reference. This would ensure sub-contexts get saved and then their parent contexts would later.
 */

public class AdAstraNSManagedObjectContext: CoreData.NSManagedObjectContext { }

public extension CoreData.NSManagedObjectContext { }

// extension DispatchQoS: Hashable {
// 	public func hash(into hasher: inout Hasher) {
// 		hasher.combine(self.qosClass)
// 	}
// }
extension DispatchQoS.QoSClass {
  // public func hash(into hasher: inout Hasher) {
  // 	hasher.combine(self.qosClass)
  // }
}

public extension ProjectsDBStack {
  var DebugWithSingleContext: Bool { false }
  // var DebugWithSingleContext: Bool { true }

  // static var _BackgroundContextDictionaryStore: [DispatchQoS.QoSClass : NSManagedObjectContext] = [:]

  /// 🌟 source of background contexts
  func backgroundContext(for qos: DispatchQoS.QoSClass) -> CoreData.NSManagedObjectContext {
    if DebugWithSingleContext { return viewContext }
    // if Self._BackgroundContextDictionaryStore.keys.contains(qos){
    // 	return Self._BackgroundContextDictionaryStore[qos] ?? self.mainBackgroundContext
    // } else {
    // 	llog("backgroundContextFor: \(qos)")
    // 	return DispatchQueue.global(qos: qos).sync{
    // 		self.newBackgroundContext(named: "DBStack_BgCxt_\(qos)")
    // 	}
    // }

    // let cxtName = "DBStack_BgCxt_\(qos)"
    // 	return self.newBackgroundContext(named: cxtName, returnIfExistingName: true)
    switch qos {
      case .utility: return utilityBackgroundContext
      // case .background: return backgroundBackgroundContext
      case .default: return mainBackgroundContext
      case .unspecified: return mainBackgroundContext
      // case .userInitiated: return userInitiatedBackgroundContext
      // case .userInteractive: return userInteractiveBackgroundContext
      @unknown default:
        return mainBackgroundContext
    }
  }


  func newBackgroundContext(named passedName: String? = nil, automaticallyMergesChangesFromParent: Bool = true) -> CoreData.NSManagedObjectContext {
    // if DebugWithSingleContext { return rootBackgroundContext }
    if DebugWithSingleContext { return viewContext }
    // container.newBackgroundContext()
    var name = passedName ?? "ProjectsDBStack_NewContextWithoutName"

    // check if name is unique
    var foundCxt: CoreData.NSManagedObjectContext?
    // if returnIfExistingName {
    // 	for cxt in backgroundContextsDistributedLibrary.allObjects {
    // 		cxt.performAndWait {
    // 			if cxt.name == name {
    // 				foundCxt = cxt
    // 			}
    // 		}
    // 	}
    // }
    // guard foundCxt.isNil else { return foundCxt! }
    // if backgroundContextDistributedLibraryNames.contains(name) {
    // name = name + "_" + UUID().uuidString // need to enforce uniqueness for transaction history that records contextName
    // }

    llog("newBackgroundContext named '\(name)'")
    // newBackgroundContext() associates directly with store coordinator, not a parent context
    // https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640581-newbackgroundcontext

    let newContext = CoreData.NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    newContext.parent = rootBackgroundContext
    // newContext.persistentStoreCoordinator = self.container.persistentStoreCoordinator
    // let newContext = container.newBackgroundContext()
    newContext.name = name // ?? "ProjectsDBStack_NewContextWithoutName"
    newContext.mergePolicy = CoreData.NSMergeByPropertyObjectTrumpMergePolicy
    newContext.automaticallyMergesChangesFromParent = automaticallyMergesChangesFromParent
    // DispatchQueue.main.async { [self] in
    // self.rootBackgroundContext.performWithoutWaiting{ _ in
    backgroundContextsDistributedLibrary.add(newContext as CoreData.NSManagedObjectContext?)
    // }
    // ToDo(.criticalImportance) // turn on .add(newContext) and handle crashes due to read & write access to library simultaneously when many performBackgroundTask() calls are made at once. (e.g. when opening drawer and every snippet needs to create an image)
    return newContext
  }

  func contextsRegisterNotifications() {
      #if os(macOS)
      typealias UINSApplication = NSApplication
      #elseif os(iOS)
      typealias UINSApplication = UIApplication
      #endif
    // /*
    NotificationCenter.default.addObserver(forName: UINSApplication.willTerminateNotification, object: nil, queue: nil) {[weak self] (_) in
      guard let self = self else { return }
      self.saveAllContexts()
    }

    #if os(iOS)

    // NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification , object: nil, queue: nil) { [weak self] (notification) in
    //    self?.saveAllContexts()
    // } // allowing heartbeat to do this automatically

    NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] (_) in
      guard let self = self else { return }
      self.didReceiveMemoryWarning()
    }
    // */
    #endif
  }


  func mergeChangesToAllContexts(fromContextDidSave notification: Notification) {
    // 2021-04-19 - added to handle distributing Ensembles' incoming updates
    // self.viewContext.mergeChanges(fromContextDidSave: notification)
    // backgroundContextsDistributed.forEach {$0?.mergeChanges(fromContextDidSave: notification)}
    backgroundContextsDistributedLibrary.allObjects.forEach {$0.mergeChanges(fromContextDidSave: notification)}
  }

  func mergeChangesToAllContexts(from transactions: [NSPersistentHistoryTransaction]) {
    llog()
    transactions.forEach { transaction in
      guard let userInfo = transaction.objectIDNotification().userInfo else { return }
      // NSManagedObjectContext.mergeChanges(
      // 	fromRemoteContextSave: userInfo,
      // 	into:
      // 		backgroundContextsDistributedLibrary.allObjects + [viewContext, rootBackgroundContext]
      // )
      mergeChangesFromRemoteContextSave(userInfo)
    }
  }

  func mergeChangesFromRemoteContextSave(_ changes: [AnyHashable: Any]) {
    CoreData.NSManagedObjectContext.mergeChanges(
      fromRemoteContextSave: changes,
      into:
      backgroundContextsDistributedLibrary.allObjects + [viewContext, rootBackgroundContext]
    )
  }

  /// frequent periodic saves across all contexts with changes
  func pulseSave() {
    saveAllContexts()
  }

  func saveAllContexts() {
    llog("💾")
      #if Disabled
    saveContextsPulseHeartbeat.scheduleNextBeat() // ensure heartbeat waits full interval from now before beating
      #endif
      
    ([viewContext] + backgroundContextsDistributedLibrary.allObjects.reversed() + [rootBackgroundContext]).forEach{eachContext in
      if eachContext.automaticallyMergesChangesFromParent == true {
        // only pulse save when the context expects merging to happen
        eachContext.perform { [weak eachContext] in
          guard let eachContext = eachContext else { return }
          if eachContext.hasChanges {
            try? eachContext.save()
          }
        }
      }
    }
  }

  func didReceiveMemoryWarning() {
    llog("‼️ memory warning in ProjectsDBStack for: \(Self.ModelPackageName) ‼️")
    saveAndRefreshAllContexts()
  }

  func saveAndRefreshAllContexts() {
    llog()

    viewContext.saveAndRefresh()

    backgroundContextsDistributedLibrary.allObjects.forEach { ctx in
      // guard let cxt = $0 else { return }
      // let ctx = $0
      ctx.saveAndRefresh()
    }
    rootBackgroundContext.saveAndRefresh()
  }
}


// extension AdAstraNSManagedObjectContext {
public extension CoreData.NSManagedObjectContext {
  func saveAndRefresh() {
    saveContextsAndThen{
      // self.refreshAllObjects()
    }
  }

  /// 🌟 performAndWait with context passed in
  func performWhileWaiting(
    _ taskName: String = "Unknown task",
    _ WorkBlock: @escaping (CoreData.NSManagedObjectContext) -> Void
  ) {
    performAndWait {
      [weak self] in
      guard let self = self else { return }
      // [self] in
      let startTime: DispatchTime = .now()
      autoreleasepool{
        WorkBlock(self)
      }
      if self.automaticallyMergesChangesFromParent { self.saveContexts() }
      let endTime: DispatchTime = .now()
      taskRecorder(taskName, startTime)
    }
  }

  /// 🌟 try performAndWait with context passed in
  func performWhileWaiting(
    _ taskName: String = "Unknown task",
    _ WorkBlock: @escaping (CoreData.NSManagedObjectContext) throws -> Void
  ) throws {
    let taskID = UUID()
    let startTime: DispatchTime = .now()

    if #available(macCatalyst 15.0, iOS 15.0, macOS 12, *) {
      try self.performAndWait {
        [weak self] in
        guard let self = self else { return }
        // [self] in
        try autoreleasepool{
          try WorkBlock(self)
        }

        if self.automaticallyMergesChangesFromParent { self.saveContexts() }
      }
    } else {
      // workaround pre-15 .performAndWait not handling throws
      var thrownError: Error?
      performAndWait {
        [weak self] in
        guard let self = self else { return }
        // [self] in

        do {
          try autoreleasepool{
            try WorkBlock(self)
          }

          if self.automaticallyMergesChangesFromParent { self.saveContexts() }
        } catch {
          thrownError = error
        }
      }
      if let error = thrownError {
        throw error
      }
    }
    taskRecorder(taskName, startTime)
  }


  /// 🌟 perform context passed in
  func performWithoutWaiting(
    _ taskName: String = "Unknown task",
    _ WorkBlock: @escaping (CoreData.NSManagedObjectContext) -> Void
  ) {
    perform {
      [weak self] in
      guard let self = self else { return }
      // [self] in
      let startTime: DispatchTime = .now()
      autoreleasepool{
        WorkBlock(self)
      }
      if self.automaticallyMergesChangesFromParent { self.saveContexts() }
      self.taskRecorder(taskName, startTime)
    }
  }


  /// 🌟 Saves context if changes, then saves parent contexts up the lineage
  func saveContexts() {
    guard hasChanges else { return }

    perform {
      [weak self] in
      guard let self = self else { return }
      // [self] in

      try? self.save()
      self.parent?.saveContexts()
    }
  }

  /// 🌟 Saves context if changes, then saves parent contexts up the lineage
  func saveContextsWhileWaiting() {
    guard hasChanges else { return }

    performAndWait {
      [weak self] in
      guard let self = self else { return }
      // [self] in

      try? self.save()
      self.parent?.saveContextsWhileWaiting()
    }
  }

  /// 🌟 Saves context if changes, then saves parent contexts up the lineage, then performs completion handler
  func saveContextsAndThen(completionHandler: @escaping (() -> Void) = { }) {
    perform {
      [weak self] in
      guard let self = self else { return }
      // [self] in

      self.saveContextsWhileWaiting()
      completionHandler()
    }
  }


  func taskRecorder(_ taskName: String, _ startTime: DispatchTime) {
    #if DEBUG
    // let endTime: DispatchTime = .now()
    Task{
      await Self.TaskListManager.shared.record("\(self.name ?? "-")|\(taskName)-\(self.name ?? "")", startTime: startTime, endTime: .now(), objectCount: self.registeredObjects.count)
    }

    #endif
  }
    
    func object(withObjectIDAsURIString objectIDAsURIString: String) -> NSManagedObject? {
        guard let objectURI = URL(string: objectIDAsURIString),
              let objectID = persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectURI) else { return nil }
        return self.object(with: objectID)
    }
}


public extension ProjectsDBStack {
  /// performs task on ephemeral background context without waiting
  func performNewBackgroundTask(_ qos: DispatchQoS.QoSClass = .default, _ named: String = "NewBGTask", _ block: @escaping (CoreData.NSManagedObjectContext) -> Void) {
    // self.container.performBackgroundTask(block)
    if DebugWithSingleContext { viewContext.performWithoutWaiting(named, block); return }

    // DispatchQueue.global(qos: qos).async{
    // let destContext: NSManagedObjectContext?
    // if qos == .background {
    // 	destContext = self.backgroundContext(for: .background)
    // } else {
    // 	destContext = self.newBackgroundContext(named: "PerformNewBackgroundTaskContext_\(named ?? UUID().uuidString)", automaticallyMergesChangesFromParent: false)
    // }

    let destContext = backgroundContext(for: qos)

    destContext.performWithoutWaiting(named) { givenContext in
      block(givenContext)
      givenContext.saveAndRefresh()
    }
    // }
  }

  func performNewBackgroundTaskWhileWaiting(_ named: String = "NewBGWTask", _ block: @escaping (CoreData.NSManagedObjectContext) throws -> Void) throws {
    if DebugWithSingleContext { try viewContext.performWhileWaiting(named, block); return }
    try autoreleasepool {
      let newContext = self.newBackgroundContext(named: "PerformBackgroundTaskWhileWaitingContext", automaticallyMergesChangesFromParent: false)
      try newContext.performWhileWaiting(named, block)
      newContext.saveAndRefresh()
    }
  }
}


public extension CoreData.NSManagedObjectContext {
  class TaskMetadata: ObservableObject {
    internal init(name: String,
                  uniqueID: UUID,
                  start: DispatchTime,
                  end: DispatchTime? = nil,
                  objectCount: Int = -1)
    {
      self.name = name
      self.uniqueID = uniqueID
      self.start = start
      self.end = end
      self.objectCount = objectCount
    }

    public var name: String
    public var uniqueID: UUID
    @Published var start: DispatchTime
    @Published public var end: DispatchTime?
    public var objectCount: Int

    public var duration: Double {
      (
        start.distance(to: (end ?? .now())).toDouble()!
      )
        / DispatchTimeInterval.seconds(1).toDouble()!
    }
    // mutating func stop(){
    // 	self.end = .now()
    // }
  }

  @MainActor
  class TaskListManager: ObservableObject {
    public static var shared = TaskListManager()
    @Published public var PerformOnContextList: [TaskMetadata] = []

    func start(_ name: String, _ uniqueID: UUID = UUID()) {
      if let index = PerformOnContextList.firstIndex(where: { $0.uniqueID == uniqueID }) {
        // task already exists
        var task = PerformOnContextList[index]
        task.name = name
        task.start = .now()
        if abs(task.duration) < 1 {
          PerformOnContextList.remove(at: index)
        }
        return
      }


      let newTask = TaskMetadata(name: name,
                                 uniqueID: uniqueID,
                                 start: .now(),
                                 // end: nil)
                                 end: .now() + .seconds(123))
      PerformOnContextList.append(newTask)
    }

    func stop(_ uniqueID: UUID) {
      // PerformOnContextList = PerformOnContextList.map{
      // 	// $0.stop()
      // 	// $0.end = .now()
      // 	if $0.uniqueID==uniqueID {
      // 		var updatedTask = $0
      // 		updatedTask.end = .now()
      // 		// if updatedTask.duration >= 1 {
      // 		return updatedTask
      // 		// }
      // 		// return nil
      // 	}
      // 	return $0
      // }

      if let index = PerformOnContextList.firstIndex(where: { $0.uniqueID == uniqueID }) {
        var task = PerformOnContextList[index]
        task.end = .now()
        // PerformOnContextList[index] = task
        llog("Task ended: \(task.duration)")

        if abs(task.duration) < 1 {
          PerformOnContextList.remove(at: index)
        }

        return
      }
      llog("failed to find task")
      let newTask = TaskMetadata(name: "end-only task",
                                 uniqueID: uniqueID,
                                 start: .now() - .seconds(456),
                                 end: .now())
      PerformOnContextList.append(newTask)
    }

    func record(_ name: String, startTime: DispatchTime, endTime: DispatchTime, objectCount: Int) {
      let newTask = TaskMetadata(name: name,
                                 uniqueID: UUID(),
                                 start: startTime,
                                 end: endTime,
                                 objectCount: objectCount)
      if abs(newTask.duration) < 1 { return }
      PerformOnContextList.append(newTask)
    }
  }

  var isMainThread: Bool { Thread.isMainThread }

  func runOnViewContext(block: @escaping (NSManagedObjectContext) -> Void) {
    if self === ProjectsDBStack.shared?.viewContext {
      block(self)
    } else if ProjectsDBStack.shared?.viewContext.persistentStoreCoordinator === persistentStoreCoordinator {
      ProjectsDBStack.shared?.viewContext.performWithoutWaiting{context in
        block(context)
      }
    } else {
      assertionFailure()
      performWithoutWaiting{context in
        block(context)
      }
    }
  }
}
