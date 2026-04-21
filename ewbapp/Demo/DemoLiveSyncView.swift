import SwiftUI
import CoreData

// MARK: - DemoLiveSyncView
// Fake V3 cloud sync dashboard — Supabase DB + S3 photo storage.
// Uses real CoreData counts to drive the numbers.

struct DemoLiveSyncView: View {
    @EnvironmentObject private var appEnv: AppEnvironment

    enum SyncPhase { case idle, connecting, syncing, done, failed }

    // Connection
    @State private var phase: SyncPhase = .idle
    @State private var supabaseLatency: Int? = nil
    @State private var s3Latency: Int? = nil
    @State private var supabaseConnected = false
    @State private var s3Connected = false

    // Table sync progress  (keyed by table name)
    @State private var tableProgress: [String: TableSyncState] = [:]

    // Photo upload — Supabase Storage (primary) + S3 replica (backup)
    @State private var photosTotal: Int = 0
    @State private var photosSynced: Int = 0       // uploaded to Supabase Storage
    @State private var photosReplicated: Int = 0   // copied to S3 backup
    @State private var photoBytes: Double = 0      // MB
    @State private var uploadSpeedMBps: Double = 0 // live throughput shown to user
    @State private var s3SpeedMBps: Double = 0
    // S3 DB snapshot (pg_dump export — fires after tables finish)
    @State private var dbSnapshotProgress: Double = 0
    @State private var dbSnapshotDone: Bool = false
    @State private var dbSnapshotSizeMB: Double = 0

    // Event log
    @State private var logLines: [LogLine] = []

    // Totals from CoreData
    private var counts: RecordCounts {
        let ctx = appEnv.persistence.mainContext
        return RecordCounts(
            sightings:  ((try? ctx.fetchAll(SightingLog.self))   ?? []).count,
            treatments: ((try? ctx.fetchAll(TreatmentRecord.self)) ?? []).count,
            patrols:    ((try? ctx.fetchAll(PatrolRecord.self))  ?? []).count,
            tasks:      ((try? ctx.fetchAll(RangerTask.self))    ?? []).count,
            zones:      ((try? ctx.fetchAll(InfestationZone.self)) ?? []).count
        )
    }

