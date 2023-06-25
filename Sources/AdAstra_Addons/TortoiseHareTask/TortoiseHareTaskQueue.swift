//
//  File.swift
//  
//
//  Created by cms on 1/20/22.
//

import Foundation
// import CoreData

public class TortoiseHareQueueManager {
   enum Mode {
      case tortoise
      case hare
   }
   
   var mode: Mode = .tortoise {
      didSet {
         guard mode != oldValue else { return }
         switch mode {
            case .tortoise:
               queue.maxConcurrentOperationCount = 1
               queue.qualityOfService = .utility
            case .hare:
               queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
               queue.qualityOfService = .default
         }
      }
   }
   
   lazy var queue: OperationQueue = {
      let queue = OperationQueue()
      queue.maxConcurrentOperationCount = 1
      queue.qualityOfService = .utility
      return queue
   }()
   
   
   // public func perform(_ block: @escaping (NSManagedObjectContext) -> Void ){
   //    DispatchQueue.global(qos: .utility).async{
   //       self.newBackgroundContext(named: "PerformBackgroundTaskContext_\(UUID().uuidString)", automaticallyMergesChangesFromParent: false).performWithoutWaiting({ givenContext in
   //          block(givenContext)
   //          try? givenContext.save()
   //          givenContext.refreshAllObjects()
   //       } )
   //    }
   // }

   /// if this approach pattern doesnt work, then try nesting the workBock inside a closure that will call the next workBlock but first checks whether .tortoise/.hare has changed and then sends next call to appropriate queue 
}
