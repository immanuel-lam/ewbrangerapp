import SwiftUI

struct OfflineIndicatorView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(DSFont.caption)
            Text("Offline — data saved locally")
                .font(DSFont.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.dsStatusTreat)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous))
    }
}
