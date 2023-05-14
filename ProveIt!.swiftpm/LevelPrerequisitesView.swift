//
//  LevelPrerequisitesView.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

struct LevelPrerequisitesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var level: Level
    @EnvironmentObject private var LSM: LevelSelectionModel
    @State private var showAnswersSheet: Bool = false {
        didSet {
            showAnswersSpoilWarning = true
            powersAnswerHidden = true
            anglesAnswerHidden = true
            rectangleTrianglesAnswersHidden = true
            squaresAnswersHidden = true
        }
    }
    @State private var showAnswersSpoilWarning: Bool = true
    @State private var powersAnswerHidden: Bool = true
    @State private var anglesAnswerHidden: Bool = true
    @State private var rectangleTrianglesAnswersHidden: Bool = true
    @State private var squaresAnswersHidden: Bool = true
    @State private var resetButton: Double = 0
    var body: some View {
        VStack {
            if !level.prerequisites.contains(where: {$0.status == false}) {
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(colorScheme.backgroundColor)
                    VStack {
                        Text("You're all set to begin!")
                            .font(.largeTitle)
                        NavigationLink(destination: AnyView(level.engine).environmentObject(LSM), label: {
                            Text("Start")
                        })
                    }
//                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(Array(level.prerequisites.enumerated()), id: \.offset) { _, prerequisite in
                    VStack {
                        HStack {
                            PrerequisitePreview(prerequisite: prerequisite)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .rotationEffect(LSM.selectedPrerequisite == prerequisite ? Angle(degrees: 90) : Angle(degrees: 0))
                        }
                        .onTapGesture {
                            withAnimation {
                                if LSM.selectedPrerequisite == prerequisite {
                                    LSM.selectedPrerequisite = nil
                                } else {
                                    LSM.selectedPrerequisite = prerequisite
                                }
                            }
                        }
                        if LSM.selectedPrerequisite == prerequisite {
                            AnyView(prerequisite.engine)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    LSM.selectedPrerequisite = level.prerequisites.first
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        showAnswersSheet = true
                    }
                } label: {
                    Image(systemName: "lightbulb")
                        .resizable()
                        .scaledToFit()
                }
                .buttonStyle(.borderless)
                .padding(.trailing)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        resetButton += 360
                        for prerequisite in prerequisites {
                            prerequisite.status = false
                        }
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                    //Center y is 0.60598 because the icon has 9.0598% too much height on the bottom
                        .rotationEffect(Angle.degrees(resetButton), anchor: UnitPoint(x: 0.5, y: 0.60598))
                }
                .buttonStyle(.borderless)
            }
        }
        //Answers sheet
        .sheet(isPresented: $showAnswersSheet, content: {
            AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                Answer(
                    visiblePart: "Powers: 2³",
                    hiddenPart: "= 2×2×2 = 8"
                ),
                Answer(
                    visiblePart: "Angles: ɑ + β =",
                    hiddenPart: "150°"
                ),
                Answer(
                    visiblePart: "Squares:",
                    hiddenPart: "All its angles are 180° is false and 44 is not the area of the given square."
                ),
                Answer(
                    visiblePart: "Rectangle Triangles:",
                    hiddenPart: "ɑ + β = 90° and the area is 9."
                )
            ])
        })
        .navigationTitle("Prerequisites")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            LSM.selectedLevel = level
        }
    }
    
    private struct PrerequisitePreview: View {
        @StateObject var prerequisite: Prerequisite
        
        var body: some View {
            Image(systemName: prerequisite.status ? "checkmark.circle.fill" : "circle")
            Text(prerequisite.name)
                .opacity(prerequisite.status ? 0.6 : 1)
                .font(.title2)
        }
    }
}
