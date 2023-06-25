//
//  File 2.swift
//  
//
//  Created by cms on 1/10/22.
//

import Foundation
// import CoreData
import AdAstraExtensions
import os.log

public class RemoteNotificationsMonitor: ObservableObject {
   static var shared: RemoteNotificationsMonitor = RemoteNotificationsMonitor()
   
   struct LogCard: Identifiable {
      var id: UUID = UUID()
      var text: String
      var timestamp: Date = Date()
   }
   
   @Published
   var logHistory: [LogCard] = [LogCard]()
   
   
   public static func llog(_ text: String){ Self.shared.llog(text) }
   public func llog(_ text: String){
      logHistory.append(
         LogCard(text: text)
      )
      LLog(text)
   }
   
}
