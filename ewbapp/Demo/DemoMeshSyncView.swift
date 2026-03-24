import SwiftUI

/// Fake animated mesh sync view for the demo branch.
/// Simulates peer discovery → connection → data transfer → completion.
struct DemoMeshSyncView: View {
    enum Phase { case idle, discovering, syncing, done }

    @State private var phase: Phase = .idle
    @State private var bobProgress: Double = 0
    @State private var carolProgress: Double = 0
    @State private var bobStatus  = "Waiting…"
    @State private var carolStatus = "Waiting…"
    @State private var showPeers = false
    @State private var summary: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Status banner
                HStack(spacing: 8) {
                    Circle()
                        .fill(bannerColor)
                        .frame(width: 10, height: 10)
                    Text(bannerText)
                        .font(.callout)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .animation(.easeInOut, value: phase)

                if !showPeers {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Tap Start Sync to find nearby rangers")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nearby Rangers")
                            .font(.headline)
                            .padding(.horizontal)

                        DemoPeerRow(
                            name: "Bob Smith's iPhone",
                            status: bobStatus,
                            progress: bobProgress
                        )
                        DemoPeerRow(
                            name: "Carol White's iPhone",
                            status: carolStatus,
                            progress: carolProgress
                        )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }

                if let summary {
                    Text(summary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                LargeButton(
                    title: buttonTitle,
                    action: {
                        if phase == .idle || phase == .done { runFakeSync() }
                    },
                    color: phase == .done ? .green : .accentColor
                )
                .disabled(phase == .syncing || phase == .discovering)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
            .navigationTitle("End of Day Sync")
        }
    }

    // MARK: - Computed
    private var bannerColor: Color {
        switch phase {
        case .idle:        return .gray
        case .discovering: return .orange
        case .syncing:     return .blue
        case .done:        return .green
        }
    }

    private var bannerText: String {
        switch phase {
        case .idle:        return "Not syncing"
        case .discovering: return "Searching for nearby rangers…"
        case .syncing:     return "Syncing with nearby devices…"
        case .done:        return "Sync complete — all records up to date"
        }
    }

    private var buttonTitle: String {
        switch phase {
        case .idle:        return "Start Sync"
        case .discovering: return "Searching…"
        case .syncing:     return "Syncing…"
        case .done:        return "Sync Again"
        }
    }

    // MARK: - Fake animation
    private func runFakeSync() {
        withAnimation { phase = .discovering; showPeers = false }
        bobProgress  = 0; carolProgress = 0
        bobStatus    = "Waiting…"; carolStatus = "Waiting…"
        summary      = nil

        after(1.0) {
            withAnimation { showPeers = true }
            bobStatus = "Connecting…"
        }
        after(1.8) { carolStatus = "Connecting…" }
        after(2.6) {
            phase = .syncing
            bobStatus   = "Syncing…"
            carolStatus = "Syncing…"
        }

        // Bob's progress ticks
        let bobTicks: [(Double, Double)] = [
            (2.9, 0.12), (3.2, 0.28), (3.5, 0.44),
            (3.8, 0.61), (4.1, 0.75), (4.4, 0.89), (4.8, 1.0)
        ]
        for (delay, value) in bobTicks {
            after(delay) { withAnimation(.linear(duration: 0.25)) { bobProgress = value } }
        }

        // Carol's progress ticks (slightly offset)
        let carolTicks: [(Double, Double)] = [
            (3.1, 0.09), (3.4, 0.22), (3.7, 0.38),
            (4.0, 0.55), (4.3, 0.70), (4.6, 0.84), (5.1, 1.0)
        ]
        for (delay, value) in carolTicks {
            after(delay) { withAnimation(.linear(duration: 0.25)) { carolProgress = value } }
        }

        after(4.8) { bobStatus   = "Complete — 14 sent · 9 received" }
        after(5.1) { carolStatus = "Complete — 14 sent · 6 received" }
        after(5.4) {
            withAnimation {
                phase   = .done
                summary = "Sync complete. 3 rangers up to date.\n28 records · 0 conflicts"
            }
        }
    }

    private func after(_ seconds: Double, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: block)
    }
}

// MARK: - Peer row
private struct DemoPeerRow: View {
    let name: String
    let status: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "iphone.circle.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name).font(.subheadline.bold())
                    Text(status).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                if progress >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            if progress > 0 && progress < 1.0 {
                ProgressView(value: progress)
                    .tint(.blue)
                    .transition(.opacity)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .animation(.easeInOut, value: progress)
    }
}
