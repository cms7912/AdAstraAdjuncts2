//
//  File.swift
//
//
//  Created by cms on 1/4/22.
//

import Foundation

// import CoreData
import CoreData
import AdAstraExtensions


open class AdAstraNSManagedObject: NSManagedObject {
  @available(*, unavailable)
  public init() {
    fatalError()
  }

  @available(*, unavailable)
  public init(context _: NSManagedObjectContext) {
    fatalError()
  }

  public convenience init(into context: NSManagedObjectContext) {
    let name = String(describing: type(of: self))
    let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
    self.init(entity: entity, insertInto: context)
  }

  override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
    super.init(entity: entity, insertInto: context)
  }

  // unwrapped self.managedObjectContext (crash on fail)
  private weak var _contextStore: NSManagedObjectContext?
  /* = {
   CrashDuringDebug🛑("This should never be reached, setContext() should always replace this initial value before its called")
   return NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
   }()
   */
  open var context: NSManagedObjectContext {
    setContext()
    #if DEBUG
    guard managedObjectContext.isNotNil else {
      fatalError("Unexpectedly self.managedObjectContext is nil: \(debugDescription)") }
    guard managedObjectContext == _contextStore else {
      fatalError("Unexpectedly did not match self.managedObjectContext for: \(debugDescription)") }
    #endif
    guard let _cxt = _contextStore else {
//      CrashDuringDebug🛑("This should never be reached, setContext() should always replace this initial value before its called")
        assertionFailure()
      return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
    return _cxt
  }

  func setContext() {
    if _contextStore.isNotNil { return }
    guard let cxt = managedObjectContext as? NSManagedObjectContext else {
      llog("missing object context for \(debugDescription)")
//      crashAfterUserAlert("Unexpected missing object context")
        assertionFailure(); fatalError()
    }
    _contextStore = cxt
  }


  public class var entityName: String! {
    return entity().managedObjectClassName.components(separatedBy: ["."]).last!
  }


  var inMemoryDictionaryStore: [String: Any?] = [:]



  public static var UpdateValuesOnlyWhenModified: Bool = false // default Core Data behavior is false

  // public override func setValue<T>(_ newValue: T?, forKey key: String) {
  override open func setValue(_ newValue: Any?, forKey key: String) {
    if Self.UpdateValuesOnlyWhenModified {
      setValueIfModified(newValue, forKey: key)
      return
    }
    super.setValue(newValue, forKey: key)
  }

  public func setValueIfModified(_ newValue: Any?, forKey key: String, completionHandler: () -> Void = { }) {
    _setValueIfModified(newValue, forKey: key, completionHandler: completionHandler)
  }

  func setValueIfModified<T: Equatable>(_ newValue: T?, forKey key: String, _ completionHandler: () -> Void = { }) {
    _setValueIfModified(newValue, forKey: key, completionHandler)
  }

  override public func willChangeValue(forKey key: String) {
    super.willChangeValue(forKey: key)
    // self.objectWillChange.send() // on macOS this is creating an error:
    // 'NSInternalInconsistencyException', reason: 'Cannot set BindableObject publisher after it has already been set'
  }

  override open func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)
    // self.objectWillChange.send() // on macOS this is creating an error:
    // 'NSInternalInconsistencyException', reason: 'Cannot set BindableObject publisher after it has already been set'
  }


  public class func aaFetchRequest<Result: NSFetchRequestResult>() -> NSFetchRequest<Result> {
    var entityName = ""
    if let name = Self.entity().name {
      entityName = name
    } else {
//      CrashDuringDebug🛑("default entity name was unexpectedly nil")
        assertionFailure()
    }
    let request = NSFetchRequest<Result>(entityName: entityName)
    request.sortDescriptors = []

    // attempt to find any of these default sort descriptors among entity's attributes. These should be replaced when needing to define the sort order
    // (request will fail when fetched if no sortDescriptors added)
    for testKey in ["modifiedTimestamp", "createdTimestamp", "id", Self.entity().attributesByName.keys.sorted().first.asEmptyIfNil] {
      if Self.entity().attributesByName.keys.contains(testKey) {
        request.sortDescriptors = [NSSortDescriptor(key: testKey, ascending: true)]
        break
      }
    }

    return request
  }

  open func performOnBackgroundContext<M: AnyObject>(
    whileWaiting: Bool = false,
    _ taskName: String, // = "Unknown task",
    _ qos: DispatchQoS.QoSClass = .utility,
    _ block: @escaping (NSManagedObjectContext, M) -> Void
  ) {
    let id = objectID

    guard let chosenContext = ProjectsDBStack.shared?.backgroundContext(for: qos) else {
//      CrashDuringDebug🛑("Failed to have expected context")
        assertionFailure()
      return
    }

    if whileWaiting.isOff {
      chosenContext.performWithoutWaiting(taskName) { context in
        guard let myself = context.object(with: id) as? M else {
          assertionFailure(); return
        }
        autoreleasepool{
          block(context, myself)
        }
      }
    } else {
      chosenContext.performWhileWaiting(taskName) { context in
        guard let myself = context.object(with: id) as? M else {
          assertionFailure(); return
        }
        autoreleasepool{
          block(context, myself)
        }
      }
    }
  }

  open func performNewBackgroundTask<M: AnyObject>(
    _ qos: DispatchQoS.QoSClass = .default,
    _: String,
    _ block: @escaping (NSManagedObjectContext, M) -> Void
  ) {
    let id = objectID

    ProjectsDBStack.shared?.performNewBackgroundTask(qos) { context in
      // ProjectsDBStack.shared?.mainBackgroundContext.performWithoutWaiting{ context in
      guard let myself = context.object(with: id) as? M else {
        assertionFailure(); return
      }
      autoreleasepool{
        block(context, myself)
      }
    }
  }

  open class func NewObject(in newContext: NSManagedObjectContext) -> Self {
    let newObject: Self = NSEntityDescription.insertNewObject(forEntityName: entityName, into: newContext) as! Self
    return newObject
  }
}


