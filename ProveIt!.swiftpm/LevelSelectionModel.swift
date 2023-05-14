//
//  LevelSelectionModel.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import Foundation


class LevelSelectionModel: ObservableObject {
    @Published var selectedLevel: Level? {
        willSet {
            self.selectedPrerequisite = nil
            self.levelStarted = false
            self.changingBool.toggle()
        }
    }
    @Published var levelStarted: Bool = false
    @Published var selectedPrerequisite: Prerequisite?
    @Published var changingBool: Bool = false
    
    static let shared = LevelSelectionModel()
}
