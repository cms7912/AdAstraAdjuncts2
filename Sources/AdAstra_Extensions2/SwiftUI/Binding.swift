//
//  File.swift
//  
//
//  Created by cms on 2/28/22.
//

import Foundation
import SwiftUI



public extension Binding {
	 init(
		getOnly: @escaping () -> Value
	){
		self.init(get: getOnly, set: {_ in })
	}
}

