//
//  ShaderRenderer.swift
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 21/01/26.
//

import Cocoa
import MetalKit
import SwiftUI

// MARK: - Shader Type
enum ShaderType: String, CaseIterable {
    case balatro = "Balatro (Original)"
    case mulBox = "Multi Box"
    case tile = "Tiles"
    case pilar = "Pillars"
    case marble = "Marbles"
    case blackHole = "Black Hole"
    case shiny = "Shiny Color"
    case heavenly = "Heavenly"
    case appleLogo = "Apple Logo"
    
    var shaderName: String {
        switch self {
        case .balatro: return "balatroShader"
        case .mulBox: return "multiBoxShader"
        case .tile: return "tileShader"
        case .pilar: return "pilarShader"
        case .marble: return "marbleShader"
        case .blackHole: return "blackHoleShader"
        case .shiny: return "shinyShader"
        case .heavenly: return "heavenlyShader"
        case .appleLogo: return "appleLogoShader"
        }
    }

    static let storageKey = "selectedShader"

    static var persistedSelection: ShaderType {
        guard
            let rawValue = UserDefaults.standard.string(forKey: storageKey),
            let shader = ShaderType(rawValue: rawValue)
        else {
            return ShaderType.allCases[0]
        }

        return shader
    }
}

struct Uniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var mouse: SIMD4<Float>
}

// MARK: - Shader Renderer
class ShaderRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime: Date!
    var currentShader: ShaderType = ShaderType.persistedSelection
    
    init?(metalView: MTKView) {
        super.init()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return nil
        }
        
        self.device = device
        metalView.device = device
        self.commandQueue = device.makeCommandQueue()
        
        startTime = Date()
        
        // Load the persisted shader when available, otherwise fall back to index 0.
        loadShader(currentShader, for: metalView)
    }
    
    func loadShader(_ shaderType: ShaderType, for metalView: MTKView) {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.main),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: shaderType.shaderName) else {
            print("Failed to load shader: \(shaderType.rawValue)")
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            currentShader = shaderType
            UserDefaults.standard.set(shaderType.rawValue, forKey: ShaderType.storageKey)
            print("Loaded shader: \(shaderType.rawValue)")
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        let time = Float(Date().timeIntervalSince(startTime))
        var uniforms = Uniforms(
            time: time,
            resolution: SIMD2(
                Float(view.drawableSize.width),
                Float(view.drawableSize.height)
            ),
            mouse: SIMD4(0,0,0,0)
        )
        
        renderEncoder.setFragmentBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: 0
        )

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Window Controller
class WallpaperWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: WallpaperWindow!
    var metalView: MTKView!
    var renderer: ShaderRenderer!
    var statusItem: NSStatusItem!
    var isVisible = true
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupMenuBar()
        NSApp.setActivationPolicy(.accessory)
    }
    
    func setupWindow() {
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame
        
        window = WallpaperWindow(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.backgroundColor = .black
        window.isOpaque = true
        
        metalView = MTKView(frame: screenRect)
        metalView.autoresizingMask = [.width, .height]
        metalView.drawableSize = CGSize(
            width: screenRect.width * 0.5,
            height: screenRect.height * 0.5
        )
        
        renderer = ShaderRenderer(metalView: metalView)
        metalView.delegate = renderer
        metalView.preferredFramesPerSecond = 60
        
        window.contentView = metalView
        window.makeKeyAndOrderFront(nil)
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "waveform.circle.fill", accessibilityDescription: "Shader Wallpaper")
        }
        
        let menu = NSMenu()
        
        // Visibility toggle
        let visibilityItem = NSMenuItem(
            title: "Hide Wallpaper",
            action: #selector(toggleVisibility),
            keyEquivalent: "h"
        )
        visibilityItem.target = self
        menu.addItem(visibilityItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Shader selection submenu
        let shaderMenu = NSMenu()
        for shader in ShaderType.allCases {
            let item = NSMenuItem(
                title: shader.rawValue,
                action: #selector(changeShader(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = shader
            item.state = shader == renderer.currentShader ? .on : .off
            shaderMenu.addItem(item)
        }
        
        let shaderMenuItem = NSMenuItem(title: "Select Shader", action: nil, keyEquivalent: "")
        shaderMenuItem.submenu = shaderMenu
        menu.addItem(shaderMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Shader Wallpaper",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc func toggleVisibility() {
        isVisible.toggle()
        
        if isVisible {
            window.orderFront(nil)
            statusItem.menu?.item(at: 0)?.title = "Hide Wallpaper"
        } else {
            window.orderOut(nil)
            statusItem.menu?.item(at: 0)?.title = "Show Wallpaper"
        }
    }
    
    @objc func changeShader(_ sender: NSMenuItem) {
        guard let shader = sender.representedObject as? ShaderType else { return }
        
        renderer.loadShader(shader, for: metalView)
        
        // Update checkmarks
        if let shaderMenu = statusItem.menu?.item(at: 2)?.submenu {
            for item in shaderMenu.items {
                item.state = .off
            }
            sender.state = .on
        }
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