    private let tables: [(key: String, label: String, icon: String)] = [
        ("sightings",         "sighting_logs",      "binoculars.fill"),
        ("treatments",        "treatment_records",  "cross.vial.fill"),
        ("patrols",           "patrol_records",     "figure.walk"),
        ("tasks",             "ranger_tasks",       "checkmark.circle.fill"),
        ("zones",             "infestation_zones",  "square.dashed"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpace.lg) {
                // Status banner
                statusBanner

                // Service cards
                HStack(spacing: DSSpace.md) {
                    ServiceCard(
                        name: "Supabase",
                        detail: "yac-rangers.supabase.co",
                        badge: "DB + Storage",
                        icon: "cylinder.split.1x2.fill",
                        color: Color(hex: "3ECF8E"),
                        connected: supabaseConnected,
                        latency: supabaseLatency
                    )
                    ServiceCard(
                        name: "S3 Backup",
                        detail: "yac-rangers-replica",
                        badge: "DB + Photos",
                        icon: "externaldrive.fill",
                        color: Color(hex: "FF9900"),
                        connected: s3Connected,
                        latency: s3Latency
                    )
                }

                // Table sync
                if !tableProgress.isEmpty {
                    tableSection
                }

                // Photo upload
                if phase == .syncing || phase == .done {
                    photoSection
                }

                // Event log
                if !logLines.isEmpty {
                    logSection
                }

                // Action button
                actionButton
                    .padding(.bottom, DSSpace.xl)
            }
            .padding(.horizontal, DSSpace.lg)
            .padding(.top, DSSpace.md)
        }
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationTitle("Cloud Sync")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { cancelSync() }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: DSSpace.sm) {
            ZStack {
                Circle()
                    .fill(bannerColor.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .scaleEffect(phase == .syncing ? 1.4 : 1)
                    .animation(
                        phase == .syncing
                            ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
                            : .default,
                        value: phase == .syncing
                    )
                Circle()
                    .fill(bannerColor)
                    .frame(width: 10, height: 10)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(bannerTitle)
                    .font(DSFont.subhead.bold())
                    .foregroundStyle(Color.dsInk)
                Text(bannerSubtitle)
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dsInk3)
            }

            Spacer()

            if phase == .done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.dsStatusCleared)
                    .font(.system(size: 20))
                    .transition(.scale.combined(with: .opacity))
            }
            if phase == .failed {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.dsStatusActive)
                    .font(.system(size: 20))
            }
        }
        .padding(DSSpace.md)
        .background(Color.dsCard)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .strokeBorder(bannerColor.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: phase == .syncing)
    }

    // MARK: - Table Section

    private var tableSection: some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            Label("Database Tables", systemImage: "tablecells.fill")
                .font(DSFont.headline)
                .foregroundStyle(Color.dsInk)

            VStack(spacing: DSSpace.xs) {
                ForEach(tables, id: \.key) { table in
                    if let state = tableProgress[table.key] {
                        TableRow(
                            icon: table.icon,
                            tableName: table.label,
                            total: state.total,
                            synced: state.synced,
                            status: state.status
                        )
                    }
                }
            }
        }
        .dsCard()
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: DSSpace.md) {
            Label("Backup & Storage", systemImage: "externaldrive.fill.badge.checkmark")
                .font(DSFont.headline)
                .foregroundStyle(Color.dsInk)

            // S3 DB Snapshot (shown once it starts)
            if dbSnapshotProgress > 0 {
                VStack(alignment: .leading, spacing: DSSpace.sm) {
                    HStack {
                        HStack(spacing: 5) {
                            Circle().fill(Color(hex: "FF9900")).frame(width: 7, height: 7)
                            Text("S3 DB Snapshot")
                                .font(DSFont.callout.bold())
                                .foregroundStyle(Color.dsInk)
                            Text("pg_dump")
                                .font(DSFont.badge)
                                .foregroundStyle(Color(hex: "FF9900"))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color(hex: "FF9900").opacity(0.12))
                                .clipShape(Capsule())
                        }
                        Spacer()
                        if dbSnapshotDone {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.dsStatusCleared)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    ProgressView(value: dbSnapshotProgress)
                        .tint(dbSnapshotDone ? Color.dsStatusCleared : Color(hex: "FF9900"))
                        .scaleEffect(x: 1, y: 1.3, anchor: .center)
                        .animation(.easeInOut(duration: 0.25), value: dbSnapshotProgress)
                    Text(dbSnapshotDone
                         ? String(format: "snapshot.sql.gz  ·  %.1f MB", dbSnapshotSizeMB)
                         : String(format: "exporting…  %.1f MB", dbSnapshotSizeMB))
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInk3)
                        .contentTransition(.numericText())
                }
                .transition(.move(edge: .top).combined(with: .opacity))

                Divider().overlay(Color.dsDivider)
            }

            // Primary — Supabase Storage
            VStack(alignment: .leading, spacing: DSSpace.sm) {
                HStack {
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: "3ECF8E")).frame(width: 7, height: 7)
                        Text("Supabase Storage")
                            .font(DSFont.callout.bold())
                            .foregroundStyle(Color.dsInk)
                    }
                    Spacer()
                    Text("\(photosSynced) / \(photosTotal)")
                        .font(DSFont.callout.bold())
                        .foregroundStyle(Color(hex: "3ECF8E"))
                        .contentTransition(.numericText())
                }
                ProgressView(value: photosTotal > 0 ? Double(photosSynced) / Double(photosTotal) : 0)
                    .tint(Color(hex: "3ECF8E"))
                    .scaleEffect(x: 1, y: 1.3, anchor: .center)
                    .animation(.spring(response: 0.4), value: photosSynced)
                HStack {
                    Text(String(format: "%.1f MB  ·  primary", photoBytes))
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInk3)
                        .contentTransition(.numericText())
                    Spacer()
                    if uploadSpeedMBps > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 9, weight: .bold))
                            Text(String(format: "%.1f MB/s", uploadSpeedMBps))
                                .font(.system(size: 11, design: .monospaced).bold())
                                .contentTransition(.numericText())
                        }
                        .foregroundStyle(Color(hex: "3ECF8E"))
                    }
                }
            }

            Divider().overlay(Color.dsDivider)

            // Secondary — S3 redundancy replica (lags ~3 photos behind)
            VStack(alignment: .leading, spacing: DSSpace.sm) {
                HStack {
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: "FF9900")).frame(width: 7, height: 7)
                        Text("S3 Replica")
                            .font(DSFont.callout.bold())
                            .foregroundStyle(Color.dsInk)
                        Text("backup")
                            .font(DSFont.badge)
                            .foregroundStyle(Color(hex: "FF9900"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FF9900").opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text("\(photosReplicated) / \(photosTotal)")
                        .font(DSFont.callout.bold())
                        .foregroundStyle(Color(hex: "FF9900"))
                        .contentTransition(.numericText())
                }
                ProgressView(value: photosTotal > 0 ? Double(photosReplicated) / Double(photosTotal) : 0)
                    .tint(Color(hex: "FF9900"))
                    .scaleEffect(x: 1, y: 1.3, anchor: .center)
                    .animation(.spring(response: 0.4), value: photosReplicated)
                HStack {
                    Text("cold replica  ·  versioned")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dsInk3)
                    Spacer()
                    if s3SpeedMBps > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 9, weight: .bold))
                            Text(String(format: "%.1f MB/s", s3SpeedMBps))
                                .font(.system(size: 11, design: .monospaced).bold())
                                .contentTransition(.numericText())
                        }
                        .foregroundStyle(Color(hex: "FF9900"))
                    }
                }
            }
        }
        .dsCard()
    }

    // MARK: - Log Section

    private var logSection: some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            Label("Sync Log", systemImage: "terminal.fill")
                .font(DSFont.headline)
                .foregroundStyle(Color.dsInk)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(logLines.prefix(12)) { line in
                    HStack(alignment: .top, spacing: DSSpace.sm) {
                        Text(line.timestamp)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color.dsInkMuted)
                            .frame(width: 55, alignment: .leading)
                        Text(line.message)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(line.isError ? Color.dsStatusActive : Color(hex: "3ECF8E"))
                            .lineLimit(1)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(DSSpace.md)
            .background(Color(hex: "0D1117"))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        }
        .dsCard()
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            switch phase {
            case .idle, .done, .failed: startSync()
            default: break
            }
        } label: {
            HStack(spacing: DSSpace.sm) {
                if phase == .connecting || phase == .syncing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                }
                Text(buttonLabel)
                    .font(DSFont.subhead.bold())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(buttonColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
            .shadow(color: buttonColor.opacity(0.35), radius: 6, y: 3)
        }
        .disabled(phase == .connecting || phase == .syncing)
        .animation(.easeInOut(duration: 0.2), value: phase == .syncing)
    }

    // MARK: - Computed

    private var bannerColor: Color {
        switch phase {
        case .idle:       return Color.dsInk3
        case .connecting: return Color(hex: "3ECF8E")
        case .syncing:    return Color(hex: "3ECF8E")
        case .done:       return Color.dsStatusCleared
        case .failed:     return Color.dsStatusActive
        }
    }

    private var bannerTitle: String {
        switch phase {
        case .idle:       return "Not connected"
        case .connecting: return "Connecting to Supabase…"
        case .syncing:    return "Sync in progress"
        case .done:       return "Sync complete"
        case .failed:     return "Connection failed"
        }
    }

    private var bannerSubtitle: String {
        switch phase {
        case .idle:       return "V3 cloud backend — tap Sync to connect"
        case .connecting: return "Establishing secure connection…"
        case .syncing:
            let done = tableProgress.values.filter { $0.status == .done }.count
            return "\(done)/\(tables.count) tables complete"
        case .done:
            let total = tableProgress.values.reduce(0) { $0 + $1.total }
            return "\(total) records · \(photosSynced) photos in Supabase · \(photosReplicated) replicated to S3"
        case .failed:
            return "Check network connection and try again"
        }
    }

    private var buttonLabel: String {
        switch phase {
        case .idle:       return "Sync to Cloud"
        case .connecting: return "Connecting…"
        case .syncing:    return "Syncing…"
        case .done:       return "Sync Again"
        case .failed:     return "Retry"
        }
    }

    private var buttonColor: Color {
        phase == .failed ? Color.dsStatusActive : Color(hex: "3ECF8E")
    }

    // MARK: - Sync Orchestration

    private func startSync() {
        let c = counts
        phase = .connecting
        supabaseConnected = false
        s3Connected = false
        supabaseLatency = nil
        s3Latency = nil
        tableProgress = [:]
        logLines = []
        photosSynced = 0
        photosReplicated = 0
        photosTotal = c.sightings
        photoBytes = 0
        uploadSpeedMBps = 0
        s3SpeedMBps = 0
        dbSnapshotProgress = 0
        dbSnapshotDone = false
        dbSnapshotSizeMB = 0

        appendLog("Resolving yac-rangers.supabase.co…")

        after(0.6) {
            supabaseLatency = Int.random(in: 18...42)
            supabaseConnected = true
            appendLog("Supabase  latency=\(supabaseLatency!)ms  tls=1.3")
        }
        after(1.0) {
            s3Latency = Int.random(in: 55...120)
            s3Connected = true
            appendLog("S3 replica  latency=\(s3Latency!)ms  cold-standby")
        }
        after(1.3) {
            phase = .syncing
            appendLog("BEGIN TRANSACTION")
            startTableSync(c: c)
        }
    }

    private func startTableSync(c: RecordCounts) {
        let specs: [(key: String, total: Int)] = [
            ("sightings",   c.sightings),
            ("treatments",  c.treatments),
            ("patrols",     c.patrols),
            ("tasks",       c.tasks),
            ("zones",       c.zones),
        ]

        var tableDelay = 1.5
        for spec in specs {
            let key = spec.key
            let total = spec.total
            let startDelay = tableDelay
            tableDelay += Double.random(in: 0.8...1.4)

            after(startDelay) {
                withAnimation {
                    tableProgress[key] = TableSyncState(total: total, synced: 0, status: .syncing)
                }
                appendLog("UPSERT \(tableName(key))  \(total) rows")
            }

            // Tick synced count up
            let tickCount = min(total, 6)
            let tickDelay = (tableDelay - startDelay - 0.2) / Double(max(tickCount, 1))
            for tick in 1...max(tickCount, 1) {
                let frac = Double(tick) / Double(tickCount)
                let synced = Int(ceil(Double(total) * frac))
                after(startDelay + Double(tick) * tickDelay) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tableProgress[key]?.synced = min(synced, total)
                    }
                }
            }

            after(tableDelay - 0.1) {
                withAnimation {
                    tableProgress[key]?.status = .done
                    tableProgress[key]?.synced = total
                }
                appendLog("OK  \(tableName(key))  \(total)/\(total)")
            }
        }

        // Photo uploads start after first table
        startPhotoSync(startDelay: 2.0, total: c.sightings)

        // DB snapshot export to S3 — starts after all tables done
        let snapshotStart = tableDelay + 0.4
        let totalRows = c.sightings + c.treatments + c.patrols + c.tasks + c.zones
        let snapshotMB = Double(totalRows) * 0.08  // ~80 KB per row
        let snapshotTicks = 8
        appendLog("pg_dump → s3://yac-rangers-replica/db/")
        for tick in 1...snapshotTicks {
            after(snapshotStart + Double(tick) * 0.3) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    dbSnapshotProgress = Double(tick) / Double(snapshotTicks)
                    dbSnapshotSizeMB = snapshotMB * Double(tick) / Double(snapshotTicks)
                }
                if tick == snapshotTicks {
                    dbSnapshotDone = true
                    appendLog("snapshot.sql.gz  \(String(format: "%.1f", snapshotMB))MB  OK")
                }
            }
        }

        // Finish after snapshot completes
        after(snapshotStart + Double(snapshotTicks) * 0.3 + 0.3) {
            appendLog("COMMIT")
            appendLog("Sync complete  \(totalRows) rows")
            withAnimation { phase = .done }
        }
    }

    private func startPhotoSync(startDelay: Double, total: Int) {
        guard total > 0 else { return }
        let mbPerPhoto = 1.2
        let interval = 0.45          // single tick drives primary, replica, AND speed together
        let replicaTickLag = 4       // replica runs this many ticks behind

        // Starlink-style speed profile in MB/s — ramp, jitter, occasional dip
        let speedProfile: [Double] = [
            0, 2.1, 5.4, 8.2, 11.3, 9.7, 12.1, 7.8, 13.4, 10.2,
            14.1, 6.3, 11.8, 13.0, 9.1, 1.4, 2.8, 10.5, 12.7, 11.9,
            8.4, 13.2, 7.6, 11.0, 9.8, 4.2, 12.5, 10.9, 13.8, 0
        ]
        // Pre-compute S3 multipliers so they don't change on re-render
        let s3Mult: [Double] = speedProfile.map { _ in Double.random(in: 0.30...0.52) }

        let totalTicks = total + replicaTickLag + 1
        for tick in 1...totalTicks {
            let primary   = min(tick, total)
            let replica   = max(0, min(tick - replicaTickLag, total))
            let sIdx      = min(tick - 1, speedProfile.count - 1)
            let pSpeed    = tick <= total ? speedProfile[sIdx] : 0.0
            let rSpeed    = tick <= total ? speedProfile[sIdx] * s3Mult[sIdx] : 0.0
            let logPrimary = primary > 0 && (primary % 5 == 0 || primary == total)
            let logReplica = replica > 0 && (replica % 7 == 0 || replica == total)

            after(startDelay + Double(tick) * interval) {
                // Single withAnimation per tick — one layout pass
                withAnimation(.easeInOut(duration: 0.3)) {
                    photosSynced    = primary
                    photoBytes      = Double(primary) * mbPerPhoto
                    photosReplicated = replica
                    uploadSpeedMBps = pSpeed
                    s3SpeedMBps     = rSpeed
                }
                // Log inserts are instant — no animation needed in a terminal view
                if logPrimary {
                    appendLog("PUT storage/photos/img_\(primary).jpg  \(String(format: "%.1f", mbPerPhoto))MB")
                }
                if logReplica {
                    appendLog("REPLICATE img_\(replica).jpg → s3://yac-rangers-replica")
                }
            }
        }
    }

    private func cancelSync() { /* timers fire and complete naturally */ }

    private func appendLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let line = LogLine(id: UUID(), timestamp: formatter.string(from: Date()),
                           message: message, isError: false)
        // No animation — instant insert keeps the terminal feel and avoids extra layout passes
        logLines.insert(line, at: 0)
        if logLines.count > 20 { logLines.removeLast() }
    }

    private func tableName(_ key: String) -> String {
        tables.first { $0.key == key }?.label ?? key
    }

    private func after(_ seconds: Double, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: block)
    }
}

