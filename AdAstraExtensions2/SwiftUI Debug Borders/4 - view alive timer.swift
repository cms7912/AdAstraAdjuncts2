//
//  File.swift
//  
//
//  Created by Clint Ramirez Stephens  on 10/18/23.
//

import Foundation
import SwiftUI

struct DebugAliveTimer: ViewModifier {
  //  @State var value: ValueType
  //  @Binding var value: ValueType
  //  @StateObject var reference: ClassObservableObject
  //  @EnvironmentObject var reference: ClassObservableObject
  //  @Environment(\.managedObjectContext) var viewContext
  public init() { }
  
  
  @ViewBuilder
  func body(content: Content) -> some View {
#if DEBUG
      content
        .overlay(alignment: .top){
          DebugTimerCapsule()
        }
#else
    content
#endif
  }
}

public struct DebugTimerCapsule: View {
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var timeElapsed = 0
  @State private var timeDisplayed: String = "0 seconds"
  public init() { }
  
  public var body: some View {
    Text("\(timeDisplayed)")
      .font(.caption2)
      .foregroundColor(.primary)
      .padding(.horizontal, 20)
      .padding(.vertical, 5)
      .background(.background.opacity(0.75))
      .clipShape(Capsule())
    
      .onReceive(timer) { _ in
        timeElapsed += 1
        if timeElapsed < 60 {
          timeDisplayed = "\(timeElapsed) s"
        } else {
          let minutesElapsed = timeElapsed.quotientAndRemainder(dividingBy: 60).quotient
          timeDisplayed = "\(minutesElapsed) m"
        }
      }
    
  }
}


public extension View {
  func addAliveTimer() -> some View {
    Group{
        self.modifier(DebugAliveTimer())
    }
  }
}
