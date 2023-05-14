//
//  LevelsView.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

struct LevelsView: View {
    @EnvironmentObject private var LSM: LevelSelectionModel
    
    var body: some View {
        //in case there were multiple levels
//        ForEach(levels, id: \.title) { level in
//            NavigationLink(destination: LevelPrerequisitesView(level: level).environmentObject(LSM), label: {
//                level.levelPreview
//            })
//        }
//        .navigationTitle("Levels")
//        .navigationBarTitleDisplayMode(.inline)
        LevelPrerequisitesView(level: PythagoreanTheorem).environmentObject(LSM)
    }
}
