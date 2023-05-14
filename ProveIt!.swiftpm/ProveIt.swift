//
//  ProveIt.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

//Scale effect that should be applied for the app to work on most devices (app initially made for iPad Pro 11") -> 1194pwidth and 834pheight
//In case the iPad is rotated by default in portrait mode
let screenWidth = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
let screenHeight = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
let scaleEffectToApply: Double = min(screenWidth / 1194, screenHeight / 834)

@main
struct ProveIt: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 1194, height: 834)
                .scaleEffect(scaleEffectToApply < 0.95 ? scaleEffectToApply * 0.96 : scaleEffectToApply)
                .preferredColorScheme(.light)
        }
    }
}
