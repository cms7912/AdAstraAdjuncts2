//
//  File.swift
//  
//
//  Created by cms on 12/16/22.
//

import SwiftUI

public struct WaitingOnTypingAnimation: View {
	public init () { }
	
	@State private var moveDot: CGFloat = 0
	@State var duration: Double = 0.45

	var animatableData: Double {
		get { moveDot }
		set {
			moveDot = newValue
		}
	}

	public var body: some View {

		HStack {
			ForEach(0..<3){ i in
				Circle()
					.frame(width: 6, height: 6, alignment: .center)
					.foregroundColor(.secondary ) //Color(#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)))
					.offset(y: moveDot)
				// .animation(Animation.easeInOut(duration: 0.35).speed(0.75) .repeatForever( autoreverses: true).delay(Double(i) * 0.09), value: moveDot)
				// .animation(Animation.interpolatingSpring(mass:  1 , stiffness: 0.46, damping: 0.1, initialVelocity: 0.2).speed(5) .repeatForever( autoreverses: true).delay(Double(i) * 0.09), value: moveDot)
					.animation(Animation.easeIn(duration: 0.35) .repeatForever( autoreverses: true).delay(Double(i) * (0.5/3)), value: moveDot)
				// .animation(Animation.easeIn(duration: duration).delay(Double(i) * (duration/3)), value: moveDot)
			}
		}
		.frame(height: 50)
		.offset(x: 0, y: 0)
		// .border(Color.orange)
		.onAppear {
			// print("yes")
			moveDot = -6
			// repeatingDots()
		}
		// .onChange(moveDot){
		// 	if moveDot == -10 || moveDot == 0 {
		// 		// repeatingDots()
		// 	}
		// }
	}

	func repeatingDots() {
		_ = Task.delayedBy(1){
			moveDot = moveDot==0 ? -10 : 0
			// repeatingDots()
		}
	}
}