// MARK: - Supporting Models

private struct RecordCounts {
    let sightings, treatments, patrols, tasks, zones: Int
}

struct TableSyncState {
    var total: Int
    var synced: Int
    var status: Status
    enum Status { case pending, syncing, done }
}

private struct LogLine: Identifiable {
    let id: UUID
    let timestamp: String
    let message: String
    let isError: Bool
}

// MARK: - Service Card

private struct ServiceCard: View {
    let name: String
    let detail: String
    let badge: String
    let icon: String
    let color: Color
    let connected: Bool
    let latency: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpace.sm) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
                Circle()
                    .fill(connected ? Color.dsStatusCleared : Color.dsInk3.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(DSFont.subhead.bold())
                    .foregroundStyle(Color.dsInk)
                Text(badge)
                    .font(DSFont.badge)
                    .foregroundStyle(color)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }
            Text(detail)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color.dsInk3)
                .lineLimit(1)
            if let ms = latency {
                Text("\(ms) ms")
                    .font(DSFont.caption.bold())
                    .foregroundStyle(color)
            } else {
                Text("—")
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dsInkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsCard(padding: DSSpace.md)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .strokeBorder(connected ? color.opacity(0.3) : Color.dsDivider.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Table Row

private struct TableRow: View {
    let icon: String
    let tableName: String
    let total: Int
    let synced: Int
    let status: TableSyncState.Status

    private var fraction: Double {
        total > 0 ? Double(synced) / Double(total) : 0
    }

    var body: some View {
        HStack(spacing: DSSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.dsPrimary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(tableName)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.dsInk)
                    Spacer()
                    Text("\(synced)/\(total)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.dsInk3)
                        .contentTransition(.numericText())
                }
                if status == .syncing || status == .done {
                    ProgressView(value: fraction)
                        .tint(status == .done ? Color.dsStatusCleared : Color(hex: "3ECF8E"))
                        .scaleEffect(x: 1, y: 0.9, anchor: .center)
                        .animation(.spring(response: 0.4), value: fraction)
                }
            }

            // Status icon
            Group {
                switch status {
                case .pending:
                    Image(systemName: "clock")
                        .foregroundStyle(Color.dsInkMuted)
                case .syncing:
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(Color(hex: "3ECF8E"))
                case .done:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.dsStatusCleared)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .font(.system(size: 14))
            .frame(width: 18)
        }
        .padding(.vertical, 4)
    }
}
