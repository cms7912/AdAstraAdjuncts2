//
//  File.swift
//  
//
//  Created by cms on 5/2/22.
//

import Foundation
import SwiftUI
import AdAstraBridgingByShim


public struct ClearRepTesting: View {
	public init(){
		
	}
	public var body: some View {
		HStack{
			// StealthViewsController(wrappedView: FrameOne())
			// StealthViewsController(){
			FrameOne()
			// }
		}
	}
}



struct FrameOne: View {
	@State var backgroundOn: Bool = false
	var body: some View {
		ZStack {
			VStack{
				Button(action: {backgroundOn.toggle()}){
					Text("Test Button")
						.background(
							backgroundOn ? Color.systemBlue : Color.systemRed
						)
				}
				.padding(.top, 30)
				
				Text("Tap Gesture")
					.onTapGesture {
						print("tap gesture")
						backgroundOn ? Color.systemBlue : Color.systemRed
					}
				
				Toggle(isOn: $backgroundOn){
          // Label("Toggle", systemSymbol: .ear)
				}
				
				
				
				Spacer()
			}
			
			FrameOneVCR()
		}
	}
}



struct FrameOneVCR: UINSViewControllerRepresentable {
	typealias ViewControllerType = FrameOneVC
	
	func makeViewController(context: Context) -> ViewControllerType {
		return FrameOneVC() }
	func updateViewController(_ viewController: ViewControllerType, context: Context){ }
	
	@objc
	class FrameOneVC: UINSViewController {
		override func loadView() {
			self.view = UINSView()
		}
		@objc func buttonPressed(){
			infoButton.backgroundColor = infoButton.backgroundColor == .clear ? .red : .clear
		}
		lazy var infoButton: UINSButton = {
			let myFirstButton = UINSButton()
			// myFirstButton.setTitle("Info", for: .normal)
			// myFirstButton.setTitleColor(.blue, for: .normal)
			myFirstButton.frame = CGRect(x: 30, y: 100, width: 100, height: 100)
			// myFirstButton.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
			return myFirstButton
		}()
		
		let purpleSubview = UINSView()
		
		override func viewDidLoad() {
			// self.view.isOpaque = false
			self.view.backgroundColor = .clear //systemRed
			
			
			purpleSubview.backgroundColor = .systemPurple
			purpleSubview.addSubview(infoButton)
			
			purpleSubview.willMove(toSuperview: view)
			view.addSubview(purpleSubview)
			purpleSubview.didMoveToSuperview()
			
			let priority: Float = 500
			purpleSubview.translatesAutoresizingMaskIntoConstraints = false
			// subview always needs translatesAutoresizingMaskIntoConstraints turned off.
			// the parent view could need it, but can be set at site of call when needed
			
			let leadingAnchor = purpleSubview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
			leadingAnchor.priority = UINSLayoutPriority(priority)
			leadingAnchor.isActive = true
			
			let trailingAnchor = purpleSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			trailingAnchor.priority = UINSLayoutPriority(priority)
			trailingAnchor.isActive = true
			
			// let topAnchor = subview.topAnchor.constraint(equalTo: view.topAnchor)
			// topAnchor.priority = UINSLayoutPriority(priority)
			// topAnchor.isActive = true
			let heights = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: purpleSubview, attribute: .height, multiplier: 2.0, constant: 0)
			heights.priority = UINSLayoutPriority(priority)
			view.addConstraint(heights)
			heights.isActive = true
			
			
			let bottomAnchor = purpleSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			bottomAnchor.priority = UINSLayoutPriority(priority)
			bottomAnchor.isActive = true
			
			
			
			
		}
		// override func viewDidAppear(_ animated: Bool) {
		// 	super.viewDidAppear(animated)
		override func viewDidAppear() {
			super.viewDidAppear()
			view.stealthKSV_RegisterToEvade(view, ifNotIn: [purpleSubview])
			// self.view.isUserInteractionEnabled = true
			// self.view.backgroundColor = .clear
			// self.view.alpha = 0
			// self.view.isOpaque = false
			// self.view.superview!.isUserInteractionEnabled = false
			// self.view.superview!.isHidden = true
			// self.view.superview!.backgroundColor = .clear
			// self.view.superview!.alpha = 0
			// self.view.superview!.isOpaque = false
			
		}
	}
	
	
	
	
	
	
}
