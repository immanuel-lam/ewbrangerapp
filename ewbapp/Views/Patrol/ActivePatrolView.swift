import SwiftUI

struct ActivePatrolView: View {
    @ObservedObject var viewModel: PatrolViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: DSSpace.sm) {
                Text(viewModel.activePatrol?.areaName ?? "Active Patrol")
                    .font(DSFont.title)
                    .foregroundStyle(Color.dsInk)

                ProgressView(value: viewModel.completionPercentage)
                    .tint(Color.dsPrimary)

                Text("\(Int(viewModel.completionPercentage * 100))% complete")
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dsInk3)

                // Time Budget
                VStack(spacing: DSSpace.sm) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
                                .fill(Color.dsInk3.opacity(0.1))

                            let totalMinutes = viewModel.plannedMinutes
                            let completedMinutes = viewModel.activeChecklistItems
                                .filter { $0.isComplete }
                                .reduce(0) { $0 + $1.timeEstimateMins }
                            let completedFrac = totalMinutes > 0 ? min(1, Double(completedMinutes) / Double(totalMinutes)) : 0
                            let remainingFrac = totalMinutes > 0 ? min(1 - completedFrac, Double(totalMinutes - completedMinutes) / Double(totalMinutes)) : 0

                            HStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
                                    .fill(Color.dsPrimary)
                                    .frame(width: geometry.size.width * completedFrac)
                                RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
                                    .fill(Color.dsAccent.opacity(0.4))
                                    .frame(width: geometry.size.width * remainingFrac)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(formatTime(viewModel.elapsedMinutes)) elapsed · \(formatTime(viewModel.plannedMinutes)) planned")
                            .font(DSFont.caption)
                            .foregroundStyle(Color.dsInk3)
                        Spacer()
                        if viewModel.plannedMinutes > 0 && viewModel.elapsedMinutes > Int(Double(viewModel.plannedMinutes) * 0.85) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.dsAccent)
                                Text("Running long")
                                    .font(DSFont.caption)
                                    .foregroundStyle(Color.dsAccent)
                            }
                        }
                    }
                }
                .padding(DSSpace.md)
                .background(Color.dsSurface.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
            }
            .padding(DSSpace.lg)
            .background(Color.dsSurface)

            // Checklist
            List {
                ForEach(viewModel.activeChecklistItems) { item in
                    ChecklistItemRow(item: item) {
                        Task { await viewModel.toggleItem(item) }
                    }
                }
            }
            .listStyle(.plain)

            // Finish button
            LargeButton(title: "Finish Patrol", action: {
                Task { await viewModel.finishPatrol() }
            }, color: Color.dsPrimary)
            .padding()
        }
    }

    private func formatTime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}

struct ChecklistItemRow: View {
    let item: PatrolChecklistItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DSSpace.md) {
                Image(systemName: item.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(item.isComplete ? Color.dsPrimary : Color.dsInk3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.label)
                        .font(DSFont.body)
                        .strikethrough(item.isComplete)
                        .foregroundStyle(item.isComplete ? Color.dsInk3 : Color.dsInk)
                    if let time = item.completedAt {
                        Text(time, style: .time)
                            .font(DSFont.caption)
                            .foregroundStyle(Color.dsInk3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !item.isComplete {
                    Text("\(item.timeEstimateMins)m")
                        .font(DSFont.badge)
                        .foregroundStyle(Color.dsInk2)
                        .padding(.horizontal, DSSpace.sm)
                        .padding(.vertical, 4)
                        .background(Color.dsInk.opacity(0.08))
                        .clipShape(Capsule())
                }
            }
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}
