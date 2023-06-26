//
//  File.swift
//  
//
//  Created by cms on 1/10/22.
//

import Foundation
import SwiftUI
import AdAstraExtensions
// import CloudKitSyncMonitor
public struct SyncStatusViewSimple: View {
   @available(iOS 14.0, *)
   @ObservedObject var syncMonitor = SyncMonitor.shared
   public init() {}

  public var body: some View {
      // Show sync status
      if #available(iOS 14.0, *) {
         Image(systemName: syncMonitor.syncStateSummary.symbolName)
            .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
      }
   }
}

// import CloudKitSyncMonitor
public struct SyncStatusViewExtended: View {
   var edge: Edge = .bottom
   var historyTotalCount: Int = 30
   var historyVisibleCount: Int = 10
   public init() {}
	open class ReadSizePK: BaseReadSizePreferenceKey { }

   @available(iOS 14.0, *)
   @ObservedObject var syncMonitor = SyncMonitor.shared
   @State var syncStateHistory: [SyncStateCard] = [SyncStateCard]()
   @State var totalScrollViewHeight: CGFloat = 0
   public var body: some View {
      Group{
         ScrollView(showsIndicators: false){
            VStack{
               ForEach (syncStateHistory) {card in
                  HStack{
                     if #available(macOS 12.0, iOS 15, *) {
                        Text(card.timestamp.formatted(date: .omitted, time: .standard))
                           .font(.caption)
                           .foregroundColor(.secondaryLabel)
                           .opacity(0.80)
                        
                     }
                     Text( card.tallies > 1 ? "\(card.tallies)" : "  ")
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)
                        .opacity(0.80)

                     Image(systemName: card.status.symbolName)
                        .foregroundColor(card.status.symbolColor)
                  }
									.readSize(Self.ReadSizePK){
                     totalScrollViewHeight = $0.height * CGFloat(historyVisibleCount)
                  }
               }
            }
         }
         .frame(maxHeight: totalScrollViewHeight)
      }
      .onReceive(SyncMonitor.shared.objectWillChange){
         updateHistory()
      }
   }
   
   struct SyncStateCard: Identifiable {
      var status: SyncMonitor.SyncSummaryStatus
      var id: UUID = UUID()
      var timestamp = Date()
      var tallies: Int = 1
   }
   
   func updateHistory(){
      if syncStateHistory.last?.status != syncMonitor.syncStateSummary {
         if let last = syncStateHistory.last, (last.timestamp + 1) > Date() {
            // last state update was less then a second ago
           
            if syncStateHistory[safeIndex: syncStateHistory.count-2]?.status == syncMonitor.syncStateSummary {
               // matches next-to-last status, simply increase its count
               if var card = syncStateHistory[safeIndex: syncStateHistory.count-2] {
                  card.tallies += 1
                  card.timestamp = Date()
                  syncStateHistory[syncStateHistory.count-2] = card
               }
               
            } else if syncStateHistory[syncStateHistory.count-1].status == syncMonitor.syncStateSummary {
               // matches last status, simply increase its count
               if var card = syncStateHistory[safeIndex: syncStateHistory.count-1] {
                  card.tallies += 1
                  card.timestamp = Date()
                  syncStateHistory[syncStateHistory.count-1] = card
               }
            }

         } else {
            
            syncStateHistory.append(
               SyncStateCard(status: syncMonitor.syncStateSummary)
            )
            syncStateHistory = syncStateHistory.suffix(historyTotalCount)
         }
      }
   }
}

