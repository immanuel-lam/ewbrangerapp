import SwiftUI

/// Horizontal layer-toggle pill for the map bottom bar.
struct LayerToggleView: View {
    @Binding var showSightings: Bool
    @Binding var showZones: Bool
    @Binding var showPatrols: Bool

    var body: some View {
        HStack(spacing: 0) {
            LayerIconButton(icon: "mappin.circle.fill", label: "Sightings",
                            isOn: $showSightings, color: Color.dsStatusActive)
            layerDivider
            LayerIconButton(icon: "square.dashed", label: "Zones",
                            isOn: $showZones, color: Color.dsStatusTreat)
            layerDivider
            LayerIconButton(icon: "figure.walk", label: "Patrols",
                            isOn: $showPatrols, color: Color.dsPrimary)
        }
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    private var layerDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 0.5, height: 22)
    }
}

private struct LayerIconButton: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { isOn.toggle() }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isOn ? color : Color.primary.opacity(0.3))
                    .scaleEffect(isOn ? 1.0 : 0.88)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isOn)
            }
            .frame(width: 46, height: 44)
            .background(isOn ? color.opacity(0.15) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
