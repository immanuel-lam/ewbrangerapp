import SwiftUI

// MARK: - SafetyCheckInView

struct SafetyCheckInView: View {
    @EnvironmentObject var viewModel: SafetyCheckInViewModel

    @State private var selectedInterval: Int = 60
    @State private var ringAnimating: Bool = false
    @State private var checkInScale: CGFloat = 1.0

    private var ringColor: Color {
        if viewModel.isOverdue { return .dsStatusActive }
        if viewModel.progress < 0.25 { return .dsStatusTreat }
        return .dsPrimary
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpace.xl) {

                    // MARK: Status header
                    statusHeader

                    // MARK: Countdown ring
                    countdownRing
                        .padding(.vertical, DSSpace.md)

                    // MARK: Check-in button (only when active)
                    if viewModel.isActive {
                        checkInButton
                    }

                    // MARK: Interval selector + start/stop
                    controlPanel

                    // MARK: Check-in history
                    if !viewModel.checkInHistory.isEmpty {
                        historySection
                    }

                    Spacer(minLength: DSSpace.xxxl)
                }
                .padding(.horizontal, DSSpace.lg)
                .padding(.top, DSSpace.lg)
            }
            .background(Color.dsBackground.ignoresSafeArea())
            .navigationTitle("Safety Check-In")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                selectedInterval = viewModel.intervalMinutes
                ringAnimating = true
            }
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        HStack(spacing: DSSpace.sm) {
            Circle()
                .fill(viewModel.isActive ? (viewModel.isOverdue ? Color.dsStatusActive : Color.dsStatusCleared) : Color.dsInkMuted)
                .frame(width: 10, height: 10)
                .scaleEffect(viewModel.isActive ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: viewModel.isActive)

            Text(viewModel.isOverdue
                    ? "OVERDUE — Check in now"
                    : viewModel.isActive
                        ? "Timer active — you are being monitored"
                        : "Timer not active")
                .font(DSFont.callout)
                .foregroundStyle(viewModel.isOverdue ? Color.dsStatusActive : viewModel.isActive ? Color.dsStatusCleared : Color.dsInk3)

            Spacer()
        }
        .padding(DSSpace.md)
        .background(viewModel.isOverdue
                        ? Color.dsStatusActiveSoft
                        : viewModel.isActive
                            ? Color.dsStatusClearedSoft
                            : Color.dsSurface)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        .animation(.easeInOut(duration: 0.3), value: viewModel.isActive)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isOverdue)
    }

    // MARK: - Countdown Ring

    private var countdownRing: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.dsDivider, lineWidth: 14)
                .frame(width: 220, height: 220)

            // Progress arc
            Circle()
                .trim(from: 0, to: viewModel.isActive ? viewModel.progress : 1.0)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: viewModel.progress)
                .animation(.easeInOut(duration: 0.4), value: ringColor)

            // Center content
            VStack(spacing: DSSpace.xs) {
                if viewModel.isActive {
                    if viewModel.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.dsStatusActive)

                        Text("OVERDUE")
                            .font(DSFont.badge)
                            .foregroundStyle(Color.dsStatusActive)
                            .tracking(1.2)
                    } else {
                        Text(viewModel.timeRemainingFormatted)
                            .font(.system(size: 38, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.dsInk)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.5), value: viewModel.timeRemainingFormatted)

                        Text("remaining")
                            .font(DSFont.caption)
                            .foregroundStyle(Color.dsInk3)
                    }
                } else {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(Color.dsInkMuted)

                    Text("Not active")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInkMuted)
                }
            }
        }
    }

    // MARK: - Check-In Button

    private var checkInButton: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                checkInScale = 0.92
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    checkInScale = 1.0
                }
            }
            viewModel.checkIn()
        } label: {
            HStack(spacing: DSSpace.md) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                Text("I'm Safe — Check In")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                LinearGradient(
                    colors: viewModel.isOverdue
                        ? [Color.dsStatusActive, Color(hex: "9B2020")]
                        : [Color.dsPrimaryLight, Color.dsPrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .shadow(color: (viewModel.isOverdue ? Color.dsStatusActive : Color.dsPrimary).opacity(0.35),
                    radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(checkInScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isOverdue)
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        VStack(spacing: DSSpace.lg) {
            if !viewModel.isActive {
                // Interval picker
                VStack(alignment: .leading, spacing: DSSpace.sm) {
                    Text("CHECK-IN INTERVAL")
                        .font(DSFont.badge)
                        .foregroundStyle(Color.dsInk3)
                        .tracking(0.8)

                    HStack(spacing: DSSpace.sm) {
                        ForEach(SafetyCheckInViewModel.intervalOptions, id: \.self) { mins in
                            IntervalPill(
                                label: mins < 60 ? "\(mins)m" : "\(mins / 60)h",
                                isSelected: selectedInterval == mins
                            ) {
                                selectedInterval = mins
                            }
                        }
                        Spacer()
                    }
                }
            }

            // Start / Stop
            if viewModel.isActive {
                DSSecondaryButton("Stop Timer", icon: "stop.fill") {
                    viewModel.stopTimer()
                }
            } else {
                DSPrimaryButton("Start Timer", icon: "timer") {
                    viewModel.startTimer(intervalMinutes: selectedInterval)
                }
            }
        }
        .dsCard()
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            Text("RECENT CHECK-INS")
                .font(DSFont.badge)
                .foregroundStyle(Color.dsInk3)
                .tracking(0.8)
                .padding(.bottom, DSSpace.xs)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.checkInHistory.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: DSSpace.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.dsStatusCleared)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.timestamp, style: .time)
                                .font(DSFont.subhead)
                                .foregroundStyle(Color.dsInk)
                            Text(entry.timestamp, style: .relative)
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)
                        }

                        Spacer()

                        Text("#\(index + 1)")
                            .font(DSFont.badge)
                            .foregroundStyle(Color.dsInkMuted)
                    }
                    .padding(.vertical, DSSpace.sm)

                    if index < viewModel.checkInHistory.count - 1 {
                        Divider()
                            .background(Color.dsDivider)
                    }
                }
            }
        }
        .dsCard()
    }
}

// MARK: - IntervalPill

private struct IntervalPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DSFont.callout)
                .foregroundStyle(isSelected ? .white : Color.dsPrimary)
                .padding(.horizontal, DSSpace.md)
                .padding(.vertical, DSSpace.sm)
                .background(isSelected ? Color.dsPrimary : Color.dsPrimarySoft)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.dsPrimary.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
