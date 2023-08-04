//
//  File.swift
//  
//
//  Created by cms on 2/6/22.
//

import Foundation
import SwiftUI
//import AdAstraExtensions


public extension View {
	@ViewBuilder
	func addWindowGlazier(
		as type: String,
		keepSVCClosed: Bool = false,
		updateSVCDisplayMode: Bool = false
	) -> some View {
    GlazierWindowBuilder (
      type: type,
      keepSVCClosed: keepSVCClosed,
      updateSVCDisplayMode: updateSVCDisplayMode) { self }
  }
}
struct GlazierWindowBuilder<Content: View>: View {
  @Environment(\.scenePhase) private var scenePhase
  @SceneStorage("AdAstraApps.GlazierWindow.externalEventRequest") var externalEventRequestSceneStore: URL?
  
  
  let type: String
  let keepSVCClosed: Bool
  let updateSVCDisplayMode: Bool
  let content: () -> Content

  init(
    type: String,
    keepSVCClosed: Bool = false,
    updateSVCDisplayMode: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ){
    self.type = type
    self.keepSVCClosed = keepSVCClosed
    self.updateSVCDisplayMode = updateSVCDisplayMode
    self.content = content
  }
  
  var body: some View {
    GlazierWindowSubBuilder(
      type: type,
      keepSVCClosed: keepSVCClosed,
      updateSVCDisplayMode: updateSVCDisplayMode,
      externalEventRequestSceneStore: $externalEventRequestSceneStore,
      content: content)
    
  }
}
struct GlazierWindowSubBuilder<Content: View>: View {
  @Environment(\.scenePhase) private var scenePhase
  @StateObject var hostWindowGlazier: HostWindowGlazier
  @StateObject var windowContainer = GlazierWindowContainer()
  @Binding var externalEventRequestSceneStore: URL?
  
  let content: () -> Content
  
  init(
    type: String,
    keepSVCClosed: Bool = false,
    updateSVCDisplayMode: Bool = false,
    externalEventRequestSceneStore: Binding<URL?>,
    @ViewBuilder content: @escaping () -> Content
  ){
    _hostWindowGlazier = StateObject(
      wrappedValue:
        HostWindowGlazier(as: type,
                          keepSVCClosed: keepSVCClosed,
                          updateSVCDisplayMode: updateSVCDisplayMode ) )
    self._externalEventRequestSceneStore = externalEventRequestSceneStore
    self.content = content
    
  }
  
  var body: some View {
    Group(content: content)
      .onOpenURL { url in // save the url
        // this gets called after window is constructed
        print("🔗 new HostWindowGlazier link: \(url)")
        if hostWindowGlazier.externalEventRequest != nil {
          print("unexpectedly will overwrite existing externalEventRequest. This shouldn't happen?")
          print("🔗 old HostWindowGlazier link: \(hostWindowGlazier.externalEventRequest!)")
        }
        hostWindowGlazier.externalEventRequest = GlazierExternalEventRequest(url)
        
        // Save in scene storeage
        externalEventRequestSceneStore = url
        
      }
      .onChange(of: externalEventRequestSceneStore){ updatedRequest in
        
        if hostWindowGlazier.externalEventRequest?.eventURL == updatedRequest{
          print("🔗🔗 successfully have alignment")
        } else {
          print("🔗🔗 failed to have alignment")
          print("🔗🔗 \(hostWindowGlazier.externalEventRequest?.eventURL.absoluteString ?? "")")
          print("🔗🔗 \(updatedRequest?.absoluteString ?? "")")
        }
        
        hostWindowGlazier.externalEventRequest = GlazierExternalEventRequest(updatedRequest)
      }
      .onAppear{
        hostWindowGlazier.updateSVCStatus()
      }
      .onChange(of: scenePhase) { scenePhase in
        print("📩 \(hostWindowGlazier.windowType) updated scenePhase: \(scenePhase)  \(hostWindowGlazier.externalEventRequest?.eventURL.absoluteString ?? "")")
      }
      .background(
        GlazierWindowBackgroundAccessorRepresentable()
      )
      .environmentObject(hostWindowGlazier)
      .background(GlazierWindowContainerView(container: windowContainer))
      .environmentObject(windowContainer)
  }
}


struct GlazierWindowBackgroundAccessorRepresentable: NSViewRepresentable {
	@EnvironmentObject var hostWindowGlazier: HostWindowGlazier

	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		DispatchQueue.main.async { [weak view, weak hostWindowGlazier] in
			guard let view = view else { return }
      if let w = view.window {
				hostWindowGlazier?.windowReference = w
				hostWindowGlazier?.findSplitViewController()
			} else {
				print("failed to obtain .window")
				assert(false)
			}
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {}
	// https://onmyway133.com/posts/how-to-manage-windowgroup-in-swiftui-for-macos/
}





// use 'GlazierWindowContainer' and 'GlazierWindowContainerView' to gain access to the underlying NSWindow. This is versatile to use in any view.

public class GlazierWindowContainer: ObservableObject {
	public init(window: NSWindow? = nil) {
		self.window = window
	}

	public var window: NSWindow?
	public var visibleFrame: CGRect? { window?.screen?.visibleFrame }

	public var frameSize50Percent: CGSize? {
		guard let frame = visibleFrame else { return nil }
		return CGSize(width: frame.width/2, height: frame.height/2)
	}
}

public struct GlazierWindowContainerView: NSViewRepresentable {
	public init(container: GlazierWindowContainer){
		self.container = container
	}
	@ObservedObject var container: GlazierWindowContainer
	public func makeNSView(context: Context) -> NSView {
		let view = NSView()
		DispatchQueue.main.async {[weak view, weak container] in
			if let w = view?.window {
				container?.window = w
      } else {
        assert(false)
      }
		}
		return view
	}

	public func updateNSView(_ view: NSView, context: Context) {
		// DispatchQueue.main.async {
		// if container.window != view.window {
		//   container.window = view.window
		//   assert(false) // why would this window value change?
		// }
		// }
	}
	// https://onmyway133.com/posts/how-to-manage-windowgroup-in-swiftui-for-macos/
}
