//
//  EquationViews.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI

enum EquationElement: Int, CaseIterable {
    case blueSide
    case greenSide
    case redSide
    case plus
    case multiply
    case equal
    case square
    case twoTimes
    case openParenthesis
    case closedParenthesis
    var isTriangleSide: Bool {
        get {
            self.rawValue < 3
        }
    }
    var isOperator: Bool {
        get {
            self.rawValue < 6 && self.rawValue > 2
        }
    }
    var isOther: Bool {
        get {
            self.rawValue > 5
        }
    }
}
    
struct EquationKeyboardView: View {
    @Binding var equation: [EquationElement]
    @Binding var availableElements: [EquationElement]
    @State var equalityText: String = ""
    @State var baseEquationNumber: Int = 0
    @State private var equationRendererRefresh: Int = 0
    @State private var validateNumberOfShakes: CGFloat = 0
    var onChangeAction: () -> (Bool)
    var body: some View {
        //Equation
        HStack {
            HStack {
                VStack {
                    ForEach(EquationElement.allCases.filter({$0.isTriangleSide}), id: \.hashValue) { element in
                        switch(element) {
                        case .blueSide:
                            Button {
                                equation.append(.blueSide)
                                equationRendererRefresh += 1
                            } label: {
                                GeometryReader { geometry in
                                    Path() { path in
                                        path.move(to: CGPoint(x: geometry.size.width / 2 - 50, y: geometry.size.height / 2))
                                        path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50, y: geometry.size.height / 2))
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                                }
                                .frame(width: 150, height: 40)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!availableElements.contains(element))
                        case .greenSide:
                            Button {
                                equation.append(.greenSide)
                                equationRendererRefresh += 1
                            } label: {
                                GeometryReader { geometry in
                                    Path() { path in
                                        path.move(to: CGPoint(x: geometry.size.width / 2 - 50, y: geometry.size.height / 2))
                                        path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50, y: geometry.size.height / 2))
                                    }
                                    .stroke(.green, style: StrokeStyle(lineWidth: 5))
                                }
                                .frame(width: 150, height: 40)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!availableElements.contains(element))
                        case .redSide:
                            Button {
                                equation.append(.redSide)
                                equationRendererRefresh += 1
                            } label: {
                                GeometryReader { geometry in
                                    Path() { path in
                                        path.move(to: CGPoint(x: geometry.size.width / 2 - 50, y: geometry.size.height / 2))
                                        path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50, y: geometry.size.height / 2))
                                    }
                                    .stroke(.red, style: StrokeStyle(lineWidth: 5))
                                }
                                .frame(width: 150, height: 40)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!availableElements.contains(element))
                        default:
                            Color.clear.frame(width: 0, height: 0)
                        }
                    }
                    HStack {
                        Button {
                            while equation.count > baseEquationNumber {
                                if !equation.isEmpty {
                                    equation.removeLast()
                                    equationRendererRefresh += 1
                                }
                            }
                        } label: {
                            Text("Delete")
                                .frame(width: 100, height: 40)
                        }
                        .buttonStyle(.bordered)
                        .padding(.trailing, -1)
                        Button {
                            if !equation.isEmpty && equation.count > baseEquationNumber {
                                equation.removeLast()
                            }
                        } label: {
                            Image(systemName: "delete.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 40)
                        }
                        .buttonStyle(.bordered)
                        .padding(.leading, -1)
                    }
                }
                VStack {
                    HStack {
                        VStack {
                            ForEach(EquationElement.allCases.filter({$0.isOther}), id: \.hashValue) { element in
                                switch(element) {
                                case .square:
                                    Button {
                                        equation.append(.square)
                                        equationRendererRefresh += 1
                                    } label: {
                                        Text("²")
                                            .font(.largeTitle)
                                            .frame(width: 60, height: 40)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!availableElements.contains(element))
                                case .twoTimes:
                                    Button {
                                        equation.append(.twoTimes)
                                        equationRendererRefresh += 1
                                    } label: {
                                        Text("2")
                                            .font(.title)
                                            .frame(width: 60, height: 40)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!availableElements.contains(element))
                                case .openParenthesis:
                                    HStack {
                                        Button {
                                            equation.append(.openParenthesis)
                                            equationRendererRefresh += 1
                                        } label: {
                                            Text("(")
                                                .font(.title)
                                                .frame(width: 15, height: 40)
                                        }
                                        .frame(width: 25, height: 40)
                                        .buttonStyle(.bordered)
                                        .disabled(!availableElements.contains(element))
                                        .padding(.trailing, 6)
                                        Button {
                                            equation.append(.closedParenthesis)
                                            equationRendererRefresh += 1
                                        } label: {
                                            Text(")")
                                                .font(.title)
                                                .frame(width: 15, height: 40)
                                        }
                                        .frame(width: 25, height: 40)
                                        .buttonStyle(.bordered)
                                        .disabled(!availableElements.contains(element))
                                        .padding(.leading, 6)
                                    }
                                    .frame(width: 60, height: 40)
                                    .padding(.top, 6)
                                default:
                                    Color.clear.frame(width: 0, height: 0)
                                }
                            }
                        }
                        VStack {
                            ForEach(EquationElement.allCases.filter({$0.isOperator}), id: \.hashValue) { element in
                                switch(element) {
                                case .plus:
                                    Button {
                                        equation.append(.plus)
                                        equationRendererRefresh += 1
                                    } label: {
                                        Text("+")
                                            .font(.largeTitle)
                                            .frame(width: 60, height: 40)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!availableElements.contains(element))
                                case .equal:
                                    Button {
                                        equation.append(.equal)
                                        equationRendererRefresh += 1
                                    } label: {
                                        Text("=")
                                            .font(.largeTitle)
                                            .frame(width: 60, height: 40)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!availableElements.contains(element))
                                case .multiply:
                                    Button {
                                        equation.append(.multiply)
                                        equationRendererRefresh += 1
                                    } label: {
                                        Text("×")
                                            .font(.largeTitle)
                                            .frame(width: 60, height: 40)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!availableElements.contains(element))
                                default:
                                    Color.clear.frame(width: 0, height: 0)
                                }
                            }
                        }
                    }
                    Button {
                        if !onChangeAction() {
                            withAnimation {
                                validateNumberOfShakes += 2
                            }
                        }
                        equationRendererRefresh += 1
                    } label: {
                        Text("Validate")
                            .frame(width: 152, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .shake(with: validateNumberOfShakes)
                }
            }
            .padding()
            Spacer()
            EquationRendererView(
                equation: $equation,
                passive: false,
                equalityText: equalityText
            )
            .frame(height: 40)
            .padding(.leading, 40)
            Spacer()
        }
    }
}
    
