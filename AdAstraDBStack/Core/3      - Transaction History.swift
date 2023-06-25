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

/**
 Handle remote store change notifications (.NSPersistentStoreRemoteChange).
 */
extension Notification.Name {
	static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
}
extension ProjectsDBStack {
   
   func buildTokenFile() -> URL {
      
      let url = projectDBFolder.appendingPathComponent("CoreDataTransactionHistory", isDirectory: true)
      if !FileManager.default.fileExists(atPath: url.path) {
         do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
         } catch {
            print("###\(#function): Failed to create persistent container URL. Error = \(error)")
         }
      }
      return url.appendingPathComponent("token.data", isDirectory: false)
   }
   
   func saveTokenFile() {
      guard let token = lastHistoryToken,
            let data = try? NSKeyedArchiver.archivedData( withRootObject: token, requiringSecureCoding: true) else { return }
      
      do {
         try data.write(to: tokenFile)
      } catch {
         print("###\(#function): Failed to write token data. Error = \(error)")
      }
      
   }
   
   @objc
   func storeRemoteChange(_ notification: Notification) {
      
      llog("👇 ")
      rootBackgroundContext.performWithoutWaiting{ ctx in
         ctx.mergeChanges(fromContextDidSave: notification)
         ctx.saveContexts()
      }
      return;
      // llog("\(notification)")
      // Process persistent history to merge changes from other coordinators.
      historyQueue.addOperation {
         self.processPersistentHistory()
      }
   }
   
   
   /**
    Process persistent history, posting any relevant transactions to the current view.
    */
   func processPersistentHistory() {
      llog()
      // let taskContext = container.newBackgroundContext()
      historyTransactionContext.performAndWait {
         
         // Fetch history received from outside the app since the last token
         // let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
         // historyFetchRequest.predicate = NSPredicate(format: "author != %@", AppTransactionAuthorName)
         let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
         // request.fetchRequest = historyFetchRequest
         
        let result = (try? historyTransactionContext.execute(fetchHistoryRequest)) as? NSPersistentHistoryResult
         guard let transactions = result?.result as? [NSPersistentHistoryTransaction],
               transactions.isNotEmpty
         else { return }
         
         transactions.forEach { transaction in
            // guard let userInfo = transaction.objectIDNotification().userInfo else { return }
            // let viewContext = self.container.viewContext
            // NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [context])
            // NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [self.viewContext])
            llog("✍️ logged one transaction")
            // Self.shared?.rootBackgroundContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            historyTransactionContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            
         }
         historyTransactionContext.saveContexts()
         // historyTransactionContext.saveContexts()
         // Update the history token using the last transaction.
         lastHistoryToken = transactions.last!.token
      }
   }
   
}
