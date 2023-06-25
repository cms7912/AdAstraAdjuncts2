// //
// //  Document Picker.swift
// //  Caleo
// //
// //  Created by cms on 4/30/21.
// //  Copyright © 2021 CMS. All rights reserved.
// //
// 
// import Foundation
// import SwiftUI
// 
// 
// #if os(iOS)
// 
// public struct DocumentPickerUI: View {
//     @State var documentTypes: [String]
//     @State var completionHandler: (([URL]) -> Void)
//     
//     var picker = DocumentPickerForiOS(
//             documentTypes: documentTypes,
//             completionHandler: completionHandler )
//     
//     
//     public init(documentTypes: [String], completionHandler: @escaping ([URL]) -> Void = {_ in } ) {
//         self.documentTypes = documentTypes
//         self.completionHandler = completionHandler
//     }
//     
//     public var body: some View {
//         VStack {
//             self.picker
//         }
//         .onAppear {
//         }
//     }
//     // adapted from: https://developer.apple.com/forums/thread/127756
// }
// 
// 
// 
// 
// final class DocumentPickerForiOS: NSObject, UIViewControllerRepresentable, UIDocumentPickerDelegate {
// 
// 	var documentTypes: [String]
// 	var completionHandler: (([URL]) -> Void)
// 
// 	init(documentTypes: [String],
// 		 completionHandler:  @escaping (([URL]) -> Void)
// 	) {
// 		self.documentTypes = documentTypes
// 		self.completionHandler = completionHandler
// 	}
// 
// 	typealias UIViewControllerType = UIDocumentPickerViewController
// 	lazy var viewController: UIDocumentPickerViewController = {
// 
// 		let vc = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
// 		vc.allowsMultipleSelection = true
// 		vc.delegate = self
// 		return vc
// 	}()
// 	func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPickerForiOS>) -> UIDocumentPickerViewController {
// 		viewController.delegate = self
// 		return viewController
// 	}
// 	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerForiOS>) {
// 	}
// 
// 	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
// 		print(urls)
// 		completionHandler(urls)
// 	}
// 	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
// 		controller.dismiss(animated: true) {
// 		}
// 		completionHandler([])
// 		print("cancelled")
// 	}
// }
// 
// 
// 
// #endif
// 
