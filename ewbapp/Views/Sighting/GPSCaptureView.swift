import SwiftUI
import CoreLocation

struct GPSCaptureView: View {
    let location: CLLocation?
    let accuracyLevel: LocationManager.AccuracyLevel
    let onRecapture: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(DSFont.headline)
            HStack {
                if let location = location {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude))
                            .font(DSFont.mono)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(accuracyColor)
                                .frame(width: 8, height: 8)
                            Text(String(format: "±%.0fm", location.horizontalAccuracy))
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dsInk3)
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Acquiring GPS…")
                            .font(DSFont.callout)
                            .foregroundStyle(Color.dsInk3)
                    }
                }
                Spacer()
                Button("Re-capture", action: onRecapture)
                    .font(DSFont.callout)
                    .buttonStyle(.bordered)
            }
            .padding(DSSpace.md)
            .background(Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        }
    }

    private var accuracyColor: Color {
        switch accuracyLevel {
        case .good: return Color.dsStatusCleared
        case .fair: return Color.dsStatusTreat
        case .poor: return Color.dsStatusActive
        case .unknown: return Color.dsInk3
        }
    }
}
