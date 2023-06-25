// //
// //  File.swift
// //  
// //
// //  Created by cms on 4/30/21.
// //
// 
// import Foundation
// import SwiftUI
// 
// #if os(macOS)
// public struct DocumentPickerUI: View {
//     @State var documentTypes: [String]
//     @State var completionHandler: (([URL]) -> Void)
//     
//     public init(documentTypes: [String], completionHandler: @escaping ([URL]) -> Void = {_ in } ) {
//         self.documentTypes = documentTypes
//         self.completionHandler = completionHandler
//     }
//     
//     public var body: some View {
//         VStack {
//         }
//         .onAppear {
//             
//             let picker = DocumentPickerForMac(
//                 documentTypes: documentTypes,
//                 completionHandler: completionHandler
//             )
//             picker.displayDialogIfMac()
//         }
//     }
//     // adapted from: https://developer.apple.com/forums/thread/127756
// }
// 
// 
// final class DocumentPickerForMac: NSObject {
//     
//     var documentTypes: [String]
//     var completionHandler: (([URL]) -> Void)
//     
//     public init(documentTypes: [String],
//                 completionHandler:  @escaping (([URL]) -> Void)
//     ) {
//         self.documentTypes = documentTypes
//         self.completionHandler = completionHandler
//         super.init()
//         
//     }
//     
//     func displayDialogIfMac() {
//         let dialog = NSOpenPanel()
//         
//         dialog.title                   = "Choose a file or files";
//         dialog.showsResizeIndicator    = true;
//         dialog.showsHiddenFiles        = false;
//         dialog.allowsMultipleSelection = true;
//         dialog.canChooseDirectories = false;
//         let response = dialog.runModal()
//         if ( response ==  NSApplication.ModalResponse.OK) {
//             self.completionHandler(dialog.urls)
//         } else {
//             llog("response: \(response)")
//             // User clicked on "Cancel"
//             // return
//             self.completionHandler([])
//         }
//     }
// }
// 
// 
// 
// 
// 
// 
// 
// 
// #endif
// 
