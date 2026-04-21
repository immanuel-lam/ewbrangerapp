import SwiftUI

// MARK: - Zone Conflict Model

struct ZoneConflict: Identifiable {
    let id = UUID()
    let zoneName: String
    let myVersion: ConflictVersion
    let peerVersion: ConflictVersion
    var resolution: ConflictResolution?

    struct ConflictVersion {
        let rangerName: String
        let timeAgo: String
        let areaM2: Int
    }

    enum ConflictResolution {
        case keptMine
        case keptTheirs
        case merged
    }

    // MARK: - Demo Data

    static let demoConflicts: [ZoneConflict] = [
        ZoneConflict(
            zoneName: "Southern Scrub Belt",
            myVersion: ConflictVersion(
                rangerName: "Alice",
                timeAgo: "2 hours ago",
                areaM2: 24500
            ),
            peerVersion: ConflictVersion(
                rangerName: "Bob",
                timeAgo: "45 minutes ago",
                areaM2: 24620
            ),
            resolution: nil
        ),
        ZoneConflict(
            zoneName: "Creek Line East",
            myVersion: ConflictVersion(
                rangerName: "Carol",
                timeAgo: "yesterday",
                areaM2: 18300
            ),
            peerVersion: ConflictVersion(
                rangerName: "Alice",
                timeAgo: "3 hours ago",
                areaM2: 18420
            ),
            resolution: nil
        ),
        ZoneConflict(
            zoneName: "Riparian Buffer",
            myVersion: ConflictVersion(
                rangerName: "Bob",
                timeAgo: "6 hours ago",
                areaM2: 31200
            ),
            peerVersion: ConflictVersion(
                rangerName: "Carol",
                timeAgo: "2 hours ago",
                areaM2: 31100
            ),
            resolution: nil
        )
    ]
}

// MARK: - Conflict Resolver View

struct ConflictResolverView: View {
    @State private var conflicts: [ZoneConflict] = ZoneConflict.demoConflicts
    @State private var showMergeToast = false

    private var unresolvedCount: Int {
        conflicts.filter { $0.resolution == nil }.count
    }

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            VStack(spacing: DSSpace.lg) {
                // Header card
                VStack(alignment: .leading, spacing: DSSpace.sm) {
                    HStack(spacing: DSSpace.md) {
                        Image(systemName: unresolvedCount > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(unresolvedCount > 0 ? Color.dsStatusActive : Color.dsStatusCleared)

                        VStack(alignment: .leading, spacing: 2) {
                            if unresolvedCount > 0 {
                                Text("\(unresolvedCount) conflict\(unresolvedCount == 1 ? "" : "s") need resolution")
                                    .font(DSFont.headline)
                                    .foregroundStyle(Color.dsInk)
                                Text("Zone boundaries edited offline by multiple rangers")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                            } else {
                                Text("All resolved ✓")
                                    .font(DSFont.headline)
                                    .foregroundStyle(Color.dsStatusCleared)
                                Text("Conflict detection enabled · Last sync check complete")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(DSSpace.lg)
                .dsCard(padding: 0)

                // Ambient note
                HStack(spacing: DSSpace.sm) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.dsInk3)
                    Text("Conflict detected during Day Sync · LWW disabled for zone boundaries")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInk3)
                    Spacer()
                }
                .padding(DSSpace.md)
                .background(Color.dsSurface)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))

                // Conflict list
                ScrollView {
                    VStack(spacing: DSSpace.md) {
                        ForEach($conflicts) { $conflict in
                            ConflictCard(conflict: $conflict, onMergeTapped: { showMergeToast = true })
                        }
                    }
                }

                Spacer()
            }
            .padding(DSSpace.lg)

            // Merge toast
            if showMergeToast {
                VStack {
                    Spacer()
                    HStack(spacing: DSSpace.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.dsPrimary)
                        Text("Merge strategy coming in next release")
                            .font(DSFont.callout)
                            .foregroundStyle(Color.dsInk)
                        Spacer()
                    }
                    .padding(DSSpace.md)
                    .background(Color.dsPrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                    .padding(DSSpace.lg)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { showMergeToast = false }
                    }
                }
            }
        }
        .navigationTitle("Zone Conflicts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Conflict Card

private struct ConflictCard: View {
    @Binding var conflict: ZoneConflict
    let onMergeTapped: () -> Void

    var body: some View {
        if let resolution = conflict.resolution {
            // Resolved state — collapsed
            HStack(spacing: DSSpace.md) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.dsStatusCleared)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Resolved: \(conflict.zoneName)")
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.dsInk)
                    Text("Kept \(resolutionLabel(resolution))'s version")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInk3)
                }

                Spacer()
            }
            .padding(DSSpace.md)
            .dsCard(padding: 0)
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        } else {
            // Unresolved state — full card
            VStack(spacing: DSSpace.md) {
                // Title
                HStack(spacing: DSSpace.sm) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.dsAccent)
                    Text(conflict.zoneName)
                        .font(DSFont.headline)
                        .foregroundStyle(Color.dsInk)
                    Spacer()
                }

                Divider().opacity(0.5)

                // Two versions side by side
                HStack(spacing: DSSpace.md) {
                    ConflictVersionView(
                        title: "Your Version",
                        version: conflict.myVersion,
                        isSelected: false
                    )

                    ConflictVersionView(
                        title: "Peer Version",
                        version: conflict.peerVersion,
                        isSelected: false
                    )
                }

                Divider().opacity(0.5)

                // Action buttons
                VStack(spacing: DSSpace.sm) {
                    Button {
                        withAnimation { conflict.resolution = .keptMine }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Keep Mine")
                                .font(DSFont.subhead.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.dsPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                    }

                    HStack(spacing: DSSpace.sm) {
                        Button {
                            withAnimation { conflict.resolution = .keptTheirs }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Keep Theirs")
                                    .font(DSFont.subhead.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.dsAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                        }

                        Button {
                            onMergeTapped()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.merge")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Merge")
                                    .font(DSFont.subhead.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.dsInk3.opacity(0.2))
                            .foregroundStyle(Color.dsInk3)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                        }
                    }
                }
            }
            .padding(DSSpace.md)
            .dsCard(padding: 0)
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    private func resolutionLabel(_ resolution: ZoneConflict.ConflictResolution) -> String {
        switch resolution {
        case .keptMine: return "your"
        case .keptTheirs: return "their"
        case .merged: return "merged"
        }
    }
}

// MARK: - Conflict Version View

private struct ConflictVersionView: View {
    let title: String
    let version: ZoneConflict.ConflictVersion
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            Text(title)
                .font(DSFont.caption.weight(.semibold))
                .foregroundStyle(Color.dsInk3)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.dsPrimary)
                    Text(version.rangerName)
                        .font(DSFont.callout.weight(.semibold))
                        .foregroundStyle(Color.dsInk)
                }

                Text(version.timeAgo)
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dsInk3)

                HStack(spacing: 4) {
                    Image(systemName: "square.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.dsAccent)
                    Text("\(version.areaM2)m²")
                        .font(DSFont.footnote.weight(.semibold))
                        .foregroundStyle(Color.dsInk)
                }
            }
            .padding(DSSpace.sm)
            .background(Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ConflictResolverView()
    }
}
