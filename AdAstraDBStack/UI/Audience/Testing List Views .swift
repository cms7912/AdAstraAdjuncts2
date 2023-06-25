//
//  File.swift
//  
//
//  Created by cms on 1/11/22.
//

import Foundation
import SwiftUI

public struct AudienceMembersListView: View {
   // @FetchRequest(entity: AudienceMember.entity(),
   //               sortDescriptors: [NSSortDescriptor(keyPath: \AudienceMember.lastObservationTimestamp, ascending: false)],
   //               predicate: nil,
   //               animation: .default
   // ) var audienceMembers: FetchedResults<AudienceMember>
   
   @FetchRequest var audienceMembers: FetchedResults<AttendeeEntityProtocol>
   public init(){
      _audienceMembers = FetchRequest<AttendeeEntityProtocol>(
         // entity: AudienceMember.entity(),
         entity: ProjectsDBStack.shared!.modernManagedObjectModel.entitiesByName["Audience_Attendee"]!,
         sortDescriptors: [NSSortDescriptor(keyPath: \AttendeeEntityProtocol.lastObservationTimestamp, ascending: false)],
         predicate: nil, animation: .default )
   
   }
   
   public var body: some View {
      Text("Audience:")
      List(audienceMembers, id: \.objectID){ member in
         Text("\(member.debugDescription)")
            .padding([.top, .bottom])
      }
   }
}

public struct GuestbookEntriesListView: View {
   @FetchRequest public var entries: FetchedResults<GuestbookEntryEntityProtocol>
   
   public init(){
      _entries = FetchRequest<GuestbookEntryEntityProtocol>(
         // entity: AudienceGuestbookEntry.entity(),
         entity: ProjectsDBStack.shared!.modernManagedObjectModel.entitiesByName["Audience_GuestbookEntry"]!,
         sortDescriptors: [NSSortDescriptor(keyPath: \GuestbookEntryEntityProtocol.mostRecentAccessTimestamp, ascending: false)],
         predicate: nil, animation: .default )
      
   }
   public var body: some View {
      Text("Guestbook:")
      List(entries, id: \.objectID){ entry in
         Text("\(entry.debugDescription)")
            .padding([.top, .bottom])
      }
   }
}

