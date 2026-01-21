//
//  ShaderWallpaperApp.swift
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 21/01/26.
//

import SwiftUI

@main
struct ShaderWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
