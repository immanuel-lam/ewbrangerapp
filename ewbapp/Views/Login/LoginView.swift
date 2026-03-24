import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @StateObject private var viewModel: LoginViewModel

    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel(
            authManager: AppEnvironment.shared.authManager,
            persistence: AppEnvironment.shared.persistence
        ))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // ── Hero background ──────────────────────────────────────
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.24, blue: 0.14),
                             Color(red: 0.13, green: 0.38, blue: 0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // ── Hero content ─────────────────────────────────────────
                VStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 52, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("Lama Lama Rangers")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Lantana Monitoring & Control")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, geo.size.height * 0.46)

                // ── Bottom card ──────────────────────────────────────────
                VStack(spacing: 0) {
                    // Drag handle
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            // Ranger selection
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Who are you?")
                                    .font(.system(size: 17, weight: .semibold))
                                    .padding(.horizontal, 4)

                                HStack(spacing: 12) {
                                    ForEach(viewModel.rangers, id: \.id) { ranger in
                                        RangerAvatarCard(
                                            ranger: ranger,
                                            isSelected: viewModel.selectedRanger?.id == ranger.id
                                        ) {
                                            viewModel.selectRanger(ranger)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)

                            // PIN section — only visible once ranger selected
                            if viewModel.selectedRanger != nil {
                                VStack(spacing: 20) {
                                    VStack(spacing: 6) {
                                        Text("Enter PIN")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.secondary)
                                        // PIN dots
                                        HStack(spacing: 18) {
                                            ForEach(0..<4, id: \.self) { i in
                                                Circle()
                                                    .fill(i < viewModel.enteredPIN.count
                                                          ? Color(red: 0.13, green: 0.45, blue: 0.25)
                                                          : Color(.systemGray4))
                                                    .frame(width: 14, height: 14)
                                                    .animation(.spring(response: 0.2), value: viewModel.enteredPIN.count)
                                            }
                                        }
                                    }

                                    // Keypad
                                    PINKeypad(
                                        onDigit: { viewModel.appendPINDigit($0) },
                                        onDelete: { viewModel.deletePINDigit() }
                                    )
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            if let error = viewModel.loginError {
                                Text(error)
                                    .font(.callout)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 8)
                        }
                        .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height * 0.60)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 20, y: -4)
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            // Attribution footer — sits below the card in safe area
            Text("31265 Communications for IT Professionals  ·  EWB Challenge 2026")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.bottom, 6)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedRanger?.id)
        .onAppear {
            viewModel.seedDemoRangersIfNeeded(authManager: appEnv.authManager, persistence: appEnv.persistence)
        }
    }
}

// MARK: - Ranger avatar card

struct RangerAvatarCard: View {
    let ranger: RangerProfile
    let isSelected: Bool
    let action: () -> Void

    private var initials: String {
        let parts = (ranger.displayName ?? "R").split(separator: " ")
        return parts.prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }

    private var roleLabel: String {
        (ranger.role ?? "Ranger")
            .replacingOccurrences(of: "seniorRanger", with: "Senior Ranger")
            .replacingOccurrences(of: "ranger", with: "Ranger")
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? Color(red: 0.10, green: 0.36, blue: 0.20)
                              : Color(.systemGray5))
                        .frame(width: 56, height: 56)
                    Text(initials)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : .primary)
                }
                .overlay(
                    Circle()
                        .strokeBorder(
                            isSelected ? Color(red: 0.18, green: 0.55, blue: 0.32) : Color.clear,
                            lineWidth: 2.5
                        )
                )

                VStack(spacing: 2) {
                    Text(ranger.displayName?.components(separatedBy: " ").first ?? "Ranger")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(roleLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected
                          ? Color(red: 0.10, green: 0.36, blue: 0.20).opacity(0.08)
                          : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color(red: 0.18, green: 0.55, blue: 0.32).opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - PIN keypad

private struct PINKeypad: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let rows = [["1","2","3"], ["4","5","6"], ["7","8","9"], ["","0","⌫"]]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Color.clear.frame(maxWidth: .infinity).frame(height: 64)
                        } else if key == "⌫" {
                            Button { onDelete() } label: {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button { onDigit(key) } label: {
                                Text(key)
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// Keep old RangerChip available in case it's used elsewhere
struct RangerChip: View {
    let ranger: RangerProfile
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(ranger.displayName ?? "Ranger")
                .font(.callout.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
