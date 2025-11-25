//
//  InteractiveBottleView.swift
//  BabyFeedTracker
//
//  Created by Akim Gauthier  on 24/11/2025.
//

import SwiftUI

// MARK: - Vue Principale
struct InteractiveBottleView: View {
    @State private var quantity: Double = 0
    @State private var isDragging = false
    
    let maxQuantity: Double = 300 // ml
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Text("Eat")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Le biberon avec effet holographique
                    OpalBottleView(
                        quantity: $quantity,
                        isDragging: $isDragging,
                        maxQuantity: maxQuantity
                    )
                    .frame(height: 350)
                    
                    // Affichage quantité style moderne
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Text("\(Int(quantity))")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .contentTransition(.numericText())
                            
                            Text("ml")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.gray)
                                .offset(y: 8)
                        }
                        
                        Text("QUANTITÉ AUJOURD'HUI")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(1.2)
                            .foregroundColor(.gray)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantity)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Stats style Opal
                    StatsBarView(quantity: quantity, maxQuantity: maxQuantity)
                        .padding(.horizontal, 25)
                    
                    // Contrôles
                    BottomControls(quantity: $quantity, maxQuantity: maxQuantity)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
                .padding(.vertical, 50)
            }
            .background(Color.gray)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

// MARK: - Biberon Holographique Style Opal
struct OpalBottleView: View {
    
    @Binding var quantity: Double
    @Binding var isDragging: Bool
    let maxQuantity: Double
    
    @State private var waveOffset: CGFloat = 0
    @State private var glowPulse: Double = 1.0
    @State private var hueRotation: Double = 0
    
    var fillPercentage: Double {
        quantity / maxQuantity
    }
    
    var body: some View {
        ZStack {
            // Glow effect background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.6),
                            Color.blue.opacity(0.4),
                            Color.purple.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 40)
                .scaleEffect(glowPulse)
                .opacity(fillPercentage > 0 ? 0.8 : 0.3)
            
            // Le biberon
            ZStack {
                // Contour holographique
                BottleShape()
                    .stroke(
                        AngularGradient(
                            colors: [
                                .cyan,
                                .blue,
                                .purple,
                                .pink,
                                .orange,
                                .yellow,
                                .cyan
                            ],
                            center: .center
                        )
                        .opacity(0.6),
                        lineWidth: 3
                    )
                    .hueRotation(.degrees(hueRotation))
                    .shadow(color: .cyan.opacity(0.5), radius: 20, y: 0)
                    .shadow(color: .purple.opacity(0.5), radius: 30, y: 0)
                
                // Liquide holographique
                if fillPercentage > 0 {
                    OpalLiquidView(
                        fillPercentage: fillPercentage,
                        waveOffset: waveOffset,
                        hueRotation: hueRotation
                    )
                    .clipShape(BottleShape())
                }
                
                // Brillance holographique
                BottleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear,
                                Color.cyan.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .hueRotation(.degrees(hueRotation * 0.5))
                
                // Zone de drag
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value: value)
                                HapticManager.impact(style: .heavy)
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isDragging = false
                                }
                            }
                    )
            }
            .padding(.horizontal, 120)
        }
        .onAppear {
            // Animation continue du glow
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowPulse = 1.15
            }
            
            // Animation des vagues
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = 140
            }
            
            // Rotation holographique
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                hueRotation = 360
            }
        }
    }
    
    private func handleDrag(value: DragGesture.Value) {
        isDragging = true
        
        let touchY = value.location.y
        let bottleHeight: CGFloat = 320
        let usableHeight = bottleHeight * 0.74
        let bottomY = bottleHeight * 0.82
        
        let relativeY = bottomY - touchY
        let percentage = max(0, min(1, relativeY / usableHeight))
        let newQuantity = percentage * maxQuantity
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
            quantity = max(0, min(maxQuantity, newQuantity))
        }
        
        let previousStep = Int(quantity / 30)
        let currentStep = Int(newQuantity / 30)
        
        if previousStep != currentStep {
            HapticManager.impact(style: .light)
        }
    }
}

// MARK: - Liquide Holographique
struct OpalLiquidView: View {
    let fillPercentage: Double
    let waveOffset: CGFloat
    let hueRotation: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Liquide principal avec effet holographique
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.blue.opacity(0.9),
                                Color.purple.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .hueRotation(.degrees(hueRotation * 0.3))
                    .frame(height: geometry.size.height * 0.74 * fillPercentage)
                    .offset(y: geometry.size.height * 0.08)
                
                // Overlay iridescent
                Rectangle()
                    .fill(
                        AngularGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .cyan.opacity(0.4),
                                .purple.opacity(0.3),
                                .clear
                            ],
                            center: .center
                        )
                    )
                    .hueRotation(.degrees(hueRotation * 0.5))
                    .blendMode(.screen)
                    .frame(height: geometry.size.height * 0.74 * fillPercentage)
                    .offset(y: geometry.size.height * 0.08)
                
                // Vague holographique
                if fillPercentage > 0 {
                    WaveShape(offset: waveOffset, percent: fillPercentage)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.cyan.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 15)
                        .offset(y: geometry.size.height * (0.82 - 0.74 * fillPercentage))
                }
                
                // Particules brillantes
                if fillPercentage > 0.1 {
                    SparklesView(fillPercentage: fillPercentage)
                        .frame(height: geometry.size.height * 0.74 * fillPercentage)
                        .offset(y: geometry.size.height * 0.08)
                }
            }
        }
    }
}

