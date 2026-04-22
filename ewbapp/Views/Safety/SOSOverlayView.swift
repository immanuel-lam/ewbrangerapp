import SwiftUI

// MARK: - SOSOverlayView

struct SOSOverlayView: View {
    enum Mode {
        case alarm                    // my timer expired — broadcasting SOS
        case rescue(rangerName: String) // received another ranger's SOS
    }

    let mode: Mode
    let onDismiss: () -> Void

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    @State private var dotsPhase: Int = 0
    @State private var dotsTimer: Timer? = nil

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer()
                mainContent
                Spacer()
                actionButtons
                    .padding(.bottom, 52)
            }
            .padding(.horizontal, DSSpace.xl)
        }
        .ignoresSafeArea()
        .onAppear {
            startPulse()
            startDotsAnimation()
        }
        .onDisappear {
            dotsTimer?.invalidate()
            dotsTimer = nil
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var background: some View {
        switch mode {
        case .alarm:
            Color.dsStatusActive.ignoresSafeArea()
                .overlay(
                    // Pulsing rings — broadcasting visual
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(Color.white.opacity(0.15 - Double(i) * 0.04), lineWidth: 1.5)
                                .scaleEffect(pulseScale + CGFloat(i) * 0.25)
                                .opacity(pulseOpacity - Double(i) * 0.15)
                                .frame(width: 300, height: 300)
                                .animation(
                                    .easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(Double(i) * 0.5),
                                    value: pulseScale
                                )
                        }
                    }
                )
        case .rescue:
            LinearGradient(
                colors: [
                    Color(hex: "7B1A1A"),
                    Color.dsStatusActive
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch mode {
        case .alarm:
            alarmContent
        case .rescue(let rangerName):
            rescueContent(rangerName: rangerName)
        }
    }

    private var alarmContent: some View {
        VStack(spacing: DSSpace.xl) {
            // SOS icon with pulse ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: DSSpace.sm) {
                Text("SOS TRIGGERED")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(2)

                Text("Check-in timer expired")
                    .font(DSFont.subhead)
                    .foregroundStyle(Color.white.opacity(0.8))
            }

            // Bluetooth beacon status
            VStack(spacing: DSSpace.sm) {
                HStack(spacing: DSSpace.sm) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                    Text("Sending Bluetooth beacon\(dotsString)")
                        .font(DSFont.callout)
                        .foregroundStyle(Color.white.opacity(0.9))
                        .animation(nil, value: dotsString)
                }
                .padding(.horizontal, DSSpace.lg)
                .padding(.vertical, DSSpace.sm)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
            }
        }
    }

    private func rescueContent(rangerName: String) -> some View {
        VStack(spacing: DSSpace.xl) {
            // Header badge
            HStack(spacing: DSSpace.sm) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("SOS BEACON RECEIVED")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.5)
            }
            .padding(.horizontal, DSSpace.md)
            .padding(.vertical, DSSpace.xs)
            .background(Color.white.opacity(0.2))
            .clipShape(Capsule())

            // Ranger name
            VStack(spacing: DSSpace.xs) {
                Text(rangerName)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("missed their safety check-in")
                    .font(DSFont.subhead)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            compassArrow
        }
    }

    // MARK: - Compass Arrow (Find My style)

    @EnvironmentObject private var safetyVM: SafetyCheckInViewModel

    private var compassArrow: some View {
        VStack(spacing: DSSpace.md) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 140, height: 140)

                // Inner compass disc
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)

                // Cardinal labels
                VStack {
                    Text("N").font(DSFont.caption).foregroundStyle(Color.white.opacity(0.5))
                    Spacer()
                    Text("S").font(DSFont.caption).foregroundStyle(Color.white.opacity(0.5))
                }
                .frame(height: 100)
                HStack {
                    Text("W").font(DSFont.caption).foregroundStyle(Color.white.opacity(0.5))
                    Spacer()
                    Text("E").font(DSFont.caption).foregroundStyle(Color.white.opacity(0.5))
                }
                .frame(width: 100)

                // Directional arrow — rotates to sosBearing
                Image(systemName: "location.north.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(safetyVM.sosBearing))
                    .animation(.linear(duration: 0.05), value: safetyVM.sosBearing)
            }

            // Distance label
            HStack(spacing: DSSpace.xs) {
                Image(systemName: "dot.radiowaves.up.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.8))
                Text(safetyVM.sosDistance)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                Text("estimated")
                    .font(DSFont.caption)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        switch mode {
        case .alarm:
            Button {
                onDismiss()
            } label: {
                HStack(spacing: DSSpace.sm) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Cancel SOS — I'm Safe")
                        .font(DSFont.subhead)
                }
                .foregroundStyle(Color.dsStatusActive)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

        case .rescue:
            VStack(spacing: DSSpace.md) {
                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: DSSpace.sm) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 17, weight: .semibold))
                        Text("I'm Responding")
                            .font(DSFont.subhead)
                    }
                    .foregroundStyle(Color.dsStatusActive)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                Button {
                    onDismiss()
                } label: {
                    Text("Dismiss")
                        .font(DSFont.callout)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private var dotsString: String {
        String(repeating: ".", count: (dotsPhase % 3) + 1)
    }

    private func startPulse() {
        withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
            pulseScale = 1.4
            pulseOpacity = 0.0
        }
    }

    private func startDotsAnimation() {
        dotsTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            Task { @MainActor in
                self.dotsPhase += 1
            }
        }
    }
}