struct EquationRendererView: View {
    @Binding var equation: [EquationElement]
    @State var passive: Bool = true
    @State var equalityText: String = ""
    @State var size: Double = 1
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text(equalityText)
                ForEach(equation, id: \.self) { element in
                    switch(element) {
                    case .blueSide:
                        GeometryReader { geometry in
                            Path() { path in
                                path.move(to: CGPoint(x: geometry.size.width / 2 - 50 * size, y: geometry.size.height / 2))
                                path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50 * size, y: geometry.size.height / 2))
                            }
                            .stroke(.blue, style: StrokeStyle(lineWidth: 5))
                        }
                        .frame(width: 100 * size, height: 40 * size)
                    case .greenSide:
                        GeometryReader { geometry in
                            Path() { path in
                                path.move(to: CGPoint(x: geometry.size.width / 2 - 50 * size, y: geometry.size.height / 2))
                                path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50 * size, y: geometry.size.height / 2))
                            }
                            .stroke(.green, style: StrokeStyle(lineWidth: 5))
                        }
                        .frame(width: 100 * size, height: 40 * size)
                    case .redSide:
                        GeometryReader { geometry in
                            Path() { path in
                                path.move(to: CGPoint(x: geometry.size.width / 2 - 50 * size, y: geometry.size.height / 2))
                                path.addLine(to: CGPoint(x: geometry.size.width / 2 + 50 * size, y: geometry.size.height / 2))
                            }
                            .stroke(.red, style: StrokeStyle(lineWidth: 5))
                        }
                        .frame(width: 100 * size, height: 40 * size)
                    case .square:
                        Text("²")
                            .font(.system(size: 40 * size))
                    case .plus:
                        Text("+")
                            .font(.system(size: 25 * size))
                    case .equal:
                        Text("=")
                            .font(.system(size: 25 * size))
                    case .openParenthesis:
                        Text("(")
                            .font(.system(size: 25 * size))
                    case .closedParenthesis:
                        Text(")")
                            .font(.system(size: 25 * size))
                    case .multiply:
                        Text("×")
                            .font(.system(size: 25 * size))
                    case .twoTimes:
                        Text("2")
                            .font(.system(size: 25 * size))
                    }
                }
            }
        }
        .scrollDisabled(passive)
    }
}
