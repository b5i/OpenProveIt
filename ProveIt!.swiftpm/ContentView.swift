//
//  ContentView.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var LSM = LevelSelectionModel.shared
    @StateObject private var DOM = DeviceOrientationModel.main
    var body: some View {
        NavigationStack {
            LevelsView()
                .environmentObject(LSM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .rotationEffect(Angle(degrees: DOM.orientation.isPortrait ? 90 : 0))
    }
}

class DeviceOrientationModel: ObservableObject {
    
    public static let main = DeviceOrientationModel()
    
    @Published var orientation: UIDeviceOrientation
    
    init () {
        orientation = UIDevice.current.orientation
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: { _ in
            self.orientation = UIDevice.current.orientation
        })
    }
}