// Default createdTimestamp, ModifiedTimestamp
extension AdAstraNSManagedObject {
  override open func awakeFromInsert() {
    super.awakeFromInsert()
    setContext()
    if containsKey("id") {
      setPrimitiveValue(UUID(), forKey: "id")
    }
    if containsKey("createdTimestamp") {
      setPrimitiveValue(Date(), forKey: "createdTimestamp")
    }
  }

  override open func awakeFromFetch() {
    super.awakeFromFetch()
    setContext()
  }

  override open func willSave() {
    super.willSave()
    if containsKey("modifiedTimestamp") {
      guard let modifiedTimestamp: Date = getter(for: "modifiedTimestamp") else {
        setter(for: "modifiedTimestamp", to: Date())
        return
      }
      if modifiedTimestamp.timeIntervalSince(Date()) > 10.0 {
        setter(for: "modifiedTimestamp", to: Date())
      }
    }
  }

  public var primitiveSortOrder: Double {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
    fetchRequest.entity = entity
    let count = Double((try? managedObjectContext?.count(for: fetchRequest)) ?? 0)
    return count
  }




  var tombstone: Bool {
    if containsKey("tombstoneTimestamp") {
      return (getter(for: "tombstoneTimestamp") as Date?).isNotNil
    }
    return false
  }

  public func deleteWithTombstone() {
    if containsKey("tombstoneTimestamp") {
      setter(for: "tombstoneTimestamp", to: Date())
      return
    }
//    Self.CrashAfterUserAlert("unexpectedly tried to set a tombstone on entity without tombstone")
      assertionFailure(); fatalError()
  }

  func undeleteWithTombstone() {
    if containsKey("tombstoneTimestamp") {
      setter(for: "tombstoneTimestamp", to: Date?.self)
      return
    }
//    Self.CrashAfterUserAlert("unexpectedly tried to set a tombstone on entity without tombstone")
      assertionFailure(); fatalError()
  }

  public func delete() {
    managedObjectContext?.perform{
      self.managedObjectContext?.delete(self)
    }
  }
}



#if Disabled
// Handle Metadata Dictionary
public extension AdAstraNSManagedObject {
  enum MetadataKeys: String {
    case v1UIColorSaved
    case test2
  }

  var metadata: [String: QuantumValue] {
    get {
      let data = (value(forKey: "metadataDictionary") as? Data) ?? Data()
      if let quantumData = try? data.jsonTo([String: QuantumValue].self) {
        // let unpackedMetadata: [String: QuantumValue] = quantumData.mapValues{ $0 }
        // return unpackedMetadata
        return quantumData
      } else {
//        CrashDuringDebug🛑()
          assertionFailure()
        return [String: QuantumValue]()
      }
    }
    set {
      // let quantumData = newValue.mapValues{ QuantumValue($0) }
      // self.setValue(quantumData.asJSON, forKey: "metadataDictionary")

      try? setValueIfModified(Self.MetadataToBinaryData(newValue), forKey: "metadataDictionary")
    }
  }



  static func MetadataToBinaryData(_ metadata: [String: QuantumValue]) throws -> Data {
    // (metadata.mapValues{ QuantumValue($0) }).asJSON
    // let quantumData = metadata.mapValues{ QuantumValue($0) }
    // return try quantumData.asJSON.data
    return try metadata.asJSON.data
    // return nil
  }
}
#endif



// Object creation & identification

public extension AdAstraNSManagedObject {
  var defaultID: String {
    var idValue: String?
//    if entity.uinsAttributesByName.keys.contains("id") {
    if entity.attributesByName.keys.contains("id") {
      idValue = value(forKey: "id") as? String
    }
    return idValue ?? objectIDAsURIString
  }

