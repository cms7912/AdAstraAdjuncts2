//
//  File.swift
//  
//
//  Created by cms on 3/8/22.
//

import Foundation

public extension Task where Failure == Error {
	static func delayedBy(_ delayInterval: TimeInterval,
												priority: TaskPriority? = nil,
												operation: @escaping @Sendable () async throws -> Success) -> Task
	{
		Task(priority: priority) {
			let delay = UInt64(delayInterval * 1_000_000_000)
			try await Task<Never, Never>.sleep(nanoseconds: delay)
			return try await operation()
		}
	}
	// https://www.swiftbysundell.com/articles/delaying-an-async-swift-task/
}