// MARK: - Particules Brillantes
struct SparklesView: View {
    let fillPercentage: Double
    @State private var sparkles: [Sparkle] = []
    
    struct Sparkle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var opacity: Double
        var scale: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Circle()
                    .fill(Color.white)
                    .frame(width: 3, height: 3)
                    .opacity(sparkle.opacity)
                    .scaleEffect(sparkle.scale)
                    .position(sparkle.position)
                    .blur(radius: 0.5)
            }
        }
        .onAppear {
            startSparkles()
        }
    }
    
    private func startSparkles() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            if sparkles.count < 15 {
                let newSparkle = Sparkle(
                    position: CGPoint(
                        x: CGFloat.random(in: 20...100),
                        y: CGFloat.random(in: 0...300) * fillPercentage
                    ),
                    opacity: Double.random(in: 0.3...0.8),
                    scale: CGFloat.random(in: 0.5...1.5)
                )
                
                sparkles.append(newSparkle)
                
                withAnimation(.easeOut(duration: 1.5)) {
                    if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                        sparkles[index].opacity = 0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    sparkles.removeAll { $0.id == newSparkle.id }
                }
            }
        }
    }
}

// MARK: - Stats Bar (Style Opal)
struct StatsBarView: View {
    let quantity: Double
    let maxQuantity: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 25) {
                StatItem(title: "OBJECTIF", value: "\(Int(maxQuantity))ml", color: .cyan)
                StatItem(title: "RESTANT", value: "\(Int(max(0, maxQuantity - quantity)))ml", color: .purple)
                StatItem(title: "PROGRESSION", value: "\(Int((quantity/maxQuantity) * 100))%", color: .blue)
            }
            
            // Barre de progression style Opal
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    // Progress avec gradient holographique
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (quantity / maxQuantity), height: 8)
                        .shadow(color: .cyan.opacity(0.5), radius: 8, y: 0)
                }
            }
            .frame(height: 8)
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(0.8)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Contrôles Bottom (Style Opal)
struct BottomControls: View {
    @Binding var quantity: Double
    let maxQuantity: Double
    
    var body: some View {
        VStack(spacing: 15) {
            // Boutons +/-
            HStack(spacing: 20) {
                ControlButton(
                    icon: "minus",
                    gradient: [.red, .orange],
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            quantity = max(0, quantity - 10)
                        }
                        HapticManager.impact(style: .light)
                    },
                    disabled: quantity == 0
                )
                
                ControlButton(
                    icon: "plus",
                    gradient: [.cyan, .blue],
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            quantity = min(maxQuantity, quantity + 10)
                        }
                        HapticManager.impact(style: .light)
                    },
                    disabled: quantity >= maxQuantity
                )
            }
        }
    }
}

struct ControlButton: View {
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    let disabled: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: gradient[0].opacity(0.4), radius: 10, y: 5)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .disabled(disabled)
        .opacity(disabled ? 0.3 : 1.0)
    }
}

// MARK: - Forme du Biberon (identique)
struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = width * 0.5
        
        let neckHeight = height * 0.08
        let neckWidth = width * 0.3
        
        path.move(to: CGPoint(x: centerX - neckWidth * 0.5, y: 0))
        path.addLine(to: CGPoint(x: centerX - neckWidth * 0.5, y: neckHeight))
        
        let bodyStartY = neckHeight
        let bodyWidth = width * 0.85
        
        path.addQuadCurve(
            to: CGPoint(x: centerX - bodyWidth * 0.5, y: bodyStartY + 30),
            control: CGPoint(x: centerX - bodyWidth * 0.3, y: bodyStartY)
        )
        
        path.addLine(to: CGPoint(x: centerX - bodyWidth * 0.5, y: height * 0.9))
        
        path.addQuadCurve(
            to: CGPoint(x: centerX + bodyWidth * 0.5, y: height * 0.9),
            control: CGPoint(x: centerX, y: height)
        )
        
        path.addLine(to: CGPoint(x: centerX + bodyWidth * 0.5, y: bodyStartY + 30))
        
        path.addQuadCurve(
            to: CGPoint(x: centerX + neckWidth * 0.5, y: neckHeight),
            control: CGPoint(x: centerX + bodyWidth * 0.3, y: bodyStartY)
        )
        
        path.addLine(to: CGPoint(x: centerX + neckWidth * 0.5, y: 0))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Wave Shape (identique)
struct WaveShape: Shape {
    var offset: CGFloat
    var percent: Double
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = 8
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX + offset / width) * .pi * 4)
            let y = height / 2 + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Haptique (identique)
class HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Preview
#Preview {
    InteractiveBottleView()
}
