//
//  PythagoreanTheorem.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

let PythagoreanTheorem = Level(
    title: "The Pythagorean Theorem",
    image: Image(systemName: "angle"),
    prerequisites: [
        PowersPrerequisite,
        AnglesPrerequisite, 
        SquarePrerequisite, 
        TrianglesPrerequisite
    ], 
    engine: {
        PythagoreanTheoremEngine()
    },
    done: false
)


class PythagoreanTheoremModel: ObservableObject {
    @Published var stepsDone: Int = 0
    
    static let shared = PythagoreanTheoremModel()
}

typealias PolygonModel = PythagoreanTheoremEngine.BigPolygonView.Model

struct PythagoreanTheoremEngine: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var step: Int = 1
    @State private var step1Progress: Double = 0
    @State private var step1Formula: [EquationElement] = []
    @State private var step2Progress: Double = 0
    @State private var step3Progress: Double = 0
    @State private var step4Progress: Double = 0
    @State private var step5Progress: Double = 0
    @State private var step3Talk: Int = 0
    @State private var topButton: Double = 0
    @State private var polygonsForStep5: [Polygon] = []
    @State private var usersAreas: [[EquationElement]] = []
    @StateObject private var PTM = PythagoreanTheoremModel.shared
    var body: some View {
        VStack {
            TabView(selection: $step) {
                Step1(
                    step: $step,
                    step1Progress: $step1Progress,
                    step1Formula: $step1Formula
                ).tag(1)
                
                if PTM.stepsDone >= 1 {
                    Step2(
                        step: $step,
                        step2Progress: $step2Progress
                    ).tag(2)
                }
                
                if PTM.stepsDone >= 2 {
                    Step3(
                        step: $step,
                        step3Progress: $step3Progress
                    ).tag(3)
                }
                
                if PTM.stepsDone >= 3 {
                    Step4(
                        step: $step,
                        step4Progress: $step4Progress,
                        polygonsForStep5: $polygonsForStep5,
                        usersAreas: $usersAreas
                    ).tag(4)
                }
                
                if PTM.stepsDone >= 4 {
                    Step5(
                        step1Formula: $step1Formula,
                        step5Progress: $step5Progress,
                        polygonsForStep5: $polygonsForStep5,
                        usersAreas: $usersAreas,
                        step: $step
                    ).tag(5)
                }
            }
            .scrollDisabled(true)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .navigationTitle("The Pythagorean Theorem - Step \(step)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        NotificationCenter.default.post(name: Notification.Name("Step\(step)Answers"), object: nil)
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
                        topButton += 360
                        NotificationCenter.default.post(name: Notification.Name("Step\(step)Reset"), object: nil)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                    //Center y is 0.60598 because the icon has 9.0598% too much height on the bottom
                        .rotationEffect(Angle.degrees(topButton), anchor: UnitPoint(x: 0.5, y: 0.60598))
                }
                .buttonStyle(.borderless)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                HStack {
                    ForEach(1...5, id: \.self) { number in
                        Button {
                            withAnimation {
                                if number <= PTM.stepsDone + 1 {
                                    step = number
                                }
                            }
                        } label: {
                            ZStack {
                                let progress: Double =
                                number == 1 ? step1Progress :
                                number == 2 ? step2Progress :
                                number == 3 ? step3Progress :
                                number == 4 ? step4Progress :
                                step5Progress
                                // FROM: https://sarunw.com/posts/swiftui-circular-progress-bar/
                                Circle()
                                    .stroke(
                                        colorScheme.textColor,
                                        lineWidth: 2
                                    )
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        .green,
                                        style: StrokeStyle(
                                            lineWidth: 2,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeOut, value: progress)
                                Text(String(number))
                                    .foregroundColor(number > PTM.stepsDone ? colorScheme.textColor : .green)
                                    .font(.title)
                            }
                            .frame(width: 40)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .frame(height: 40)
                .padding(.trailing, 30)
            })
        }
    }
    
    private struct Step1: View {
        @Binding var step: Int
        @Binding var step1Progress: Double
        @Binding var step1Formula: [EquationElement]
        @State private var ASlider: Double = 150
        @State private var BSlider: Double = 200
        @State private var equation: [EquationElement] = [.redSide, .square, .equal]
        @State private var showAnswersSheet: Bool = false
        @State private var availableElements: [EquationElement] = [.blueSide, .equal, .greenSide, .plus, .redSide, .square]
        var body: some View {
            //Step 0: elaborate the theorem
            VStack {
                InstructionText("Here is a rectangle triangle, using the prerequisites that you validated before, find a formula to get the square value of the red length. You can modify this triangle with the sliders to test your hypothesis.")
                    .padding(.horizontal)
                HStack {
                    Slider(value: $ASlider, in: 50...250)
                        .frame(width: 270)
                        .tint(.green)
                        .padding()
                    Slider(value: $BSlider, in: 50...250)
                        .frame(width: 270)
                        .tint(.blue)
                        .padding()
                }
                HStack {
                    GeometryReader { geometry in
                        let widthDividedByTwo = geometry.size.width / 2 - ASlider / 2
                        let startingHeight = geometry.size.height * 0.70
                        ZStack {
                            Path() { path in
                                path.move(to: CGPoint(x: widthDividedByTwo, y: startingHeight))
                                path.addLine(to: CGPoint(x: widthDividedByTwo + ASlider, y: startingHeight))
                                path.closeSubpath()
                            }
                            .stroke(.green, style: StrokeStyle(lineWidth: 5))
                            //Green length
                            Text(String(round(ASlider * 2) / 100))
                                .position(x: widthDividedByTwo + ASlider / 2, y: 20 + startingHeight)
                            Path() { path in
                                path.move(to: CGPoint(x: widthDividedByTwo + ASlider, y: startingHeight))
                                path.addLine(to: CGPoint(x: widthDividedByTwo, y: -BSlider + startingHeight))
                                path.closeSubpath()
                            }
                            .stroke(.red, style: StrokeStyle(lineWidth: 5))
                            //Red length
                            Text(String(round(pow(pow(ASlider, 2)+pow(BSlider, 2), 0.5) * 2) / 100))
                                .position(x: widthDividedByTwo + ASlider / 2 + 30, y: -BSlider / 2 - 5 + startingHeight)
                            //Blue line
                            Path() { path in
                                path.move(to: CGPoint(x: widthDividedByTwo, y: -BSlider + startingHeight))
                                path.addLine(to: CGPoint(x: widthDividedByTwo, y: startingHeight))
                            }
                            .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                            //Blue length
                            Text(String(round(BSlider * 2) / 100))
                                .position(x: widthDividedByTwo - 20, y: -BSlider / 2 + startingHeight)
                        }
                    }
                }
                .padding(.bottom, -50)
                EquationKeyboardView(
                    equation: $equation,
                    availableElements: $availableElements,
                    baseEquationNumber: 3,
                    onChangeAction: {
                        //Push user's thought
                        let possibleCombinations: [[EquationElement]] = [
                            [.redSide, .square, .equal, .blueSide, .square, .plus, .greenSide, .square],
                            [.redSide, .square, .equal, .greenSide, .square, .plus, .blueSide, .square],
                            [.greenSide, .square, .plus, .blueSide, .square, .equal, .redSide, .square],
                            [.blueSide, .square, .plus, .greenSide, .square, .equal, .redSide, .square]
                        ]
                        if possibleCombinations.contains(equation) {
                            let model = PythagoreanTheoremModel.shared
                            withAnimation {
                                model.stepsDone = max(step, model.stepsDone)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                withAnimation {
                                    step1Progress = 1
                                    step = 2
                                    step1Formula = equation
                                }
                            })
                            return true
                        } else {
                            return false
                        }
                        
                    }
                )
            }
            //Answers sheet
            .sheet(isPresented: $showAnswersSheet, content: {
                AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                    Answer(
                        visiblePart: "Formula (multiple answers accepted here):",
                        hiddenPart: "",
                        hiddenEquation: [.redSide, .square, .equal, .greenSide, .square, .plus, .blueSide, .square]
                    )
                ])
            })
            .padding(.top)
            .onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name("Step1Reset"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        step1Progress = 0
                        ASlider = 150
                        BSlider = 200
                        equation = [.redSide, .square, .equal]
                    }
                })
                NotificationCenter.default.addObserver(forName: Notification.Name("Step1Answers"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        showAnswersSheet = true
                    }
                })
            }
        }
    }
    
    private struct SquareSidePossiblitiesView: View {
        @Binding var draggedTriangles: [PythagoreanTheoremEngine.Step2.DraggableTriangleType]
        @Binding var step: Int
        @Binding var step2Progress: Double
        @Binding var trianglesDone: [Bool]
        @State var number: Int
        @Binding var triangle0Rotation: Angle
        @Binding var triangle1Rotation: Angle
        @Binding var triangle2Rotation: Angle
        @Binding var triangle3Rotation: Angle
        var body: some View {
            HStack {
                ForEach(PythagoreanTheoremEngine.Step2.DraggableTriangleType.allCases, id: \.self) { value in
                    if !draggedTriangles.contains(value) {
                        ButtonPossibilityView(
                            value: value,
                            number: number,
                            triangle0Rotation: $triangle0Rotation,
                            triangle1Rotation: $triangle1Rotation,
                            triangle2Rotation: $triangle2Rotation,
                            triangle3Rotation: $triangle3Rotation,
                            action: {
                                withAnimation {
                                    trianglesDone[number] = true
                                    draggedTriangles.append(value)
                                    step2Progress += 1/3
                                }
                            }
                        )
                    }
                }
            }
        }
        
        private struct ButtonPossibilityView: View {
            @State var value: PythagoreanTheoremEngine.Step2.DraggableTriangleType
            @State var number: Int
            @Binding var triangle0Rotation: Angle
            @Binding var triangle1Rotation: Angle
            @Binding var triangle2Rotation: Angle
            @Binding var triangle3Rotation: Angle
            @State var action: () -> ()
            @State private var shakeNumber: CGFloat = 0
            var body: some View {
                Button {
                    let angle: Angle =
                    number == 0 ? triangle0Rotation :
                    number == 1 ? triangle1Rotation :
                    number == 2 ? triangle2Rotation : triangle3Rotation
                    let type: PythagoreanTheoremEngine.Step2.DraggableTriangleType
                    switch (round((angle.degrees / 90).truncatingRemainder(dividingBy: 4))) {
                    case 0:
                        type = .top
                    case 1:
                        type = .right
                    case 2:
                        type = .bottom
                    default:
                        type = .left
                    }
                    if value == type {
                        action()
                    } else {
                        withAnimation {
                            shakeNumber += 2
                        }
                    }
                } label: {
                    switch(value) {
                    case .top:
                        LilSysImage("1.circle")
                    case .bottom:
                        LilSysImage("2.circle")
                    case .left:
                        LilSysImage("3.circle")
                    case .right:
                        LilSysImage("4.circle")
                    }
                }
                .buttonStyle(.bordered)
                .shake(with: shakeNumber)
            }
        }
    }
    
    private struct Step2: View {
        @State var draggedTriangles: [DraggableTriangleType] = [.top]
        @Binding var step: Int
        @Binding var step2Progress: Double
        //Array content at certain index isn't updated with @State property!
        @State private var triangle0Rotation: Angle = .zero
        @State private var triangle1Rotation: Angle = .zero
        @State private var triangle2Rotation: Angle = .zero
        @State private var triangle3Rotation: Angle = .zero
        @State private var trianglesDone: [Bool] = [true, false, false, false]
        @State private var size: Double = scaleEffectToApply > 0.99 ? 0.565 : 0.55 //Check when the ratio is too low and decrease the size for the polygon to stay on screen
        @State private var showAnswersSheet: Bool = false
        var body: some View {
            VStack {
                InstructionText("Ok, now, attach the triangles to the free sides of the red polygon to create a big square containing it. For that rotate and attach the triangles by clicking on the number of the side under the rotate button under each of them.")
                    .padding([.top, .horizontal])
                VStack {
                    HStack {}.frame(width: 0, height: trianglesDone.filter({$0}).count == 4 ? 100 : 0)
                    HStack {
                        ForEach(0...3, id: \.self) { number in
                            if !trianglesDone[number] {
                                GeometryReader { geometry in
                                    let middleWidth = geometry.size.width / 2
                                    let triangleBaseCenterX = middleWidth - 150 * size
                                    let middleHeight = geometry.size.height / 2
                                    let triangleASide: Double = 108 * size
                                    let triangleBSide: Double = 192 * size
                                    let triangleCSide: Double = 144 * size
                                    let totallength: Double = triangleASide + triangleBSide
                                    let triangleCenter: UnitPoint = UnitPoint(
                                        x: 0.5,
                                        y: 1 - triangleCSide / geometry.size.height)
                                    let angle: Angle =
                                    number == 0 ? triangle0Rotation :
                                    number == 1 ? triangle1Rotation :
                                    number == 2 ? triangle2Rotation : triangle3Rotation
                                    VStack {
                                        ZStack {
                                            Path() { path in
                                                path.move(to: CGPoint(x: triangleBaseCenterX, y: middleHeight))
                                                //a=108,b=192,c=144
                                                path.addLine(to: CGPoint(x: triangleBaseCenterX + triangleBSide, y: middleHeight - triangleCSide))
                                                path.closeSubpath()
                                            }
                                            .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                            Path() { path in
                                                path.move(to: CGPoint(x: triangleBaseCenterX + triangleBSide, y: middleHeight - triangleCSide))
                                                path.addLine(to: CGPoint(x: triangleBaseCenterX + totallength, y: middleHeight))
                                                path.closeSubpath()
                                            }
                                            .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                            Path() { path in
                                                path.move(to: CGPoint(x: triangleBaseCenterX + totallength, y: middleHeight))
                                                path.addLine(to: CGPoint(x: triangleBaseCenterX, y: middleHeight))
                                                path.closeSubpath()
                                            }
                                            .stroke(.red, style: StrokeStyle(lineWidth: 5))
                                        }
                                        .rotationEffect(angle, anchor: triangleCenter)
                                        .padding(.leading)
                                        .frame(height: geometry.size.height * 0.6)
                                        ZStack{}.frame(height: 70)
                                        VStack {
                                            Button {
                                                withAnimation {
                                                    switch(number) {
                                                    case 0:
                                                        triangle0Rotation.degrees += 90
                                                    case 1:
                                                        triangle1Rotation.degrees += 90
                                                    case 2:
                                                        triangle2Rotation.degrees += 90
                                                    default:
                                                        triangle3Rotation.degrees += 90
                                                    }
                                                }
                                            } label: {
                                                Image("rotate.triangle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.green)
                                                    .frame(width: 30, height: 30)
                                            }
                                            SquareSidePossiblitiesView(
                                                draggedTriangles: $draggedTriangles,
                                                step: $step,
                                                step2Progress: $step2Progress,
                                                trianglesDone: $trianglesDone,
                                                number: number,
                                                triangle0Rotation: $triangle0Rotation,
                                                triangle1Rotation: $triangle1Rotation,
                                                triangle2Rotation: $triangle2Rotation,
                                                triangle3Rotation: $triangle3Rotation
                                            )
                                        }
                                        .frame(height: geometry.size.height * 0.2)
                                        .padding(.top, -geometry.size.height * 0.1)
                                    }
                                }                            }
                        }
                    }
                    ZStack{}.frame(height: 100)
                    GeometryReader { geometry in
                        let middleWidth = geometry.size.width / 2
                        ZStack {
                            ZStack {
                                if draggedTriangles.contains(.top) {
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth - 150 * size, y: 0))
                                        //a=108,b=192,c=144
                                        path.addLine(to: CGPoint(x: middleWidth + 42 * size, y: -144 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth + 42 * size, y: -144 * size))
                                        path.addLine(to: CGPoint(x: middleWidth + 150 * size, y: 0))
                                        path.closeSubpath()
                                    }
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                }
                                if draggedTriangles.contains(.bottom) {
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth - 150 * size, y: 300 * size))
                                        //a=108,b=192,c=144
                                        path.addLine(to: CGPoint(x: middleWidth - 42 * size, y: 444 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth - 42 * size, y: 444 * size))
                                        path.addLine(to: CGPoint(x: middleWidth + 150 * size, y: 300 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                }
                                if draggedTriangles.contains(.left) {
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth - 150 * size, y: 0))
                                        //a=108,b=192,c=144
                                        path.addLine(to: CGPoint(x: middleWidth - 294 * size, y: 108 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth - 294 * size, y: 108 * size))
                                        path.addLine(to: CGPoint(x: middleWidth - 150 * size, y: 300 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                }
                                if draggedTriangles.contains(.right) {
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth + 150 * size, y: 0))
                                        //a=108,b=192,c=144
                                        path.addLine(to: CGPoint(x: middleWidth + 294 * size, y: 192 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                    Path() { path in
                                        path.move(to: CGPoint(x: middleWidth + 294 * size, y: 192 * size))
                                        path.addLine(to: CGPoint(x: middleWidth + 150 * size, y: 300 * size))
                                        path.closeSubpath()
                                    }
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                }
                                Path() { path in
                                    path.move(to: CGPoint(x: middleWidth - 150 * size, y: 0))
                                    path.addLine(to: CGPoint(x: middleWidth + 150 * size, y: 0))
                                    path.addLine(to: CGPoint(x: middleWidth + 150 * size, y: 300 * size))
                                    path.addLine(to: CGPoint(x: middleWidth - 150 * size, y: 300 * size))
                                    path.addLine(to: CGPoint(x: middleWidth - 150 * size, y: 0))
                                    path.closeSubpath()
                                }
                                .stroke(.red, style: StrokeStyle(lineWidth: 5))
                            }
                            LilSysImage("1.circle")
                                .position(CGPoint(x: middleWidth, y: -50 * size))
                            LilSysImage("2.circle")
                                .position(CGPoint(x: middleWidth, y: 350 * size))
                            LilSysImage("3.circle")
                                .position(CGPoint(x: middleWidth - 200 * size, y: 150 * size))
                            LilSysImage("4.circle")
                                .position(CGPoint(x: middleWidth + 200 * size, y: 150 * size))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    if trianglesDone.filter({$0}).count == 4 {
                        Button {
                            withAnimation {
                                PythagoreanTheoremModel.shared.stepsDone = 2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                withAnimation {
                                    step = 3
                                }
                            })
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            //Answers sheet
            .sheet(isPresented: $showAnswersSheet, content: {
                AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                    Answer(
                        visiblePart: "Instructions:",
                        hiddenPart: "\n     1. Rotate one time the new first triangle and tap on 4.\n     2. Rotate two times the new first triangle and tap on 2.\n     3. Rotate three times the only triangle left and tap on 3."
                    )
                ])
            })
            .onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name("Step2Reset"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        //Full rotation of button
                        draggedTriangles = [.top]
                        step2Progress = 0
                        triangle0Rotation = .zero
                        triangle1Rotation = .zero
                        triangle2Rotation = .zero
                        triangle3Rotation = .zero
                        trianglesDone = [true, false, false, false]
                    }
                })
                NotificationCenter.default.addObserver(forName: Notification.Name("Step2Answers"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        showAnswersSheet = true
                    }
                })
            }
        }
        
        enum DraggableTriangleType: Codable, CaseIterable {
            case top
            case bottom
            case left
            case right
        }
    }
    
    private struct Step3: View {
        @Binding var step: Int
        @Binding var step3Progress: Double
        @State private var talkStep: Int = 0
        @State private var size: Double = 0.6
        @State private var filledTriangles: [SideTriangles] = []
        @State private var showAnswersSheet: Bool = false
        var body: some View {
            VStack {
                HStack {
                    switch(talkStep) {
                    case 0:
                        InstructionText("Ok so first of all, as every triangles you added on the sides of this polygon are exactly the same, what can you conclude about this ”mysterious” red polygon? (make the most precise conclusion)")
                    case 1:
                        InstructionText("Ok, we agree. Now how can you prove that this is effectively a square? (multiple answers may be necessary)")
                    default:
                        Color.clear.frame(width: 0, height: 0)
                    }
                }
                .padding(.top)
                TabView(selection: $talkStep) {
                    Talk0View(
                        talkStep: $talkStep,
                        step3Progress: $step3Progress
                    )
                    .tag(0)
                    
                    Talk1View(
                        talkStep: $talkStep,
                        step3Progress: $step3Progress,
                        step: $step
                    )
                    .tag(1)
                }
                .padding(.top, -50)
                GeometryReader { geometry in
                    ZStack {
                        let middleWidth = geometry.size.width / 2
                        //Values of triangles lengths are a=108,b=192,c=144
                        //Point are numbered by top to bottom and left to right
                        let p1 = CGPoint(x: middleWidth + 42 * size, y: -144 * size)
                        let p2 = CGPoint(x: middleWidth - 150 * size, y: 0)
                        let p3 = CGPoint(x: middleWidth + 150 * size, y: 0)
                        let p4 = CGPoint(x: middleWidth - 294 * size, y: 108 * size)
                        let p5 = CGPoint(x: middleWidth + 294 * size, y: 192 * size)
                        let p6 = CGPoint(x: middleWidth - 150 * size, y: 300 * size)
                        let p7 = CGPoint(x: middleWidth + 150 * size, y: 300 * size)
                        let p8 = CGPoint(x: middleWidth - 42 * size, y: 444 * size)
                        ZStack {
                            //Red square
                            ZStack {
                                Path() { path in
                                    path.move(to: p2)
                                    path.addLine(to: p3)
                                    path.addLine(to: p7)
                                    path.addLine(to: p6)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                }
                                .stroke(.red, style: StrokeStyle(lineWidth: 5))
                                Path() { path in
                                    path.move(to: p2)
                                    path.addLine(to: p3)
                                    path.addLine(to: p7)
                                    path.addLine(to: p6)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                }
                                .fill(.red)
                            }
                            //Blue, green and red triangles
                            ZStack {
                                if filledTriangles.contains(.top) {
                                    Path() { path in
                                        path.move(to: p2)
                                        //a=108,b=192,c=144
                                        path.addLine(to: p1)
                                        path.addLine(to: p3)
                                        path.addLine(to: p2)
                                        path.closeSubpath()
                                    }
                                    .fill(.orange)
                                }
                                if filledTriangles.contains(.bottom) {
                                    //Bottom triangle
                                    Path() { path in
                                        path.move(to: p6)
                                        //a=108,b=192,c=144
                                        path.addLine(to: p8)
                                        path.addLine(to: p7)
                                        path.addLine(to: p6)
                                        path.closeSubpath()
                                    }
                                    .fill(.orange)
                                }
                                if filledTriangles.contains(.left) {
                                    //Left triangle
                                    Path() { path in
                                        path.move(to: p2)
                                        //a=108,b=192,c=144
                                        path.addLine(to: p4)
                                        path.addLine(to: p6)
                                        path.addLine(to: p2)
                                        path.closeSubpath()
                                    }
                                    .fill(.orange)
                                }
                                if filledTriangles.contains(.right) {
                                    //Right triangle
                                    Path() { path in
                                        path.move(to: p3)
                                        //a=108,b=192,c=144
                                        path.addLine(to: p5)
                                        path.addLine(to: p7)
                                        path.addLine(to: p3)
                                        path.closeSubpath()
                                    }
                                    .fill(.orange)
                                }
                            }
                            .opacity(0.6)
                            ZStack {
                                //Top triangle
                                Path() { path in
                                    path.move(to: p2)
                                    //a=108,b=192,c=144
                                    path.addLine(to: p1)
                                    path.closeSubpath()
                                }
                                .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                Path() { path in
                                    path.move(to: p1)
                                    path.addLine(to: p3)
                                    path.closeSubpath()
                                }
                                .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                //Bottom triangle
                                Path() { path in
                                    path.move(to: p6)
                                    //a=108,b=192,c=144
                                    path.addLine(to: p8)
                                    path.closeSubpath()
                                }
                                .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                Path() { path in
                                    path.move(to: p8)
                                    path.addLine(to: p7)
                                    path.closeSubpath()
                                }
                                .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                //Left triangle
                                Path() { path in
                                    path.move(to: p2)
                                    //a=108,b=192,c=144
                                    path.addLine(to: p4)
                                    path.closeSubpath()
                                }
                                .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                Path() { path in
                                    path.move(to: p4)
                                    path.addLine(to: p6)
                                    path.closeSubpath()
                                }
                                .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                //Right triangle
                                Path() { path in
                                    path.move(to: p3)
                                    //a=108,b=192,c=144
                                    path.addLine(to: p5)
                                    path.closeSubpath()
                                }
                                .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                Path() { path in
                                    path.move(to: p5)
                                    path.addLine(to: p7)
                                    path.closeSubpath()
                                }
                                .stroke(.green, style: StrokeStyle(lineWidth: 5))
                            }
                            .opacity(0.6)
                        }
                    }
                    .opacity(step == 3 ? 1 : 0)
                }
                .padding(.top, 20)
            }
            //Answers sheet
            .sheet(isPresented: $showAnswersSheet, content: {
                AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                    Answer(
                        visiblePart: "Shape name:",
                        hiddenPart: "a square."
                    ),
                    Answer(
                        visiblePart: "Proof:",
                        hiddenPart: "Arguments 1 and 2."
                    )
                ])
            })
            .onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name("Step3Reset"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        step3Progress = 0
                        talkStep = 0
                        filledTriangles = []
                    }
                })
                NotificationCenter.default.addObserver(forName: Notification.Name("Step3Answers"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        showAnswersSheet = true
                    }
                })
            }
        }
        
        enum SideTriangles {
            case top
            case bottom
            case left
            case right
        }
        
        private struct Polygon {
            var position: CGPoint?
            var model: PolygonModel
            
            init(geometry: GeometryProxy) {
                self.model = PolygonModel(geometry: geometry)
            }
        }
        
        private struct Talk0View: View {
            @Binding var talkStep: Int
            @Binding var step3Progress: Double
            var body: some View {
                VStack {
                    VStack {
                        HStack {
                            ButtonAnswerView(description: "This is a rectangle.", action: {})
                            ButtonAnswerView(description: "This is a square.", isRightAnswer: true, action: { processResult() })
                            ButtonAnswerView(description: "This is a triangle.", action: {})
                            ButtonAnswerView(description: "This is a circle.", action: {})
                        }
                    }
                    .padding([.vertical, .bottom])
                }
            }
            
            private struct ButtonAnswerView: View {
                @State var description: String
                @State var isRightAnswer: Bool = false
                @State var action: () -> ()
                @State private var shakeNumber: CGFloat = 0
                var body: some View {
                    Button {
                        //Function to process user input
                        if isRightAnswer {
                            action()
                        } else {
                            withAnimation {
                                shakeNumber += 2
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.green)
                            Text(description)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 280, height: 80)
                    .shake(with: shakeNumber)
                }
            }
            
            private func processResult() {
                withAnimation {
                    step3Progress = 0.5
                    talkStep = 1
                }
            }
        }
        
        private struct Talk1View: View {
            @Binding var talkStep: Int
            @Binding var step3Progress: Double
            @Binding var step: Int
            //When proving that the center figure is a square
            @State private var crossedAgruments: [Int] = []
            @State private var arguments: [String] = [
                "The red polygon is a square because it has four sides, and all four-sided shapes are squares.",
                "Each angle of the red polygon forms a line with 2 angles (sum is 90°) of the triangles next to it. So we have that every corner of the red polygon has an angle of 180° - 90° = 90°.",
                "As every triangle we used is the same and that we used the same red side of each triangle, we know that every side of this polygon is the same.",
                "The red polygon is a square because its shape looks like the letter ”C”, and the letter ”C” stands for ”carré” in french so ”square” in english."
            ]
            var body: some View {
                HStack {
                    ForEach(Array(arguments.enumerated()), id: \.offset) { index, element in
                        VStack {
                            JustifiedText(element)
                                .foregroundColor(.white)
                                .frame(height: 160)
                                .padding([.top, .horizontal])
                            Button {
                                withAnimation {
                                    if crossedAgruments.contains(index) {
                                        crossedAgruments.removeAll(where: {$0 == index})
                                    } else {
                                        crossedAgruments.append(index)
                                        verifyInput()
                                    }
                                }
                            } label: {
                                Image(systemName: crossedAgruments.contains(index) ? "checkmark.square" : "square")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .padding([.bottom, .horizontal])
                            }
                            .hoverEffect(.lift)
                        }
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 3))
                        .padding(index == 3 ? .all : [.leading, .vertical])
                    }
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: Notification.Name("Step3Reset"), object: nil, queue: .main, using: { _ in
                        withAnimation {
                            crossedAgruments = []
                        }
                    })
                }
            }
            
            private func verifyInput() {
                if crossedAgruments == [1, 2] {
                    withAnimation {
                        PythagoreanTheoremModel.shared.stepsDone = max(step, PythagoreanTheoremModel.shared.stepsDone)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        withAnimation {
                            step3Progress = 1
                            step = 4
                        }
                    })
                }
            }
        }
    }
    
    private struct Step4: View {
        @Binding var step: Int
        @Binding var step4Progress: Double
        @Binding var polygonsForStep5: [Polygon]
        @Binding var usersAreas: [[EquationElement]]
        @State private var areasTalkStep: Int = 0 {
            didSet {
                switch(areasTalkStep) {
                case 0:
                    AreaTalkStep1Action()
                case 1:
                    AreaTalkStep2Action()
                case 2:
                    AreaTalkStep3Action()
                default:
                    break
                }
            }
        }
        @State private var polygons: [Polygon] = []
        @State private var geometryInit: Int = 0
        @State private var equation: [EquationElement] = []
        @State private var equalityText: String = ""
        @State private var onChangeAction: () -> (Bool) = { return true }
        @State private var availableElements: [EquationElement] = [.blueSide, .greenSide, .redSide, .square, .twoTimes, .openParenthesis, .closedParenthesis, .plus, .multiply]
        @State private var area1: [EquationElement] = []
        @State private var area2: [EquationElement] = []
        @State private var area3: [EquationElement] = []
        @State private var showAnswersSheet: Bool = false
        var body: some View {
            VStack {
                //Multiple areas to calculate
                switch(areasTalkStep) {
                case 0:
                    InstructionText("Now let's calculate some areas! What is the area of the red square? (write the shortest formula possible!)")
                case 1:
                    InstructionText("Great! Now what's the area of all the side triangles? (sum of orange areas) (shortest possible as before!)")
                case 2:
                    InstructionText("Nice! Now what's the area of the big blue square itself? (shortest possible as before!)")
                case 3:
                    InstructionText("Congrats! You found all the areas, now time to conclude your proof!")
                default:
                    Color.clear.frame(width: 0, height: 0)
                }
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(polygons.enumerated()), id: \.offset) { index, polygon in
                            VStack {
                                BigPolygonView(geometry: geometry, model: polygon.model)
                                switch(index) {
                                case 0:
                                    EquationRendererView(equation: $area1, size: 0.7)
                                        .position(x: geometry.size.width / 2 + 150, y: 50)
                                        .opacity(areasTalkStep > 0 ? 1 : 0)
                                case 1:
                                    EquationRendererView(equation: $area2, size: 0.7)
                                        .position(x: geometry.size.width + 260, y: 50)
                                        .opacity(areasTalkStep > 1 ? 1 : 0)
                                case 2:
                                    EquationRendererView(equation: $area3, size: 0.7)
                                        .position(x: geometry.size.width * 3 / 4 + 175, y: 50)
                                        .opacity(areasTalkStep > 2 ? 1 : 0)
                                default:
                                    Color.clear.frame(width: 0, height: 0)
                                }
                            }
                        }
                    }
                    .onAppear {
                        availableElements = [.blueSide, .greenSide, .redSide, .square, .twoTimes, .openParenthesis, .closedParenthesis, .plus, .multiply]
                        if polygons.isEmpty {
                            polygons.append(Polygon(geometry: geometry))
                            withAnimation {
                                polygons[0].model.showFilledRedSquare = true
                                polygons[0].model.showRedSquare = true
                                polygons[0].model.greenBlueBordersOpacity = 0.3
                                polygons[0].model.filledRedSquareOpacity = 1
                            }
                        } else {
                            for polygon in polygons {
                                polygon.model.geometry = geometry
                            }
                        }
                    }
                }
                .padding(.top, 200)
                .id(geometryInit)
                //Calculators goes here
                ZStack {
                    EquationKeyboardView(
                        equation: $equation,
                        availableElements: $availableElements,
                        equalityText: equalityText,
                        onChangeAction: onChangeAction
                    )
                    .opacity(areasTalkStep < 3 ? 1 : 0)
                    if areasTalkStep == 3 {
                        Spacer()
                        Button {
                            //Launch step 5
                            polygonsForStep5 = polygons
                            usersAreas = [area1, area2, area3]
                            withAnimation {
                                PythagoreanTheoremModel.shared.stepsDone = max(step, PythagoreanTheoremModel.shared.stepsDone)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                withAnimation {
                                    step4Progress = 1
                                    step = 5
                                }
                            })
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                }
            }
            .padding(.top)
            //Answers sheet
            .sheet(isPresented: $showAnswersSheet, content: {
                AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                    Answer(
                        visiblePart: "Area of red square:",
                        hiddenPart: "",
                        hiddenEquation: [.redSide, .square]
                    ),
                    Answer(
                        visiblePart: "Sum of orange areas (multiple answers accepted here):",
                        hiddenPart: "",
                        hiddenEquation: [.twoTimes, .multiply, .greenSide, .multiply, .blueSide]
                    ),
                    Answer(
                        visiblePart: "Big blue square area (multiple answers accepted here):",
                        hiddenPart: "",
                        hiddenEquation: [.openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis, .square]
                    )
                ])
            })
            .onAppear {
                AreaTalkStep1Action()
                NotificationCenter.default.addObserver(forName: Notification.Name("Step4Reset"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        AreaTalkStep1Action()
                        step4Progress = 0
                        areasTalkStep = 0
                        polygons = []
                        geometryInit += 1
                    }
                })
                NotificationCenter.default.addObserver(forName: Notification.Name("Step4Answers"), object: nil, queue: .main, using: { _ in
                    withAnimation {
                        showAnswersSheet = true
                    }
                })
            }
        }
        
        private func AreaTalkStep1Action() {
            withAnimation {
                equation = []
                equalityText = ""
                availableElements = [.blueSide, .greenSide, .openParenthesis, .closedParenthesis, .multiply, .twoTimes, .plus]
            }
            onChangeAction = {
                //Push user's thought
                let possibleCombinations: [[EquationElement]] = [
                    [.redSide, .square]
                ]
                //If the user uses pythagorean theorem in his calculus
                //                        let possibleAdvancedCombinations: [[EquationElement]] = [
                //                            [.blueSide, .square, .plus, .greenSide, .square],
                //                            [.greenSide, .square, .plus, .blueSide, .square]
                //                        ]
                if possibleCombinations.contains(equation) {
                    if polygons.count != 0 {
                        let newPolygon: Polygon = Polygon(geometry: polygons[0].model.geometry)
                        newPolygon.model.showFilledRedSquare = true
                        newPolygon.model.greenBlueBordersOpacity = 0.3
                        newPolygon.model.filledRedSquareOpacity = 1
                        withAnimation {
                            polygons[0].model.positionX = 200
                            polygons[0].model.opacity = 0.5
                            polygons[0].model.size = 0.4
                            area1 = equation
                            polygons.append(newPolygon)
                            areasTalkStep = 1
                            step4Progress = 1/3
                        }
                    }
                    return true
                } else {
                    return false
                }
            }
        }
        
        private func AreaTalkStep2Action() {
            if polygons.count > 1 {
                withAnimation {
                    equation = []
                    availableElements = [.blueSide, .greenSide, .openParenthesis, .closedParenthesis, .multiply, .twoTimes, .plus]
                    equalityText = ""
                }
                onChangeAction = {
                    //Push user's thought
                    let possibleCombinations: [[EquationElement]] = [
                        [.twoTimes, .multiply, .blueSide, .multiply, .greenSide],
                        [.twoTimes, .multiply, .greenSide, .multiply, .blueSide],
                        [.greenSide, .multiply, .twoTimes, .multiply, .blueSide],
                        [.greenSide, .multiply, .blueSide, .multiply, .twoTimes],
                        [.blueSide, .multiply, .twoTimes, .multiply, .greenSide],
                        [.blueSide, .multiply, .greenSide, .multiply, .twoTimes]
                    ]
                    
                    print(equation)
                    if possibleCombinations.contains(equation) {
                        let currentPolygonModel = polygons[1].model
                        let newPolygon = Polygon(geometry: currentPolygonModel.geometry)
                        newPolygon.model.polygonRotationAngle = Angle(degrees: 36.5)
                        newPolygon.model.filledTriangles = [.top, .bottom, .left, .right]
                        withAnimation {
                            currentPolygonModel.positionX = currentPolygonModel.geometry.size.width - 200
                            currentPolygonModel.size = 0.4
                            currentPolygonModel.opacity = 0.5
                            area2 = equation
                            polygons.append(newPolygon)
                            areasTalkStep = 2
                            step4Progress = 2/3
                        }
                        return true
                    } else {
                        return false
                    }
                }
                let currentPolygonModel = polygons[1].model
                withAnimation {
                    currentPolygonModel.showFilledRedSquare = false
                    currentPolygonModel.greenBlueBordersOpacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    withAnimation {
                        currentPolygonModel.polygonRotationAngle = Angle(degrees: 36.5)
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    withAnimation {
                        currentPolygonModel.filledTriangles.append(.left)
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                    withAnimation {
                        currentPolygonModel.filledTriangles.append(.top)
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: {
                    withAnimation {
                        currentPolygonModel.filledTriangles.append(.bottom)
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: {
                    withAnimation {
                        currentPolygonModel.filledTriangles.append(.right)
                    }
                })
            }
        }
        
        private func AreaTalkStep3Action() {
            if polygons.count > 2 {
                let currentPolygonModel = polygons[2].model
                withAnimation {
                    currentPolygonModel.filledTriangles = []
                    currentPolygonModel.showFilledBlueSquare = true
                    currentPolygonModel.showRedSquare = false
                    currentPolygonModel.filledBlueSquareOpacity = 0.5
                }
            }
            withAnimation {
                equation = []
                availableElements = [.blueSide, .greenSide, .openParenthesis, .closedParenthesis, .plus, .square, .redSide]
                equalityText = ""
            }
            onChangeAction = {
                //Push user's thought
                let possibleCombinations: [[EquationElement]] = [
                    [.openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis, .square],
                    [.openParenthesis, .blueSide, .plus, .greenSide, .closedParenthesis, .square],
                    [.openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis, .multiply, .openParenthesis, .blueSide, .plus, .greenSide, .closedParenthesis],
                    [.openParenthesis, .blueSide, .plus, .greenSide, .closedParenthesis, .multiply, .openParenthesis, .blueSide, .plus, .greenSide, .closedParenthesis],
                    [.openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis, .multiply, .openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis],
                    [.openParenthesis, .blueSide, .plus, .greenSide, .closedParenthesis, .multiply, .openParenthesis, .greenSide, .plus, .blueSide, .closedParenthesis]
                ]
                if possibleCombinations.contains(equation) {
                    withAnimation {
                        step4Progress = 1
                        areasTalkStep = 3
                        area3 = equation
                        equation = []
                        if polygons.count > 2 {
                            let currentPolygonModel = polygons[2].model
                            currentPolygonModel.size = 0.4
                        }
                        for polygon in polygons {
                            polygon.model.opacity = 1
                        }
                    }
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    private struct Step5: View {
        @Environment(\.colorScheme) private var colorScheme
        @Binding var step1Formula: [EquationElement]
        @Binding var step5Progress: Double
        @Binding var polygonsForStep5: [Polygon]
        @Binding var usersAreas: [[EquationElement]]
        @Binding var step: Int
        @State private var polygons: [Polygon] = []
        @State private var talkStep: Int = 0
        @State private var geometryInit: Int = 0
        @State private var isFirstPlaceholderTargeted: Bool = false
        @State private var isFirstPlaceholderHovered: Bool = false
        @State private var firstPlaceholderContent: TransferableElement? = nil
        @State private var isSecondPlaceholderTargeted: Bool = false
        @State private var isSecondPlaceholderHovered: Bool = false
        @State private var secondPlaceholderContent: TransferableElement? = nil
        @State private var userArea1Backup: [EquationElement] = []
        @State private var case2Equation: [EquationElement] = [.greenSide, .square, .plus, .blueSide, .square, .plus, .twoTimes, .multiply, .greenSide, .multiply, .blueSide] //green^2 + 2*green*blue + blue^2
        @State private var currentGeometry: GeometryProxy? = nil
        @State private var continueButtonShakesNumber: CGFloat = 0
        @State private var showAnswersSheet: Bool = false
        @State private var equation: [EquationElement] = []
        @State private var availableElements: [EquationElement] = [.blueSide, .greenSide, .redSide, .square, .twoTimes, .openParenthesis, .closedParenthesis, .plus, .multiply]
        @State private var lastTalkBlured: Bool = false
        @State private var endShaking: CGFloat = 0
        var body: some View {
            ZStack {
                VStack {
                    //Multiple areas to calculate
                    switch(talkStep) {
                    case 0:
                        InstructionText("Ok, now try to do an equality of the areas you calculated (I changed the color of the areas into blue so it's easier for you!). For that drag an operator (= or -) and drop it to the right ”?” placeholder.")
                            .padding(.horizontal)
                    case 1:
                        InstructionText("Ok, we now have this equation.")
                    case 2:
                        InstructionText("If we develop a bit the area of the entire square we get a result where one term is cancelling itself in one side of the formula. Can you find and write it?")
                            .padding(.horizontal)
                    case 3:
                        InstructionText("Congrats, you have successfully proved the Pythagorean Theorem!")
                    default:
                        Color.clear.frame(width: 0, height: 0)
                    }
                    GeometryReader { geometry in
                        HStack {
                            Spacer(minLength: talkStep < 3 ? geometry.size.width / 4 - 35 : geometry.size.width / 8 - 50)
                            ZStack {
                                HStack {
                                    Text("Formula to prove: ")
                                    EquationRendererView(equation: $step1Formula, size: talkStep < 3 ? 1.1 : 2)
                                }
                                .blur(radius: lastTalkBlured ? 10 : 0)
                                if lastTalkBlured {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                            }
                            .shake(with: endShaking)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 3))
                            Spacer(minLength: talkStep < 3 ? geometry.size.width / 4 - 35 : geometry.size.width / 8 - 50)
                        }
                        .position(x: geometry.size.width / 2, y: talkStep < 3 ? -200 : geometry.size.height / 5)
                        
                        ZStack {
                            ForEach(Array(polygons.enumerated()), id: \.offset) { index, polygon in
                                VStack {
                                    if talkStep == 0 {
                                        BigPolygonView(geometry: geometry, model: polygon.model)
                                    }
                                    
                                    if talkStep < 3 {
                                        let positionY: Double = talkStep == 0 ? -100 : 0
                                        let size: Double =
                                        talkStep == 0 ? 0.7 :
                                        talkStep == 1 ? 1.1 : 0.9
                                        switch(index) {
                                        case 0:
                                            if usersAreas.count > index {
                                                let positionX: Double =
                                                talkStep > 2 ? geometry.size.width - 170
                                                : talkStep > 1 ? geometry.size.width / 2 + 20
                                                : geometry.size.width / 2 + 150
                                                EquationRendererView(equation: $usersAreas[index], size: size)
                                                    .position(x: positionX, y: positionY)
                                            }
                                        case 1:
                                            if usersAreas.count > index {
                                                let positionX: Double = talkStep > 2 ? geometry.size.width - 195
                                                : talkStep == 1 ? geometry.size.width + 240
                                                : geometry.size.width + 260
                                                EquationRendererView(equation: $usersAreas[index], size: size)
                                                    .position(x: positionX, y: positionY)
                                            }
                                        case 2:
                                            if usersAreas.count > index {
                                                let positionX: Double =
                                                talkStep > 2 ? geometry.size.width + 50.0
                                                : talkStep > 1 ? geometry.size.width / 2 + 230.0
                                                : talkStep == 1 ? geometry.size.width * 3 / 4 + 100
                                                : geometry.size.width * 3 / 4 + 175
                                                EquationRendererView(equation: talkStep > 1 ? $case2Equation : $usersAreas[index], size: size)
                                                    .position(x: positionX, y: positionY)
                                            }
                                        default:
                                            Color.clear.frame(width: 0, height: 0)
                                        }
                                    }
                                }
                            }
                            if talkStep < 3 {
                                ZStack {
                                    let positionX: Double = talkStep == 0 ? geometry.size.width / 2 - 200.0
                                    : talkStep == 1 ? geometry.size.width / 2 - 250.0
                                    : talkStep > 2 ? geometry.size.width / 2
                                    : geometry.size.width / 2 - 420.0
                                    let commonPosition = CGPoint(
                                        x: positionX,
                                        y: talkStep == 0 ? -25 : 0
                                    )
                                    ZStack {
                                        if let firstPlaceholderContent = firstPlaceholderContent {
                                            Image(systemName: firstPlaceholderContent.type.rawValue)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50)
                                                .blur(radius: isFirstPlaceholderHovered ? 10 : 0)
                                                .onLongPressGesture(perform: {
                                                    withAnimation {
                                                        isFirstPlaceholderHovered = true
                                                    }
                                                })
                                                .position(commonPosition)
                                        } else {
                                            Button {
                                                
                                            } label: {
                                                Image(systemName: "questionmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                                    .blur(radius: isFirstPlaceholderTargeted ? 10 : 0)
                                            }
                                            .position(commonPosition)
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .dropDestination(for: TransferableElement.self, action: { item, _ in
                                        withAnimation {
                                            firstPlaceholderContent = item.first
                                        }
                                        return true
                                    }, isTargeted: { status in
                                        withAnimation {
                                            isFirstPlaceholderTargeted = status
                                        }
                                    })
                                    if isFirstPlaceholderHovered {
                                        Button {
                                            withAnimation {
                                                self.firstPlaceholderContent = nil
                                                isFirstPlaceholderHovered = false
                                            }
                                        } label: {
                                            Image(systemName: "multiply.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .scaledToFit()
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.borderless)
                                        .position(commonPosition)
                                    }
                                }
                            }
                            if talkStep < 3 {
                                ZStack {
                                    let positionX: Double = talkStep == 0 ? geometry.size.width / 2 + 200.0
                                    : talkStep == 1 ? geometry.size.width / 2 + 180.0
                                    : geometry.size.width / 2 + 225
                                    let commonPosition = CGPoint(
                                        x: positionX,
                                        y: talkStep == 0 ? -25 : 0
                                    )
                                    ZStack {
                                        if let secondPlaceholderContent = secondPlaceholderContent {
                                            Image(systemName: secondPlaceholderContent.type.rawValue)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50)
                                                .blur(radius: isSecondPlaceholderHovered ? 10 : 0)
                                                .onLongPressGesture(perform: {
                                                    withAnimation {
                                                        isSecondPlaceholderHovered = true
                                                    }
                                                })
                                                .position(commonPosition)
                                        } else {
                                            Button { } label: {
                                                Image(systemName: "questionmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                                    .blur(radius: isSecondPlaceholderTargeted ? 10 : 0)
                                            }
                                            .position(commonPosition)
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .dropDestination(for: TransferableElement.self, action: { item, _ in
                                        withAnimation {
                                            secondPlaceholderContent = item.first
                                        }
                                        return true
                                    }, isTargeted: { status in
                                        withAnimation {
                                            isSecondPlaceholderTargeted = status
                                        }
                                    })
                                    if isSecondPlaceholderHovered {
                                        Button {
                                            withAnimation {
                                                self.secondPlaceholderContent = nil
                                                isSecondPlaceholderHovered = false
                                            }
                                        } label: {
                                            Image(systemName: "multiply.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .scaledToFit()
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.borderless)
                                        .position(commonPosition)
                                    }
                                }
                            }
                            ZStack {
                                HStack {
                                    ForEach(TransferableElementType.allCases, id: \.self) { type in
                                        if firstPlaceholderContent?.type != type && secondPlaceholderContent?.type != type {
                                            Button {} label: {
                                                Image(systemName: type.rawValue)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(colorScheme.textColor)
                                            }
                                            .buttonStyle(.bordered)
                                            .disabled(true)
                                            .draggable(TransferableElement(type: type))
                                            .padding(.top, 100)
                                        }
                                    }
                                }
                                if firstPlaceholderContent != nil && secondPlaceholderContent != nil && talkStep < 2 {
                                    Button {
                                        switch(talkStep) {
                                        case 0:
                                            if firstPlaceholderContent?.type == .equal && secondPlaceholderContent?.type == .minus {
                                                withAnimation {
                                                    step5Progress = 1/3
                                                    talkStep = 1
                                                    geometryInit += 1
                                                }
                                            } else {
                                                withAnimation {
                                                    continueButtonShakesNumber += 2
                                                }
                                            }
                                        case 1:
                                            withAnimation {
                                                step5Progress = 2/3
                                                talkStep = 2
                                                geometryInit += 1
                                            }
                                        default:
                                            break
                                        }
                                    } label: {
                                        Text("Continue")
                                    }
                                    .buttonStyle(.bordered)
                                    .padding(.top, talkStep == 0 ? 100 : 0)
                                    .shake(with: continueButtonShakesNumber)
                                }
                            }
                        }
                        .onAppear {
                            if polygons.isEmpty {
                                polygonInit(geometry: geometry)
                                currentGeometry = geometry
                                //                            polygons = polygonsForStep5
                            } else {
                                for polygon in polygons {
                                    polygon.model.geometry = geometry
                                    currentGeometry = geometry
                                }
                            }
                        }
                    }
                    .padding(.top, 250)
                    .id(geometryInit)
                    if talkStep == 2 {
                        EquationKeyboardView(
                            equation: $equation,
                            availableElements: $availableElements,
                            onChangeAction: {
                                let possibleCombinations: [[EquationElement]] = [
                                    [.twoTimes, .multiply, .blueSide, .multiply, .greenSide],
                                    [.twoTimes, .multiply, .greenSide, .multiply, .blueSide],
                                    [.greenSide, .multiply, .twoTimes, .multiply, .blueSide],
                                    [.greenSide, .multiply, .blueSide, .multiply, .twoTimes],
                                    [.blueSide, .multiply, .twoTimes, .multiply, .greenSide],
                                    [.blueSide, .multiply, .greenSide, .multiply, .twoTimes]
                                ]
                                
                                if possibleCombinations.contains(equation) {
                                    endShaking = 0
                                    withAnimation {
                                        PythagoreanTheoremModel.shared.stepsDone = max(step, PythagoreanTheoremModel.shared.stepsDone)
                                        lastTalkBlured = false
                                        step5Progress = 1
                                        talkStep = 3
                                        if case2Equation.count > 5 {
                                            case2Equation.removeLast(6)
                                        }
                                        userArea1Backup = usersAreas[1]
                                        usersAreas[1] = []
                                        geometryInit += 1
                                    }
                                    withAnimation(.linear(duration: 1)) {
                                        endShaking = 8
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                        withAnimation {
                                            lastTalkBlured = true
                                        }
                                    })
                                    return true
                                } else {
                                    return false
                                }
                            }
                        )
                    }
                }
                .padding(.top)
                //Answers sheet
                .sheet(isPresented: $showAnswersSheet, content: {
                    AnswersSheetView(showAnswersSheet: $showAnswersSheet, answers: [
                        Answer(
                            visiblePart: "Symbols order:",
                            hiddenPart: "= then - (you can remove one by exercing a long pressure on it)"
                        ),
                        Answer(
                            visiblePart: "Term that cancels itself (multiple answers accepted here):",
                            hiddenPart: "",
                            hiddenEquation: [.twoTimes, .multiply, .greenSide, .multiply, .blueSide]
                        )
                    ])
                })
                .onAppear {
                    NotificationCenter.default.addObserver(forName: Notification.Name("Step5Reset"), object: nil, queue: .main, using: { _ in
                        withAnimation {
                            if currentGeometry != nil || polygonsForStep5.first?.model.geometry != nil {
                                polygonInit(geometry: currentGeometry ?? polygonsForStep5.first!.model.geometry)
                            }
                            lastTalkBlured = false
                            step5Progress = 0
                            isFirstPlaceholderTargeted = false
                            isFirstPlaceholderHovered = false
                            firstPlaceholderContent = nil
                            isSecondPlaceholderTargeted = false
                            isSecondPlaceholderHovered = false
                            secondPlaceholderContent = nil
                            case2Equation = [.greenSide, .square, .plus, .blueSide, .square, .plus, .twoTimes, .multiply, .greenSide, .multiply, .blueSide]
                            if usersAreas[1].isEmpty {
                                usersAreas[1] = userArea1Backup
                            }
                            geometryInit += 1
                            talkStep = 0
                            equation = []
                        }
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("Step5Answers"), object: nil, queue: .main, using: { _ in
                        withAnimation {
                            showAnswersSheet = true
                        }
                    })
                }
                .onTapGesture {
                    isFirstPlaceholderHovered = false
                    isSecondPlaceholderHovered = false
                }
                if lastTalkBlured {
                    //No ignoreSafeArea because the navigation buttons wouldn't work anymore
                    FireworkView()
                }
            }
        }
        
        private func polygonInit(geometry: GeometryProxy) {
            polygons = []
            //Set polygons for step 5
            let firstPolygon = Polygon(geometry: geometry)
            firstPolygon.model.positionX = 200
            firstPolygon.model.size = 0.4
            firstPolygon.model.polygonRotationAngle.degrees = 36.5
            firstPolygon.model.filledTrianglesColor = .blue
            firstPolygon.model.filledRedSquareColor = .blue
            firstPolygon.model.filledRedSquareOpacity = 0.6
            firstPolygon.model.redBorderOpacity = 0
            firstPolygon.model.showFilledRedSquare = true
            firstPolygon.model.greenBlueBordersOpacity = 0
            polygons.append(firstPolygon)
            
            let secondPolygon = Polygon(geometry: geometry)
            secondPolygon.model.positionX = geometry.size.width - 200
            secondPolygon.model.size = 0.4
            secondPolygon.model.polygonRotationAngle.degrees = 36.5
            secondPolygon.model.filledTrianglesColor = .blue
            secondPolygon.model.filledRedSquareColor = .blue
            secondPolygon.model.filledTriangles = [.top, .bottom, .left, .right]
            secondPolygon.model.redBorderOpacity = 0
            secondPolygon.model.greenBlueBordersOpacity = 0
            polygons.append(secondPolygon)
            
            let thirdPolygon = Polygon(geometry: geometry)
            thirdPolygon.model.size = 0.4
            thirdPolygon.model.polygonRotationAngle.degrees = 36.5
            thirdPolygon.model.filledTrianglesColor = .blue
            thirdPolygon.model.filledRedSquareColor = .blue
            thirdPolygon.model.filledBlueSquareOpacity = 0.6
            thirdPolygon.model.showFilledBlueSquare = true
            thirdPolygon.model.filledRedSquareOpacity = 0
            thirdPolygon.model.redBorderOpacity = 0
            thirdPolygon.model.greenBlueBordersOpacity = 0
            polygons.append(thirdPolygon)
        }
        
        enum TransferableElementType: String, Codable, CaseIterable {
            case minus
            case equal
        }
        
        private struct TransferableElement: Transferable, Codable {
            var type: TransferableElementType
            
            static var transferRepresentation: some TransferRepresentation {
                CodableRepresentation(contentType: .item)
            }
        }
    }
    
    private struct Polygon {
        var model: PolygonModel
        
        init(geometry: GeometryProxy) {
            self.model = PolygonModel(geometry: geometry)
        }
    }
    
    struct BigPolygonView: View {
        @State var geometry: GeometryProxy
        @StateObject var model: PolygonModel
        var body: some View {
            let startWidth: Double = geometry.size.width / 2
            let size = model.size
            //Values of triangles lengths are a=108,b=192,c=144
            //Point are numbered by top to bottom and left to right
            let p1 = CGPoint(x: startWidth + 42 * size, y: -144 * size)
            let p2 = CGPoint(x: startWidth - 150 * size, y: 0)
            let p3 = CGPoint(x: startWidth + 150 * size, y: 0)
            let p4 = CGPoint(x: startWidth - 294 * size, y: 108 * size)
            let p5 = CGPoint(x: startWidth + 294 * size, y: 192 * size)
            let p6 = CGPoint(x: startWidth - 150 * size, y: 300 * size)
            let p7 = CGPoint(x: startWidth + 150 * size, y: 300 * size)
            let p8 = CGPoint(x: startWidth - 42 * size, y: 444 * size)
            let polygonCenter = UnitPoint(x: startWidth / geometry.size.width, y: 150 * size / geometry.size.height)
            VStack {
                ZStack {
                    //Red square
                    ZStack {
                        Path() { path in
                            path.move(to: p2)
                            path.addLine(to: p3)
                            path.addLine(to: p7)
                            path.addLine(to: p6)
                            path.addLine(to: p2)
                            path.closeSubpath()
                        }
                        .stroke(.red, style: StrokeStyle(lineWidth: 5))
                        .opacity(model.redBorderOpacity)
                        Path() { path in
                            path.move(to: p2)
                            path.addLine(to: p3)
                            path.addLine(to: p7)
                            path.addLine(to: p6)
                            path.addLine(to: p2)
                            path.closeSubpath()
                        }
                        .fill(model.showFilledRedSquare ? model.filledRedSquareColor : .clear)
                    }
                    .opacity(model.showRedSquare ? model.filledRedSquareOpacity : 0)
                    //Blue, green and red triangles
                    ZStack {
                        if model.filledTriangles.contains(.top) {
                            Path() { path in
                                path.move(to: p2)
                                //a=108,b=192,c=144
                                path.addLine(to: p1)
                                path.addLine(to: p3)
                                path.addLine(to: p2)
                                path.closeSubpath()
                            }
                            .fill(model.filledTrianglesColor)
                        }
                        if model.filledTriangles.contains(.bottom) {
                            //Bottom triangle
                            Path() { path in
                                path.move(to: p6)
                                //a=108,b=192,c=144
                                path.addLine(to: p8)
                                path.addLine(to: p7)
                                path.addLine(to: p6)
                                path.closeSubpath()
                            }
                            .fill(model.filledTrianglesColor)
                        }
                        if model.filledTriangles.contains(.left) {
                            //Left triangle
                            Path() { path in
                                path.move(to: p2)
                                //a=108,b=192,c=144
                                path.addLine(to: p4)
                                path.addLine(to: p6)
                                path.addLine(to: p2)
                                path.closeSubpath()
                            }
                            .fill(model.filledTrianglesColor)
                        }
                        if model.filledTriangles.contains(.right) {
                            //Right triangle
                            Path() { path in
                                path.move(to: p3)
                                //a=108,b=192,c=144
                                path.addLine(to: p5)
                                path.addLine(to: p7)
                                path.addLine(to: p3)
                                path.closeSubpath()
                            }
                            .fill(model.filledTrianglesColor)
                        }
                    }
                    .opacity(0.6)
                    //Entire square
                    ZStack {
                        Path() { path in
                            path.move(to: p4)
                            path.addLine(to: p1)
                            path.addLine(to: p5)
                            path.addLine(to: p8)
                            path.addLine(to: p4)
                            path.closeSubpath()
                        }
                        .fill(model.filledBlueSquareColor)
                    }
                    .opacity(model.showFilledBlueSquare ? model.filledBlueSquareOpacity : 0)
                    ZStack {
                        //Top triangle
                        Path() { path in
                            path.move(to: p2)
                            //a=108,b=192,c=144
                            path.addLine(to: p1)
                            path.closeSubpath()
                        }
                        .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                        Path() { path in
                            path.move(to: p1)
                            path.addLine(to: p3)
                            path.closeSubpath()
                        }
                        .stroke(.green, style: StrokeStyle(lineWidth: 5))
                        //Bottom triangle
                        Path() { path in
                            path.move(to: p6)
                            //a=108,b=192,c=144
                            path.addLine(to: p8)
                            path.closeSubpath()
                        }
                        .stroke(.green, style: StrokeStyle(lineWidth: 5))
                        Path() { path in
                            path.move(to: p8)
                            path.addLine(to: p7)
                            path.closeSubpath()
                        }
                        .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                        //Left triangle
                        Path() { path in
                            path.move(to: p2)
                            //a=108,b=192,c=144
                            path.addLine(to: p4)
                            path.closeSubpath()
                        }
                        .stroke(.green, style: StrokeStyle(lineWidth: 5))
                        Path() { path in
                            path.move(to: p4)
                            path.addLine(to: p6)
                            path.closeSubpath()
                        }
                        .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                        //Right triangle
                        Path() { path in
                            path.move(to: p3)
                            //a=108,b=192,c=144
                            path.addLine(to: p5)
                            path.closeSubpath()
                        }
                        .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                        Path() { path in
                            path.move(to: p5)
                            path.addLine(to: p7)
                            path.closeSubpath()
                        }
                        .stroke(.green, style: StrokeStyle(lineWidth: 5))
                    }
                    .opacity(model.greenBlueBordersOpacity)
                }
                .rotationEffect(model.polygonRotationAngle, anchor: polygonCenter)
                .position(x: model.positionX, y: model.positionY)
                .opacity(model.opacity)
            }
        }
        class Model: ObservableObject {
            var geometry: GeometryProxy
            
            @Published var opacity: Double = 1
            @Published var polygonRotationAngle: Angle = .zero
            @Published var greenBlueBordersOpacity: Double = 1
            @Published var filledBlueSquareOpacity: Double = 1
            @Published var filledRedSquareOpacity: Double = 1
            @Published var redBorderOpacity: Double = 1
            @Published var showFilledRedSquare: Bool = false
            @Published var showFilledBlueSquare: Bool = false
            @Published var showRedSquare: Bool = true
            @Published var size: Double = 0.6
            @Published var filledTriangles: [SideTriangles] = []
            @Published var positionX: Double
            @Published var positionY: Double = 0
            @Published var filledRedSquareColor: Color = .red
            @Published var filledTrianglesColor: Color = .orange
            @Published var filledBlueSquareColor: Color = .blue
            
            init(geometry: GeometryProxy) {
                self.geometry = geometry
                self.positionX = geometry.size.width / 2
            }
            
            enum SideTriangles {
                case top
                case bottom
                case left
                case right
            }
        }
    }
}
