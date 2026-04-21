import SwiftUI

struct SyncStatusBadge: View {
    let status: SyncStatus

    var body: some View {
        Image(systemName: status.iconSystemName)
            .foregroundStyle(color)
            .font(DSFont.caption)
    }

    private var color: Color {
        switch status {
        case .synced: return Color.dsStatusCleared
        case .pendingCreate, .pendingUpdate: return Color.dsStatusTreat
        case .pendingDelete: return Color.dsStatusActive
        }
    }
}
