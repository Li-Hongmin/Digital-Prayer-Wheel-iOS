//
//  WheelLoadingView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/23.
//

import SwiftUI

/// 转经筒装载动画视图
struct WheelLoadingView: View {
    @Binding var isPresented: Bool
    let prayerType: String
    let prayerText: String
    let count: Int
    let onComplete: () -> Void

    @State private var progress: Double = 0
    @State private var rotation: Double = 0
    @State private var particles: [ParticleData] = []
    @State private var isCompleted: Bool = false
    @State private var particleTimer: Timer?

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Title
                Text("装载经文到转经筒")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Prayer information
                VStack(spacing: 8) {
                    Text(prayerType)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                    Text("\(formatCount(count)) 遍")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }

                // Prayer wheel animation area
                ZStack {
                    // Particle effect (flowing text)
                    ForEach(particles) { particle in
                        Text(String(prayerText.prefix(1)))
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15).opacity(particle.opacity))
                            .offset(x: particle.x, y: particle.y)
                    }

                    // Prayer wheel icon (rotating)
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.99, green: 0.84, blue: 0.15),
                                    Color(red: 0.96, green: 0.78, blue: 0.10)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.90, green: 0.82, blue: 0.55),
                                    Color(red: 0.75, green: 0.63, blue: 0.35)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text("卍")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(rotation))
                        )
                }
                .frame(height: 200)

                // Progress bar
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.99, green: 0.84, blue: 0.15)))
                        .frame(height: 8)
                        .scaleEffect(y: 2)

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 40)

                // Completion message
                if isCompleted {
                    Text("✅ 装载完成！")
                        .font(.headline)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
            )
            .padding(20)
        }
        .onAppear {
            startLoadingAnimation()
        }
        .onDisappear {
            particleTimer?.invalidate()
        }
    }

    private func startLoadingAnimation() {
        // Start particle generation
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                generateParticle()
            } else {
                timer.invalidate()
            }
        }

        // Prayer wheel rotation animation
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            rotation = 360 * 10 // Multiple rotations
        }

        // Progress animation (4 seconds)
        withAnimation(.easeInOut(duration: 4.0)) {
            progress = 1.0
        }

        // Complete after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation {
                isCompleted = true
            }

            // Wait 1 more second before closing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
                isPresented = false
            }
        }
    }

    private func generateParticle() {
        let particle = ParticleData(
            id: UUID(),
            x: CGFloat.random(in: -60...60),
            y: -100,
            opacity: 1.0
        )
        particles.append(particle)

        // Particle falling animation
        withAnimation(.linear(duration: 2.0)) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].y = 100
                particles[index].opacity = 0
            }
        }

        // Remove after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll { $0.id == particle.id }
        }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 100000000 {
            return "\(count / 100000000) 亿"
        } else if count >= 10000 {
            return "\(count / 10000) 万"
        } else {
            return "\(count)"
        }
    }
}

/// Particle data for animation
struct ParticleData: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

#Preview {
    @Previewable @State var isPresented = true
    return WheelLoadingView(
        isPresented: $isPresented,
        prayerType: "南无阿弥陀佛",
        prayerText: "南无阿弥陀佛",
        count: 100000000
    ) {
        print("Loading completed!")
    }
}
