//
//  AnswersSheetView.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

struct AnswersSheetView: View {
    @Binding var showAnswersSheet: Bool {
        didSet {
            showAnswersSpoilWarning = true
        }
    }
    @State private var showAnswersSpoilWarning: Bool = true
    @State var answers: [Answer]
    var body: some View {
        //Answers sheet
        if showAnswersSpoilWarning {
            NavigationStack {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                        Text("Answers warning")
                            .font(.title)
                    }
                    Text("Are you sure that you want to see the answers?")
                    HStack {
                        Button {
                            withAnimation {
                                showAnswersSheet = false
                            }
                        } label: {
                            Text("No")
                        }
                        .buttonStyle(.borderedProminent)
                        Button {
                            withAnimation {
                                showAnswersSpoilWarning = false
                            }
                        } label: {
                            Text("Yes")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .navigationTitle("Warning")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            NavigationStack {
                VStack(alignment: .center) {
                    VStack (alignment: .leading) {
                        ForEach(Array(answers.enumerated()), id: \.offset) { _, answer in
                            AnswerView(answer: answer)
                        }
                    }
                    Button {
                        withAnimation {
                            showAnswersSheet = false
                        }
                    } label: {
                        Text("Close")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .navigationTitle("Prerequisites answers")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct Answer {
    var visiblePart: String
    var hiddenPart: String = ""
    var hiddenEquation: [EquationElement] = []
}

struct AnswerView: View {
    @State var answer: Answer
    @State private var isHidden: Bool = true
    var body: some View {
        HStack {
            Text(answer.visiblePart)
            ZStack {
                if $answer.hiddenEquation.isEmpty {
                    Text(answer.hiddenPart)
                        .blur(radius: isHidden ? 10 : 0)
                } else {
                    EquationRendererView(equation: $answer.hiddenEquation, size: 0.5)
                        .blur(radius: isHidden ? 10 : 0)
                }
                Text("Click to reveal")
                    .onTapGesture {
                        withAnimation {
                            isHidden = false
                        }
                    }
                    .opacity(isHidden ? 1 : 0)
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 3))
        .padding()
    }
}
