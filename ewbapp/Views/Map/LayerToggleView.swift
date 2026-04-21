import SwiftUI

struct LayerToggleView: View {
    @Binding var showSightings: Bool
    @Binding var showZones: Bool
    @Binding var showPatrols: Bool

    var body: some View {
        VStack(spacing: 0) {
            LayerIconButton(icon: "mappin.circle.fill", isOn: $showSightings, color: Color.dsStatusActive)
            Divider().frame(width: 28)
            LayerIconButton(icon: "square.dashed", isOn: $showZones, color: Color.dsStatusTreat)
            Divider().frame(width: 28)
            LayerIconButton(icon: "figure.walk", isOn: $showPatrols, color: Color.dsPrimary)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

private struct LayerIconButton: View {
    let icon: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isOn ? color : Color.dsInk3.opacity(0.5))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }
}
