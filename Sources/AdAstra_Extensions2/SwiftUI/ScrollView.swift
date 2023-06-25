// //
// //  TrackingScrollView
// //  Created by cms on 2021-12-23
// //
// 
// import Foundation
// import SwiftUI
// // import UIKit
// #if canImport(AdAstraBridgingByMask)
// import AdAstraBridgingByMask
// import AdAstraBridgingNSExtensions
// #endif
// 
// struct TrackingScrollView<Content: View>: UIViewControllerRepresentable {
// 
//     typealias UIViewControllerType = TrackingScrollViewContentWrapper<Content>
//     typealias NSViewControllerType = TrackingScrollViewContentWrapper<Content>
// 
//     var wrappedView: () -> Content
// 
//     func makeUIViewController(context: Context) -> TrackingScrollViewContentWrapper<Content> {
//         let uiViewController = TrackingScrollViewContentWrapper<Content>(wrappedView: wrappedView, context.coordinator)
//         uiViewController.updateContentSize()
//         return uiViewController
//     }
//     func makeNSViewController(context: Context) -> TrackingScrollViewContentWrapper<Content> {
//         self.makeUIViewController(context: context)
//     }
// 
//     func updateUIViewController(_ uiViewController: TrackingScrollViewContentWrapper<Content>, context: Context) {
//         uiViewController.updateContentSize()
//     }
//     func updateNSViewController(_ uiViewController: TrackingScrollViewContentWrapper<Content>, context: Context) {
//         self.updateUIViewController(uiViewController, context: context)
//     }
// 
//     func makeCoordinator() -> TrackingScrollViewRepresentableCoordinator<Content> {
//         Coordinator(parentRepresentable: self)
//     }
// }
// class TrackingScrollViewRepresentableCoordinator<Content: View>: NSObject {
//     var parentRepresentable: TrackingScrollView<Content>
//     init(parentRepresentable: TrackingScrollView<Content>) {
//         self.parentRepresentable = parentRepresentable
//     }
// }
// 
// 
// 
// class TrackingScrollViewContentWrapper<Content: View>: UIViewController, ObservableObject {
// 
//     var wrappedView: () -> Content
//     var coordinator: TrackingScrollViewRepresentableCoordinator<Content>
//     init(
// 
//         // @ViewBuilder
//         wrappedView: @escaping () -> Content, _ coordinator: TrackingScrollViewRepresentableCoordinator<Content>){
//             self.wrappedView = wrappedView
//             self.coordinator = coordinator
//             // self.coordinator = coordinator
//             super.init(nibName: nil, bundle: nil)
//         }
// 
//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }
// 
//     lazy var contentHostingViewController: UIHostingController = {
//         UIHostingController(
//             rootView:
//                 // CardStackAccumulator(dataPackage: dataPackage, wrapper: self)
//             // .fixedSize()
//             // self.coordinator.parentRepresentable.wrappedView
//             wrappedView()
//             // .border(Color.red, width: 3)
//         )
//     }()
// 
//     // weak var coordinator: ControllerRepresentable.Coordinator?
// 
//     override func viewDidLoad() {
//         super.viewDidLoad()
// 
//         addChild(contentHostingViewController)
//         view.addSubviewWithAnchorConstraints(contentHostingViewController.view)
//         contentHostingViewController.didMove(toParent: self)
//         updateContentSize()
// 
//         // contentViewController.view.sizeToFit()
//         // preferredContentSize = contentViewController.view.bounds.size
// 
//         // view.layer.borderColor = UIColor.purple.cgColor
//         // view.layer.borderWidth = 1
// 
//         // contentHostingViewController.preferredContentSize.height = UIScreen.main.bounds.height/3
//         // self.preferredContentSize.height = UIScreen.main.bounds.height/3
// 
//         // contentHostingViewController.view.layer.borderColor = UIColor.green.cgColor
//         // contentHostingViewController.view.layer.borderWidth = 2
//     }
// 
//     func updateContentSize(to newHeight: CGFloat? = nil) {
//         return
//         // view.sizeToFit()
//             
//             contentHostingViewController.view.sizeToFit()
// 
//         // contentViewController.preferredContentSize = contentViewController.view.bounds.size
//         // preferredContentSize = view.bounds.size
//         // print (preferredContentSize)
// 
//         // view.setNeedsLayout()
//         // let fittingSize = CGSize(width: UIView.layoutFittingExpandedSize.width, height: UIView.layoutFittingExpandedSize.height)
// 
//         // let fittingSize = CGSize(width: UIView.layoutFittingExpandedSize.width, height: UIView.layoutFittingExpandedSize.height)
// 
//         // contentHostingViewController.preferredContentSize = contentHostingViewController.sizeThatFits(in: fittingSize)
//         // preferredContentSize = contentHostingViewController.sizeThatFits(in: fittingSize)
// 
//         // preferredContentSize = view.sizeThatFits(in: fittingSize)
//         // contentHostingViewController.preferredContentSize = contentHostingViewController.view.sizeThatFits(in: fittingSize)
// 
//         // self.view.bounds.size = fittingSize
// 
//         contentHostingViewController.preferredContentSize = contentHostingViewController.view.frame.size
//         self.preferredContentSize = contentHostingViewController.view.frame.size
// 
// 
//     }
// }
// 
// 
