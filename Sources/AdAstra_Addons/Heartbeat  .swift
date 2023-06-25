//
//  File.swift
//  
//
//  Created by cms on 1/7/22.
//

import Foundation
// import CoreData

public class AdAstraHeartbeat: NSObject {
   /*
    types of beats:
    - Beat now and reschedule next beat to after interval [Combine: throttle, latest=false)
    
    - Beat now only if not already scheduled
    - (aka beat only when called and no more frequently than interval since last beat)  [Combine: throttle = latest=true]
    - set 'beatNoMoreThanInterval' to true
    
    - Kick-the-can: don't beat now, and beat only after full interval unless another request comes to restart interval again [Combine: debounce]
    - call 'scheduleNextBeat()' for each request with requestedBeatTime=nil
    */
   
   override public func llogPrefix() -> String? { "♥️ '\(name)'|" }
   private var HeartbeatQueue: DispatchQueue = DispatchQueue(label: "HeartbeatQueue",
                                                             qos: .default,
                                                             // attributes: .concurrent,
                                                             autoreleaseFrequency: .inherit,
                                                             target: nil)
   // without "attributes: .concurrent", this is a serial queue
   
   public init(interval: TimeInterval,
               beatNoMoreThanInterval: Bool = false,
               startOnAwake: Bool = false,
               pauseWhileBackgrounded: Bool,
               beatWhenBackgrounded: Bool,
               beatWhenForegrounded: Bool,
               name: String,
               closure: @escaping () -> Void ){
      self.timeInterval = interval
      self.beatOnlyAfterInterval = beatNoMoreThanInterval
      self.pauseWhileBackgrounded = pauseWhileBackgrounded
      self.beatWhenBackgrounded = beatWhenBackgrounded
      self.beatWhenForegrounded = beatWhenForegrounded
      self.name = name
      
      self.closure = closure
      super.init()
      
      originatingQueue = OperationQueue.current?.underlyingQueue
      
      if startOnAwake { start() }
      
      self.setupBackgrounding()
      
   }
	private lazy var timer: DispatchSourceTimer = buildTimer()
	private func buildTimer() -> DispatchSourceTimer {
      // HeartbeatQueue.sync {
      let t = DispatchSource.makeTimerSource(queue: HeartbeatQueue)
      t.schedule(deadline: .distantFuture,
                 repeating: self.timeInterval,
                 leeway: DispatchTimeInterval.milliseconds(100)) // 100 = 0.1 seconds.  1,000 milliseconds = 1 second
      t.setEventHandler(handler: { [weak self] in
         self?.beatNow()
      })
      return t
      // }
   }
   
   // public var interval: DispatchTimeInterval
	public var timeInterval: TimeInterval {
		didSet {
			// reset timer when timeInterval is updated. (can be done by outside calls)
			if timeInterval == oldValue { return } // only reset timer if interval has changed
			timer = buildTimer()
		}
	}
   private var beatOnlyAfterInterval: Bool
   private var pauseWhileBackgrounded: Bool
   private var beatWhenBackgrounded: Bool
   private var beatWhenForegrounded: Bool
   private var name: String
   
   private var closure: () -> Void
   var paused: Bool = true // paused at initialization
   var running: Bool { paused.negated }
   
   public  func pause(){
      if paused { return }
      llog("⏸ pausing")
      timer.suspend()
      paused = true
   }
   public func resume(){
      if running { return }
      llog("▶️ resuming")
      timer.resume()
      paused = false
   }
   
   private var originatingQueue: DispatchQueue?
   public func start() {
      if running { return }
      llog("⏺ starting")
      // resume()
      scheduleNextBeat()
   }
   
   private var rightNow: DispatchTime { DispatchTime.now() }
   
   public func beatNow(){
      if #available(iOS 15.0, macOS 12.0, *) {
         llog("🩸\( Date().formatted(date: .omitted, time: .standard) )")
         // note that this class uses 'DispatchTime' for scheduling. this llog of 'Date()' is only for developer-friendly timestamps
      }
      // if cancelled { llog("⏹ previously cancelled"); return }
      llog("will call closure()")
      if originatingQueue == nil { CrashDuringDebug🛑() }
      originatingQueue?.async {
         self.closure()
      }
   }
   
   
   public func scheduleNextBeat(for requestedBeatTime: DispatchTime? = nil) {
      // requestedBeatTime = nil for normal interval
      // if requestedBeatTime is greater than 'nextBeatOnSchedule' then beats will pause until 'requestedBeatTime' (if it is ever reached before deinit)
      llog("->⏱")
      HeartbeatQueue.async { [self] in
         if let requestedBeatTime = requestedBeatTime,
            requestedBeatTime > .now() {
            timer.schedule(deadline: requestedBeatTime)
            llog("⏱-> requestedBeatTime: \(DispatchTime.now().distance(to:requestedBeatTime))")
         } else {
					 let nextBeatOnSchedule = rightNow + timeInterval
            timer.schedule(deadline: nextBeatOnSchedule)
            llog("⏱-> nextBeatOnSchedule: \( DispatchTime.now().distance(to:nextBeatOnSchedule) )")
         }
         resume()
      }
   }
   /// convenience function
   public func scheduleNextBeat(for givenBeatInterval: TimeInterval) { scheduleNextBeat(for: .now() + givenBeatInterval ) }
   
   
}

#if os(iOS)
import UIKit
extension AdAstraHeartbeat {
   func setupBackgrounding(){
      
      NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification , object: nil, queue: nil) { [weak self] (notification) in
         self?.HeartbeatQueue.async {
            self?.didEnterBackground()
         }
      }
      NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
         self?.HeartbeatQueue.async {
         self?.didBecomeActive()
         }
      }
   }
   
   func didEnterBackground(){
      if beatWhenBackgrounded{
         scheduleNextBeat()
         beatNow()
      }
      if pauseWhileBackgrounded {
         pause()
      }
   }
   func didBecomeActive(){
      if beatWhenForegrounded {
         beatNow()
      } else {
         scheduleNextBeat()
      }
      if pauseWhileBackgrounded {
         resume()
      }
   }
   
}
#endif

#if os(macOS)
extension AdAstraHeartbeat {
   func setupBackgrounding( ){
      
   }
}
#endif
