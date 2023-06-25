//
//  File.swift
//  
//
//  Created by cms on 1/23/22.
//

import Foundation
import SwiftUI

#if DEBUG_XX
public struct DocumentPickerUI: View {
	@State var documentTypes: [String]
	@State var completionHandler: (([URL]) -> Void)

	var picker = DocumentPickerForiOS(
		documentTypes: documentTypes,
		completionHandler: completionHandler )


	public init(documentTypes: [String], completionHandler: @escaping ([URL]) -> Void = {_ in } ) {
		self.documentTypes = documentTypes
		self.completionHandler = completionHandler
	}

	public var body: some View {
		VStack {
			self.picker
		}
		.onAppear {
		}
	}
	// adapted from: https://developer.apple.com/forums/thread/127756
}


#endif
