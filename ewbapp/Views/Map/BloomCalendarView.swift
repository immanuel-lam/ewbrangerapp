import SwiftUI

// MARK: - Risk Level Enum

enum RiskLevel: String {
    case high
    case moderate
    case low

    var color: Color {
        switch self {
        case .high: return Color.dsStatusActive
        case .moderate: return Color.dsAccent
        case .low: return Color.dsInkMuted
        }
    }

    var label: String {
        switch self {
        case .high: return "HIGH RISK"
        case .moderate: return "MODERATE"
        case .low: return "Low"
        }
    }
}

// MARK: - Bloom Calendar View

struct BloomCalendarView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayMonth: Int = {
        Calendar.current.component(.month, from: Date())
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: DSSpace.sm) {
                        HStack {
                            Text(monthName(displayMonth))
                                .font(DSFont.title)
                                .foregroundStyle(Color.dsInk)
                            Spacer()
                        }
                        .padding(.horizontal, DSSpace.lg)

                        HStack(spacing: DSSpace.md) {
                            Button {
                                withAnimation { displayMonth = displayMonth == 1 ? 12 : displayMonth - 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.dsPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.dsSurface)
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text("Active Flowering & Seeding")
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)

                            Spacer()

                            Button {
                                withAnimation { displayMonth = displayMonth == 12 ? 1 : displayMonth + 1 }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.dsPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.dsSurface)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, DSSpace.lg)
                    }
                    .padding(.vertical, DSSpace.lg)
                    .background(Color.dsCard)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
                    .padding(DSSpace.lg)

                    // Species list
                    ScrollView {
                        VStack(spacing: DSSpace.md) {
                            ForEach(InvasiveSpecies.allCases.filter({ $0 != .unknown }), id: \.self) { species in
                                BloomSpeciesCard(species: species, month: displayMonth)
                            }
                        }
                        .padding(DSSpace.lg)
                    }

                    // Bottom note
                    VStack(spacing: DSSpace.sm) {
                        HStack(spacing: DSSpace.sm) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.dsAccent)
                            Text("Treat before seed set to prevent dispersal")
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DSSpace.md)
                        .background(Color.dsAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                    }
                    .padding(DSSpace.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month))!
        return formatter.string(from: date)
    }
}

// MARK: - Bloom Species Card

private struct BloomSpeciesCard: View {
    let species: InvasiveSpecies
    let month: Int

    var body: some View {
        let (description, risk) = riskLevel(for: species, month: month)

        VStack(alignment: .leading, spacing: DSSpace.sm) {
            HStack(spacing: DSSpace.md) {
                Circle()
                    .fill(species.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(species.displayName)
                        .font(DSFont.subhead.weight(.semibold))
                        .foregroundStyle(Color.dsInk)
                    Text(description)
                        .font(DSFont.footnote)
                        .foregroundStyle(Color.dsInk3)
                }

                Spacer()

                riskBadge(risk)
            }
        }
        .padding(DSSpace.md)
        .dsCard(padding: 0)
    }

    @ViewBuilder
    private func riskBadge(_ risk: RiskLevel) -> some View {
        Text(risk.label)
            .font(DSFont.badge)
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpace.sm)
            .padding(.vertical, 4)
            .background(risk.color)
            .clipShape(Capsule())
    }
}

// MARK: - Risk Level Helper

private func riskLevel(for species: InvasiveSpecies, month: Int) -> (description: String, risk: RiskLevel) {
    switch species {
    case .lantana:
        // Peak Oct–Mar (wraps year boundary)
        if month >= 10 || month <= 3 {
            return ("Peak flowering — HIGH RISK", .high)
        } else {
            return ("Flowering year-round", .moderate)
        }

    case .rubberVine:
        if (8...10).contains(month) {
            return ("Flowers now — seeds next", .high)
        } else if month == 11 || month == 12 || month == 1 {
            // Seeds Nov–Jan (wraps year boundary)
            return ("Seeds dispersing — CRITICAL", .high)
        } else {
            return ("Dormant", .low)
        }

    case .pricklyAcacia:
        if (4...7).contains(month) {
            return ("Pods mature & fall — CRITICAL", .high)
        } else {
            return ("Off-season", .low)
        }

    case .sicklepod:
        if (4...9).contains(month) {
            return ("Seeds setting — HIGH RISK", .high)
        } else {
            return ("Wet season growth", .moderate)
        }

    case .giantRatsTailGrass:
        if (3...6).contains(month) {
            return ("Seeds ripen — HIGH RISK", .high)
        } else {
            return ("Off-season", .low)
        }

    case .pondApple:
        if (4...7).contains(month) {
            return ("Fruits develop — moderate risk", .moderate)
        } else {
            return ("Dormant", .low)
        }

    case .unknown:
        return ("Data unavailable", .low)
    }
}

// MARK: - Preview

#Preview {
    BloomCalendarView()
        .environmentObject(AppEnvironment.shared)
}
