import SwiftUI

/// Reusable bloom calendar button for the map view.
/// A small capsule button with leaf icon and "Bloom" label.
struct BloomCalendarButton: View {
    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("Bloom")
                    .font(DSFont.callout.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpace.md)
            .padding(.vertical, 8)
            .background(Color.dsPrimary)
            .clipShape(Capsule())
            .shadow(color: Color.dsPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BloomCalendarButton(isPresented: .constant(false))
}
