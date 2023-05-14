//
//  Prerequisite.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

class Prerequisite: ObservableObject {
    var name: String
    var engine: any View
    @Published var status: Bool
    
    init(name: String, engine: () -> any View, status: Bool = false) {
        self.name = name
        self.engine = engine()
        self.status = status
    }
}

extension Prerequisite: Equatable {
    static func == (lhs: Prerequisite, rhs: Prerequisite) -> Bool {
        lhs.name == rhs.name
    }
}

let prerequisites = [PowersPrerequisite, AnglesPrerequisite, SquarePrerequisite, TrianglesPrerequisite]

struct PowersPrerequisiteEngine: View {
    @State private var showHelp: Bool = false
    @StateObject private var prerequisite = PowersPrerequisite
    var body: some View {
        VStack {
            HStack {
                Text("2³ = ?")
                    .font(.largeTitle)
                Button {
                    //Show help
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(.borderless)
            }
            HStack {
                Button {
                    //Right answer
                    withAnimation {
                        prerequisite.status = true
                        LevelSelectionModel.shared.selectedPrerequisite = LevelSelectionModel.shared.selectedLevel?.prerequisites.filter({$0.status == false}).first
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.green)
                        Text("2×2×2 = 8")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                .frame(width: 225, height: 60)
                Button {
                    //Wrong answer
                    showHelp = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.green)
                        Text("3×3 = 9")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                .frame(width: 225, height: 60)
            }
        }
        .sheet(isPresented: $showHelp, content: {
            NavigationStack {
                VStack (alignment: .leading) {
                    Text("A power is a number A that you place on top right of another number to indicate that you want to multiply your number by itself A times.")
                        .frame(height: 50)
                    Text("Examples: ")
                    Text("   2¹ = 2")
                    Text("   2² = 2×2")
                    Text("   3³ = 3×3×3")
                    Text("Note that any number to the power ⁰ = 1. Except 0⁰ that is not determined.")
                    Text("")
                }
                .navigationTitle("Powers - Help")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        })
    }
}

var PowersPrerequisite = Prerequisite(
    name: "Powers", 
    engine: {
        PowersPrerequisiteEngine()
    },
    status: false
)

struct AnglesPrerequisiteEngine: View {
    @State private var showHelp: Bool = false
    @StateObject private var prerequisite = AnglesPrerequisite
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("What is the value of ɑ + β?")
                        .font(.largeTitle)
                    Button {
                        //Show help
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.borderless)
                }
                Image("Angles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)
                HStack {
                    Button {
                        //Wrong answer
                        showHelp = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.green)
                            Text("ɑ + β = 50°")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                    .frame(width: 225, height: 60)
                    Button {
                        //Wrong answer
                        showHelp = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.green)
                            Text("ɑ + β = 125°")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                    .frame(width: 225, height: 60)
                    Button {
                        //Right answer
                        withAnimation {
                            prerequisite.status = true
                            LevelSelectionModel.shared.selectedPrerequisite = LevelSelectionModel.shared.selectedLevel?.prerequisites.filter({$0.status == false}).first
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.green)
                            Text("ɑ + β = 150°")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                    .frame(width: 225, height: 60)
                    Button {
                        //Wrong answer
                        showHelp = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.green)
                            Text("We need more information.")
                                .foregroundColor(.white)
                                .font(.body)
                        }
                    }
                    .frame(width: 225, height: 60)
                }
            }
        }
        .sheet(isPresented: $showHelp, content: {
            NavigationStack {
                VStack (alignment: .leading) {
                    Text("An angle is the measure of the gap between two lines that intersect at a point.")
                        .frame(height: 50)
                    Text("Examples: ")
                    Text("We admit that if there is two lines glued together, the angle between the two is 180°.")
                    Image("Angle180")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    HStack {
                        Text("A half of the previous angle (the two lines are perpendicular): 90°. We note a kind of L to indicate that this angle measures 90° and we name it a “right angle”.")
                    }
                    Image("Angle90")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    Text("And another half of the previous angle is: 45°.")
                    Image("Angle45")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                }
                .navigationTitle("Angles - Help")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        })
    }
}

var AnglesPrerequisite = Prerequisite(
    name: "Angles", 
    engine: {
        AnglesPrerequisiteEngine()
    },
    status: false
)