  var objectIDAsURIString: String {
    if objectID.isTemporaryID {
      try? context.obtainPermanentIDs(for: [self])
    }
    return objectID.uriRepresentation().absoluteString
  }
}


// Key & Value - Getters & Setters
extension AdAstraNSManagedObject {
  func getter<Content>(for key: String) -> Content? {
    willAccessValue(forKey: key)
    defer { didAccessValue(forKey: key) }
    return primitiveValue(forKey: key) as? Content
  }

  func setter<Content>(for key: String, to newValue: Content?) {
    willChangeValue(forKey: key)
    defer { didChangeValue(forKey: key) }

    guard let value = newValue else {
      setPrimitiveValue(nil, forKey: key)
      return
    }
    setPrimitiveValue(value, forKey: key)
  }

  // lazy var allAttributeNames: [String] = self.entity.attributesByName.enumerated().map { $0.element.key }

  func containsKey(_ key: String) -> Bool {
    return entity.attributesByName.keys.contains(key)
  }


  func _setValueIfModified(_ newValue: Any?, forKey key: String, completionHandler: () -> Void = { }) {
    if newValue.isNil && primitiveValue(forKey: key).isNil {
      return
    }

    if let valueType = entity.attributesByName[key]?.type {
      switch valueType {
        case .boolean:
          setValueIfModified(newValue as? Bool, forKey: key, completionHandler)
        case .date:
          setValueIfModified(newValue as? Date, forKey: key, completionHandler)
        case .string:
          setValueIfModified(newValue as? String, forKey: key, completionHandler)
        case .date:
          setValueIfModified(newValue as? Date, forKey: key, completionHandler)
        case .binaryData:
          setValueIfModified(newValue as? Data, forKey: key, completionHandler)
        case .double:
          setValueIfModified(newValue as? Double, forKey: key, completionHandler)
        case .uuid:
          setValueIfModified(newValue as? UUID, forKey: key, completionHandler)
        case .integer64:
          setValueIfModified(newValue as? Int64, forKey: key, completionHandler)
        default:
          fatalError()
      }
    } else {
      fatalError()
    }
  }

  func _setValueIfModified<T: Equatable>(_ newValue: T?, forKey key: String, _ completionHandler: () -> Void = { }) {
    if let oldValue = primitiveValue(forKey: key) as? T {
      guard oldValue != newValue else { return }
      super.setValue(newValue, forKey: key)
      completionHandler()
      return
    } else if newValue.isNil {
      return
    }
    fatalError()
  }
}



// Contexts

extension AdAstraNSManagedObject { }

public extension NSManagedObject {
  /// base NSManagedObject init
  //  public convenience init(into context: NSManagedObjectContext) {
  //   let name = String(describing: type(of: self))
  //   let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
  //   self.init(entity: entity, insertInto: context)
  //   // https://stackoverflow.com/questions/51851485/multiple-nsentitydescriptions-claim-nsmanagedobject-subclass
  // }
}

extension NSManagedObject {
  // public static func entityName() -> String {
  // 	//		return String(`self`)
  // 	return String(describing: self)
  // }
}


public extension NSManagedObject {
  func saveAndRefresh() {
    if hasChanges {
      try? managedObjectContext?.save()
    }
    managedObjectContext?.refresh(self, mergeChanges: false) // mergeChanges=false will return object to a fault and no memory footprint.
  }

  private func _saveAndRefreshAllRelated() {
    // first, refresh self
    saveAndRefresh()

    // Next, find all related objects
    let allRelationshipNames = entity.relationshipsByName.keys
    for relationName in allRelationshipNames {
      if hasFault(forRelationshipNamed: relationName).isFalse {
        // not a fault, therefore has data:

        // Then on every related object call for them to refresh
        let allObjectIDs = objectIDs(forRelationshipNamed: relationName)
        for objectID in allObjectIDs{
          let object = managedObjectContext?.object(with: objectID)
          if object?.isFault.isFalse ?? false {
            // not a fault, therefore has data:
            object?._saveAndRefreshAllRelated()
          }
        }
      }
    }
  }

  func saveAndRefreshAllRelated() {
    managedObjectContext?.perform {
      self._saveAndRefreshAllRelated()
    }
  }



  func performWithoutWaiting<Self>(
    _: DispatchQoS.QoSClass = .default,
    _ named: String,
    _ block: @escaping (NSManagedObjectContext, Self) -> Void
  ) {
    let id = objectID

    managedObjectContext?.performWithoutWaiting(named) {context in
      guard let myself = context.object(with: id) as? Self else { assertionFailure(); return }
      block(context, myself)
    }
  }

  func runOnViewContext(block: @escaping (NSManagedObjectContext, Self) -> Void) {
    managedObjectContext?.runOnViewContext{ context in
      if let myself = context.object(with: self.objectID) as? Self {
        block(context, myself)
      } else {
        assertionFailure()
      }
    }
  }
}
