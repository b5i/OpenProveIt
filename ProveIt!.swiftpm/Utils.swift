//
//  Utils.swift
//  ProveIt
//
//  Created by Antoine Bollengier.
//

import SwiftUI


func InstructionText(_ string: String) -> some View {
    Text(string)
        .padding()
        .font(.title2)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 3))
}

func LilSysImage(_ name: String) -> some View {
    Image(systemName: name)
        .resizable()
        .frame(width: 25, height: 25)
}

extension CGPoint {
    func scalarMultiply(by scalar: Double) -> CGPoint {
        CGPoint(x: self.x * scalar, y: self.y * scalar)
    }
}


//https://swiftuirecipes.com/blog/justify-text-in-swiftui
struct JustifiedText: UIViewRepresentable {
    private let text: String
    private let font: UIFont
    
    init(_ text: String, font: UIFont = .systemFont(ofSize: 18)) {
        self.text = text
        self.font = font
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = font
        textView.textAlignment = .justified
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

//https://medium.com/devtechie/shake-animation-with-animatable-in-swiftui-17a91f694ce6
struct Shake: AnimatableModifier {
    var shakes: CGFloat = 0
    var direction: ShakeDirection = .horizontal
    
    var animatableData: CGFloat {
        get {
            shakes
        } set {
            shakes = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: direction == .horizontal ? sin(shakes * .pi * 2) * 5 : cos(shakes * .pi * 2) * 5)
    }
    
    enum ShakeDirection {
        case vertical
        case horizontal
    }
}

extension View {
    func shake(with shakes: CGFloat) -> some View {
        modifier(Shake(shakes: shakes))
    }
}

//Add rich graphics to your SwiftUI app - WWDC21 - Videos -> Apple
/*
Copyright © 2021 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
struct FireworkView: View {
    
    @StateObject private var model = FireworkModel.main
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                model.update(time: now, size: size)

                context.blendMode = .screen
                model.forEachParticle { particle in
                    var innerContext = context
                    innerContext.opacity = particle.opacity
                    innerContext.fill(
                        Ellipse().path(in: particle.frame),
                        with: .color(randomColor()))
                }
            }
        }
    }
    
    private func randomColor() -> Color {
        let allColors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown, .gray] //Without white, black and clear
        return allColors.randomElement() ?? .accentColor
    }
    
    private class FireworkModel: ObservableObject {
        static let main = FireworkModel()
        
        private var rootCell = ParticleCell(birthRate: 2)
        private var lastTime = 0.0

        func update(time: Double, size: CGSize) {
            let delta = min(time - lastTime, 1.0 / 10.0)
            lastTime = time

            if delta > 0 {
                rootCell.updateOldParticles(delta: delta)
                rootCell.createNewParticles(delta: delta) {
                    make(position: CGPoint(
                        x: Double.random(in: 0..<size.width),
                        y: Double.random(in: 0..<size.height)))
                }
            }
        }

        func add(position: CGPoint) {
            let particle = make(position: position)
            rootCell.particles.append(particle)
        }

        func make(position: CGPoint) -> Particle {
            var particle = Particle()
            particle.lifetime = 0.5
            particle.position = position
            particle.parentCenter = particle.position

            var cell = ParticleCell()
            cell.beginEmitting = 0.0
            cell.endEmitting = Double.random(in: 0.05..<0.1)
            cell.birthRate = 8000
            cell.generator = { particle in
                particle.lifetime = Double.random(in: 0.2..<0.5)
                let ang = Double.random(in: -.pi ..< .pi)
                let velocity = Double.random(in: 200..<400)
                particle.velocity = CGSize(width: velocity * cos(ang), height: velocity * -sin(ang))
                particle.size *= Double.random(in: 0.25..<1)
                particle.sizeSpeed = -particle.size * 0.5
                particle.opacity = Double.random(in: 0.5..<0.9)
                particle.opacitySpeed = -particle.opacity / particle.lifetime
            }
            particle.cell = cell
            return particle
        }

        func forEachParticle(do body: (Particle) -> Void) {
            rootCell.forEachParticle(do: body)
        }
    }
    
    private struct ParticleCell {
        typealias Generator = (inout Particle) -> Void

        var time = 0.0
        var beginEmitting = 0.0
        var endEmitting = Double.infinity
        var birthRate = 0.0
        var lastBirth = 0.0
        var generator: Generator = { _ in }
        var particles = [Particle]()

        var isActive: Bool { !particles.isEmpty }

        mutating func updateOldParticles(delta: Double) {
            let oldN = particles.count
            var newN = oldN
            var index = 0
            while index < newN {
                if particles[index].update(delta: delta) {
                    index += 1
                } else {
                    newN -= 1
                    particles.swapAt(index, newN)
                }
            }
            if newN < oldN {
                particles.removeSubrange(newN ..< oldN)
            }
        }

        mutating func createNewParticles(delta: Double, newParticle: () -> Particle) {
            time += delta

            guard time >= beginEmitting && lastBirth < endEmitting else {
                lastBirth = time
                return
            }

            let birthInterval = 1 / birthRate
            while time - lastBirth >= birthInterval {
                lastBirth += birthInterval
                guard lastBirth >= beginEmitting && lastBirth < endEmitting else {
                    continue
                }
                var particle = newParticle()
                generator(&particle)
                if particle.update(delta: time - lastBirth) {
                    particles.append(particle)
                }
            }
        }

        func forEachParticle(do body: (Particle) -> Void) {
            for index in particles.indices {
                if let cell = particles[index].cell {
                    cell.forEachParticle(do: body)
                } else {
                    body(particles[index])
                }
            }
        }
    }
    
    private struct Particle {
        var lifetime = 0.0
        var position = CGPoint.zero
        var parentCenter = CGPoint.zero
        var velocity = CGSize.zero
        var size = 16.0
        var sizeSpeed = 0.0
        var opacity = 0.0
        var opacitySpeed = 0.0
        var cell: ParticleCell?
        
        mutating func update(delta: Double) -> Bool {
            lifetime -= delta
            position.x += velocity.width * delta
            position.y += velocity.height * delta
            size += sizeSpeed * delta
            opacity += opacitySpeed * delta
            
            var active = lifetime > 0
            
            if var cell = cell {
                cell.updateOldParticles(delta: delta)
                if active {
                    cell.createNewParticles(delta: delta) {
                        Particle(position: position, parentCenter: position,
                                 velocity: velocity, size: size)
                    }
                }
                active = active || cell.isActive
                self.cell = cell
            } else {
                if (opacitySpeed <= 0 && opacity <= 0) ||
                    (sizeSpeed <= 0 && size <= 0)
                {
                    active = false
                }
            }
            
            return active
        }
        
        var frame: CGRect {
            CGRect(origin: position, size: CGSize(width: size, height: size))
        }
    }
}