struct SquarePrerequisiteEngine: View {
    @State private var showHelp: Bool = false
    @State private var questionNumber: Int = 0
    @State private var questions: [Question] = [
        Question(
            id: 0,
            title: "Which of these is not a characteristic of a square?",
            image: "Square",
            answers: [
                Question.Answer(
                    title: "It has four sides.",
                    isRight: false,
                    font: .body
                ),
                Question.Answer(
                    title: "All its angles are 180°.",
                    isRight: true,
                    font: .body
                ),
                Question.Answer(
                    title: "All its sides have the same length.",
                    isRight: false,
                    font: .body
                ),
                Question.Answer(
                    title: "All its angles are equals.",
                    isRight: false,
                    font: .body
                )
            ]
        ),
        Question(
            id: 1,
            title: "What is not the area of this square?",
            image: "Square4",
            answers: [
                Question.Answer(
                    title: "2⁴",
                    isRight: false
                ),
                Question.Answer(
                    title: "16",
                    isRight: false
                ),
                Question.Answer(
                    title: "4²",
                    isRight: false
                ),
                Question.Answer(
                    title: "44",
                    isRight: true
                )
            ]
        )
    ]
    @StateObject private var prerequisite = SquarePrerequisite
    var body: some View {
        VStack {
            TabView(selection: $questionNumber, content: {
                ForEach(questions, content: { question in
                    VStack {
                        HStack {
                            Text(question.title)
                                .font(.largeTitle)
                            Button {
                                //Show help
                                showHelp = true
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                        Image(question.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                        HStack {
                            //Get all the pair answers
                            ForEach(Array(question.answers.indices.enumerated()), id: \.offset) { index, indice in
                                Button {
                                    //Right answer
                                    if question.answers[indice].isRight {
                                        questions[questions.firstIndex(where: {$0.id == question.id}) ?? 0].found = true
                                        if questions.filter({!$0.found}).count == 0 {
                                            withAnimation {
                                                prerequisite.status = true
                                                //Switch to the next non-resolved question
                                                LevelSelectionModel.shared.selectedPrerequisite = LevelSelectionModel.shared.selectedLevel?.prerequisites.filter({$0.status == false}).first
                                            }
                                        } else { //Not all the questions of this theme are answered
                                            withAnimation {
                                                // find the next non-answered question
                                                questionNumber = questions.firstIndex(where: {!$0.found}) ?? 0
                                            }
                                        }
                                    } else {
                                        //Wrong answer
                                        showHelp = true
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.green)
                                        Text(question.answers[indice].title)
                                            .foregroundColor(.white)
                                            .font(question.answers[indice].font)
                                    }
                                }
                                .frame(width: 225, height: 60)
                            }
                        }
                    }
                })
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .sheet(isPresented: $showHelp, content: {
            NavigationStack {
                VStack (alignment: .leading) {
                    Text("A square is a polygon with four sides and four right angles. We also note that every side has the same length")
                    Text("The area of a square is its side length A to the power ², A².")
                    HStack {
                        Spacer()
                        Image("Square")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400)
                        Spacer()
                    }
                }
                .navigationTitle("Squares - Help")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        })
    }
}

var SquarePrerequisite = Prerequisite(
    name: "Squares", 
    engine: {
        SquarePrerequisiteEngine()
    },
    status: false
)

struct TrianglesPrerequisiteEngine: View {
    @State private var showHelp: Bool = false
    @State private var questionNumber: Int = 0
    @State private var questions: [Question] = [
        Question(
            id: 0,
            title: "What is the value of ɑ + β?",
            image: "RectangleTriangle",
            answers: [
                Question.Answer(
                    title: "ɑ + β = 90°",
                    isRight: true
                ),
                Question.Answer(
                    title: "ɑ + β = 45°",
                    isRight: false
                ),
                Question.Answer(
                    title: "ɑ + β = 180°",
                    isRight: false
                ),
                Question.Answer(
                    title: "We need more information.",
                    isRight: false,
                    font: .body
                )
            ]
        ),
        Question(
            id: 1,
            title: "What is the area of this rectangle triangle?",
            image: "RectangleTriangle36",
            answers: [
                Question.Answer(
                    title: "18",
                    isRight: false
                ),
                Question.Answer(
                    title: "36",
                    isRight: false
                ),
                Question.Answer(
                    title: "9",
                    isRight: true
                ),
                Question.Answer(
                    title: "4.5",
                    isRight: false
                )
            ]
        )
    ]
    @StateObject private var prerequisite = TrianglesPrerequisite
    var body: some View {
        VStack {
            TabView(selection: $questionNumber, content: {
                ForEach(questions, content: { question in
                    VStack {
                        HStack {
                            Text(question.title)
                                .font(.largeTitle)
                            Button {
                                //Show help
                                showHelp = true
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                        Image(question.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 300)
                        HStack {
                            ForEach(Array(question.answers.indices.enumerated()), id: \.offset) { index, indice in
                                Button {
                                    //Right answer
                                    if question.answers[indice].isRight {
                                        questions[questions.firstIndex(where: {$0.id == question.id}) ?? 0].found = true
                                        if questions.filter({!$0.found}).count == 0 {
                                            withAnimation {
                                                prerequisite.status = true
                                                //Switch to the next non-resolved question
                                                LevelSelectionModel.shared.selectedPrerequisite = LevelSelectionModel.shared.selectedLevel?.prerequisites.filter({$0.status == false}).first
                                            }
                                        } else { //Not all the questions of this theme are answered
                                            withAnimation {
                                                // find the next non-answered question
                                                questionNumber = questions.firstIndex(where: {!$0.found}) ?? 0
                                            }
                                        }
                                    } else {
                                        //Wrong answer
                                        showHelp = true
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.green)
                                        Text(question.answers[indice].title)
                                            .foregroundColor(.white)
                                            .font(question.answers[indice].font)
                                    }
                                }
                                .frame(width: 225, height: 60)
                            }
                        }
                    }
                })
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .sheet(isPresented: $showHelp, content: {
            NavigationStack {
                VStack (alignment: .leading) {
                    Text("The rectangle triangle is a polygon that has 3 corners and that has a corner with a right angle. Reminder: the sum of the angles of any triangle is equal to 180°. So ɑ + β + 90° = 180°.")
                    HStack {
                        Spacer()
                        Image("RectangleTriangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500)
                        Spacer()
                    }
                    .padding(.bottom)
                    Text("The area of a rectangle triangle is: (A×B)÷2 (A and B are the lengths of the lines that make the right angle). We divide by two because if we glue two equals rectangle triangles, we obtain a rectange of which the area is A×B.")
                    HStack {
                        Spacer()
                        Image("RectangleTriangleArea")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500)
                        Spacer()
                    }
                }
                .navigationTitle("Rectangle Triangles - Help")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        })
    }
}

var TrianglesPrerequisite = Prerequisite(
    name: "Rectangle Triangles",
    engine: {
        TrianglesPrerequisiteEngine()
    },
    status: false
)


struct PrerequisiteEngine: View {
    @State private var showHelp: Bool = false
    @State private var questionNumber: Int = 0
    @State var questions: [Question]
    @State var helpView: any View
    @StateObject var prerequisite: Prerequisite
    var body: some View {
        VStack {
            TabView(selection: $questionNumber, content: {
                ForEach(questions, content: { question in
                    VStack {
                        HStack {
                            Text(question.title)
                                .font(.largeTitle)
                            Button {
                                //Show help
                                showHelp = true
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                        Image(question.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                        HStack {
                            ForEach(Array(question.answers.indices.enumerated()), id: \.offset) { index, indice in
                                Button {
                                    //Right answer
                                    if question.answers[indice].isRight {
                                        questions[questions.firstIndex(where: {$0.id == question.id}) ?? 0].found = true
                                        if questions.filter({!$0.found}).count == 0 {
                                            withAnimation {
                                                prerequisite.status = true
                                                //Switch to the next non-resolved question
                                                LevelSelectionModel.shared.selectedPrerequisite = LevelSelectionModel.shared.selectedLevel?.prerequisites.filter({$0.status == false}).first
                                            }
                                        } else { //Not all the questions of this theme are answered
                                            withAnimation {
                                                // find the next non-answered question
                                                questionNumber = questions.firstIndex(where: {!$0.found}) ?? 0
                                            }
                                        }
                                    } else {
                                        //Wrong answer
                                        showHelp = true
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.green)
                                        Text(question.answers[indice].title)
                                            .foregroundColor(.white)
                                            .font(question.answers[indice].font)
                                    }
                                }
                                .frame(width: 200, height: 50)
                            }
                        }
                    }
                })
            })
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .sheet(isPresented: $showHelp, content: {
            NavigationStack {
                VStack (alignment: .leading) {
                    AnyView(helpView)                }
                .navigationTitle("\(prerequisite.name) - Help")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        })
    }
}


struct Question: Identifiable {
    var id: Int
    var title: String
    var image: String
    var answers: [Answer]
    var found: Bool = false
    struct Answer {
        var title: String
        var isRight: Bool
        var font: Font = .title
    }
}
