//
//  Level.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

class Level {
    var title: String
    var image: Image
    var prerequisites: [Prerequisite]
    var engine: any View
    var done: Bool
    
    init(title: String, image: Image, prerequisites: [Prerequisite], engine: () -> any View, done: Bool = false) {
        self.title = title
        self.image = image
        self.prerequisites = prerequisites
        self.engine = engine()
        self.done = done
    }
    
    var levelPreview: some View {
        Text(title)
    }
}

let levels = [PythagoreanTheorem]
