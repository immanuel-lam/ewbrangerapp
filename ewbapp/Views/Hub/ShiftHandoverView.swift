import SwiftUI
import CoreData

struct ShiftHandoverView: View {
    @EnvironmentObject private var appEnv: AppEnvironment

    // Demo data — shows realistic shift content regardless of seeded dates
    private struct DemoShift {
        let sightingsCount = 7
        let untreatedCount = 2
        let speciesBreakdown: [(name: String, color: Color, count: Int)] = [
            ("Lantana", Color(hex: "C4692A"), 3),
            ("Rubber Vine", Color(hex: "8B5E3C"), 2),
            ("Sicklepod", Color(hex: "2A5C3F"), 2)
        ]
        let patrolArea = "Southern Scrub Belt"
        let patrolDuration = "2h 45m"
        let checklistPct = 85
        let supplies: [(name: String, qty: String)] = [
            ("Garlon 600", "2.5 L"),
            ("Access", "1.2 L")
        ]
    }

    private let demo = DemoShift()

    @State private var openTasks: [RangerTask] = []
    @State private var overdueTasks: [RangerTask] = []

    private var currentRanger: RangerProfile? {
        guard let id = appEnv.authManager.currentRangerID else { return nil }
        return try? appEnv.persistence.mainContext.fetchFirst(
            RangerProfile.self,
            predicate: NSPredicate(format: "id == %@", id as CVarArg)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpace.lg) {

                // Header card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentRanger?.displayName ?? "Ranger")
                            .font(DSFont.headline)
                            .foregroundStyle(Color.dsInk)
                        Text(Date(), style: .time)
                            .font(DSFont.caption)
                            .foregroundStyle(Color.dsInk3)
                    }
                    Spacer()
                    VStack(spacing: 3) {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.dsPrimary)
                        Text("End of Shift")
                            .font(DSFont.badge)
                            .foregroundStyle(Color.dsPrimary)
                    }
                }
                .dsCard()
                .padding(.horizontal, DSSpace.lg)

                // Today's Field Activity
                handoverSection(title: "Today's Field Activity", icon: "binoculars.fill") {
                    VStack(spacing: DSSpace.md) {
                        HStack(spacing: DSSpace.lg) {
                            statPill(label: "Sightings", value: "\(demo.sightingsCount)", color: Color.dsPrimary)
                            statPill(label: "Untreated", value: "\(demo.untreatedCount)", color: Color.dsStatusActive)
                        }

                        Divider().overlay(Color.dsDivider)

                        VStack(alignment: .leading, spacing: DSSpace.sm) {
                            Text("Species breakdown")
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)
                            ForEach(demo.speciesBreakdown, id: \.name) { item in
                                HStack(spacing: DSSpace.sm) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 8, height: 8)
                                    Text(item.name)
                                        .font(DSFont.callout)
                                        .foregroundStyle(Color.dsInk)
                                    Spacer()
                                    Text("\(item.count)")
                                        .font(DSFont.callout)
                                        .foregroundStyle(Color.dsInk2)
                                }
                            }
                        }
                    }
                }

                // Patrol Summary
                handoverSection(title: "Patrol Summary", icon: "figure.walk") {
                    VStack(spacing: DSSpace.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Area")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                                Text(demo.patrolArea)
                                    .font(DSFont.subhead)
                                    .foregroundStyle(Color.dsInk)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("Duration")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                                Text(demo.patrolDuration)
                                    .font(DSFont.subhead)
                                    .foregroundStyle(Color.dsInk)
                            }
                        }

                        Divider().overlay(Color.dsDivider)

                        HStack(spacing: DSSpace.md) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Checklist")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                                Text("\(demo.checklistPct)% complete")
                                    .font(DSFont.callout)
                                    .foregroundStyle(Color.dsInk)
                            }
                            Spacer()
                            // Mini progress ring
                            ZStack {
                                Circle()
                                    .stroke(Color.dsDivider, lineWidth: 3)
                                Circle()
                                    .trim(from: 0, to: CGFloat(demo.checklistPct) / 100)
                                    .stroke(Color.dsPrimary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                Text("\(demo.checklistPct)%")
                                    .font(DSFont.badge)
                                    .foregroundStyle(Color.dsInk)
                            }
                            .frame(width: 44, height: 44)
                        }
                    }
                }

                // Supplies Used
                handoverSection(title: "Supplies Used", icon: "flask.fill") {
                    VStack(spacing: 0) {
                        ForEach(Array(demo.supplies.enumerated()), id: \.offset) { idx, item in
                            if idx > 0 {
                                Divider().overlay(Color.dsDivider).padding(.vertical, DSSpace.sm)
                            }
                            HStack {
                                HStack(spacing: DSSpace.sm) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color.dsAccent)
                                    Text(item.name)
                                        .font(DSFont.callout)
                                        .foregroundStyle(Color.dsInk)
                                }
                                Spacer()
                                Text(item.qty)
                                    .font(DSFont.callout)
                                    .foregroundStyle(Color.dsInk2)
                                    .padding(.horizontal, DSSpace.sm)
                                    .padding(.vertical, 3)
                                    .background(Color.dsSurface)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Open Tasks (live from CoreData)
                handoverSection(title: "Open Tasks", icon: "checklist") {
                    VStack(spacing: DSSpace.md) {
                        HStack(spacing: DSSpace.lg) {
                            statPill(label: "Open", value: "\(openTasks.count)", color: Color.dsInk2)
                            statPill(label: "Overdue", value: "\(overdueTasks.count)", color: overdueTasks.isEmpty ? Color.dsInkMuted : Color.dsStatusActive)
                        }
                        if !overdueTasks.isEmpty {
                            Divider().overlay(Color.dsDivider)
                            VStack(alignment: .leading, spacing: DSSpace.sm) {
                                Text("Overdue")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsInk3)
                                ForEach(overdueTasks.prefix(3), id: \.id) { task in
                                    HStack(spacing: DSSpace.sm) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.dsStatusActive)
                                        Text(task.title ?? "Unnamed task")
                                            .font(DSFont.caption)
                                            .foregroundStyle(Color.dsInk)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }

                // Sync Status
                handoverSection(title: "Sync Status", icon: "antenna.radiowaves.left.and.right") {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ready for mesh sync")
                                .font(DSFont.callout)
                                .foregroundStyle(Color.dsInk)
                            Text("Tap Day Sync in Hub to transfer data")
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)
                        }
                        Spacer()
                        DSSyncBadge(status: .pendingCreate)
                    }
                }

                // Share button
                ShareLink(item: shareText) {
                    HStack(spacing: DSSpace.sm) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share Handover Report")
                            .font(DSFont.callout)
                    }
                    .foregroundStyle(Color.dsPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.dsPrimarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
                }
                .padding(.horizontal, DSSpace.lg)
                .padding(.bottom, DSSpace.xxxl)
            }
        }
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationTitle("Shift Handover")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadTasks() }
    }

    // MARK: - Section helper

    @ViewBuilder
    private func handoverSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.dsPrimary)
                Text(title)
                    .font(DSFont.headline)
                    .foregroundStyle(Color.dsInk)
            }
            content()
        }
        .dsCard()
        .padding(.horizontal, DSSpace.lg)
    }

    @ViewBuilder
    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DSFont.title)
                .foregroundStyle(color)
            Text(label)
                .font(DSFont.caption)
                .foregroundStyle(Color.dsInk3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpace.sm)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
    }

    // MARK: - Load live tasks only

    private func loadTasks() {
        guard let rangerID = appEnv.authManager.currentRangerID else { return }
        let ctx = appEnv.persistence.mainContext
        let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "assignedRanger.id == %@", rangerID as CVarArg),
            NSPredicate(format: "isComplete == %@", NSNumber(value: false))
        ])
        openTasks = (try? ctx.fetchAll(RangerTask.self, predicate: pred)) ?? []
        overdueTasks = openTasks.filter { ($0.dueDate ?? .distantFuture) < Date() }
            .sorted { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
    }

    private var shareText: String {
        let name = currentRanger?.displayName ?? "Ranger"
        let df = DateFormatter(); df.dateStyle = .medium
        return """
        Shift Handover — \(name) — \(df.string(from: Date()))

        Sightings: \(demo.sightingsCount) (untreated: \(demo.untreatedCount))
        Patrol: \(demo.patrolArea) · \(demo.patrolDuration) · \(demo.checklistPct)% checklist
        Open tasks: \(openTasks.count)

        Supplies used:
        \(demo.supplies.map { "  \($0.name): \($0.qty)" }.joined(separator: "\n"))

        Ready for mesh sync transfer.
        """
    }
}
