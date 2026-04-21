import SwiftUI
import MapKit

struct MapContainerView: View {
    @EnvironmentObject var appEnv: AppEnvironment
    @StateObject private var viewModel: MapViewModel
    @State private var showLogSheet = false
    @State private var showAddZoneSheet = false

    @State private var actionCard: MapActionCardData?
    @State private var sightingForDetail: SightingLog?
    @State private var zoneForEdit: InfestationZone?

    @State private var drawingZone: InfestationZone?
    @State private var drawVertices: [CLLocationCoordinate2D] = []
    @State private var showZonePicker = false
    @State private var zoneForDetail: InfestationZone?
    @State private var showTimeline = false
    @State private var fabPressed = false
    @State private var showBloomCalendar = false

    init() {
        _viewModel = StateObject(wrappedValue: MapViewModel(
            persistence: AppEnvironment.shared.persistence
        ))
    }

    var isDrawing: Bool { drawingZone != nil }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // MARK: Map
                MapView(
                    mapType: viewModel.mapType,
                    annotations: viewModel.filteredSightings.map { SightingAnnotation(sighting: $0) },
                    patrolAnnotations: viewModel.filteredPatrols,
                    zones: viewModel.zones,
                    showZones: viewModel.showZones,
                    tileOverlay: OfflineTileManager.shared.tileOverlay(),
                    onSelectSighting: { sighting, point in
                        let species = InvasiveSpecies.from(legacyVariant: sighting.variant ?? "")
                        let size = InfestationSize(rawValue: sighting.infestationSize ?? "")?.displayName
                        actionCard = MapActionCardData(
                            title: species.displayName, subtitle: size, anchor: point,
                            species: species,
                            actions: [
                                MapCardAction(label: "View Details", icon: "info.circle", isDestructive: false) {
                                    sightingForDetail = sighting
                                },
                                MapCardAction(label: "Delete", icon: "trash", isDestructive: true) {
                                    deleteSighting(sighting)
                                }
                            ]
                        )
                    },
                    onSelectPatrol: { patrol, point in
                        let date = patrol.startTime.map {
                            let f = DateFormatter(); f.dateStyle = .short; return f.string(from: $0)
                        }
                        actionCard = MapActionCardData(
                            title: patrol.areaName ?? "Patrol", subtitle: date, anchor: point,
                            species: nil,
                            actions: [
                                MapCardAction(label: "Delete", icon: "trash", isDestructive: true) {
                                    deletePatrol(patrol)
                                }
                            ]
                        )
                    },
                    onSelectZone: { zone, point in
                        actionCard = MapActionCardData(
                            title: zone.name ?? "Zone",
                            subtitle: statusLabel(zone.status),
                            anchor: point,
                            species: InvasiveSpecies.from(legacyVariant: zone.dominantVariant ?? ""),
                            actions: [
                                MapCardAction(label: "View Details", icon: "info.circle", isDestructive: false) {
                                    zoneForDetail = zone
                                },
                                MapCardAction(label: "Edit Zone", icon: "pencil", isDestructive: false) {
                                    zoneForEdit = zone
                                },
                                MapCardAction(label: "Delete", icon: "trash", isDestructive: true) {
                                    deleteZone(zone)
                                }
                            ]
                        )
                    },
                    drawVertices: drawVertices,
                    onMapTapped: isDrawing ? { coord in drawVertices.append(coord) } : nil
                )
                .ignoresSafeArea()

                // MARK: Draw mode
                if isDrawing {
                    drawModeBanner
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if !isDrawing {
                    // MARK: Top overlay row
                    VStack {
                        HStack(alignment: .center) {
                            // Stats badge
                            mapStatsBadge
                                .padding(.leading, DSSpace.lg)

                            Spacer()

                            // Bloom calendar button
                            bloomButton
                                .padding(.trailing, DSSpace.sm)

                            // Map type toggle
                            mapTypeButton
                                .padding(.trailing, DSSpace.lg)
                        }
                        .padding(.top, DSSpace.sm)
                        Spacer()
                    }

                    // MARK: Bottom controls
                    VStack(spacing: DSSpace.sm) {
                        Spacer()

                        // Timeline scrubber
                        if showTimeline {
                            TimelineScrubberView(
                                date: $viewModel.timelineDate,
                                range: viewModel.dateRange,
                                isPlaying: viewModel.isPlayingTimeline,
                                onTogglePlay: viewModel.toggleTimeline
                            )
                            .padding(.horizontal, DSSpace.lg)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Bottom control bar
                        mapControlBar
                            .padding(.horizontal, DSSpace.lg)
                            .padding(.bottom, DSSpace.md)
                    }
                }

                // MARK: Action card
                if let card = actionCard {
                    MapActionCard(data: card, screenSize: geo.size) {
                        actionCard = nil
                    }
                    .ignoresSafeArea()
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isDrawing)
            .animation(.spring(duration: 0.2), value: actionCard == nil)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showTimeline)
        }
        .sheet(isPresented: $showLogSheet, onDismiss: { viewModel.load() }) {
            if let rangerID = appEnv.authManager.currentRangerID {
                LogSightingView(rangerID: rangerID)
            }
        }
        .sheet(isPresented: $showAddZoneSheet, onDismiss: { viewModel.load() }) {
            AddZoneView()
        }
        .sheet(item: $sightingForDetail) { sighting in
            NavigationStack { SightingDetailView(sighting: sighting) }
        }
        .sheet(item: $zoneForEdit, onDismiss: { viewModel.load() }) { zone in
            EditZoneView(zone: zone) { viewModel.load() }
        }
        .sheet(item: $zoneForDetail, onDismiss: { viewModel.load() }) { zone in
            NavigationStack { ZoneDetailView(zone: zone) }
        }
        .sheet(isPresented: $showZonePicker) {
            ZonePickerSheet(zones: viewModel.zones) { zone in
                drawingZone = zone; drawVertices = []; showZonePicker = false
            }
        }
        .sheet(isPresented: $showBloomCalendar) {
            BloomCalendarView()
        }
        .onAppear { viewModel.load() }
    }

    // MARK: - Map stats badge

    private var mapStatsBadge: some View {
        HStack(spacing: DSSpace.sm) {
            if viewModel.showSightings && !viewModel.filteredSightings.isEmpty {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.dsStatusActive)
                        .frame(width: 7, height: 7)
                    Text("\(viewModel.filteredSightings.count)")
                        .font(DSFont.caption.weight(.semibold))
                        .foregroundStyle(Color.primary)
                }
            }
            if viewModel.showZones && !viewModel.zones.isEmpty {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(Color.dsStatusTreat)
                        .frame(width: 8, height: 8)
                    Text("\(viewModel.zones.count)")
                        .font(DSFont.caption.weight(.semibold))
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .padding(.horizontal, DSSpace.md)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .opacity((viewModel.filteredSightings.isEmpty && viewModel.zones.isEmpty) ? 0 : 1)
        .onTapGesture { } // no-op; bloom button handles tap
    }

    // MARK: - Bloom calendar button (used in top bar area)

    private var bloomButton: some View {
        Button {
            showBloomCalendar = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Bloom")
                    .font(DSFont.caption)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpace.md)
            .padding(.vertical, 7)
            .background(Color.dsPrimary)
            .clipShape(Capsule())
            .shadow(color: Color.dsPrimary.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Map type button

    private var mapTypeButton: some View {
        Menu {
            Button {
                viewModel.mapType = .satellite
            } label: {
                Label("Satellite", systemImage: viewModel.mapType == .satellite ? "checkmark" : "globe")
            }
            Button {
                viewModel.mapType = .hybrid
            } label: {
                Label("Hybrid", systemImage: viewModel.mapType == .hybrid ? "checkmark" : "globe")
            }
            Button {
                viewModel.mapType = .standard
            } label: {
                Label("Standard", systemImage: viewModel.mapType == .standard ? "checkmark" : "map")
            }
        } label: {
            Image(systemName: mapTypeIcon)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
    }

    // MARK: - Bottom control bar

    private var mapControlBar: some View {
        HStack(spacing: DSSpace.md) {
            // Layer toggles
            LayerToggleView(
                showSightings: $viewModel.showSightings,
                showZones: $viewModel.showZones,
                showPatrols: $viewModel.showPatrols
            )

            Spacer()

            // Timeline clock
            Button {
                withAnimation { showTimeline.toggle() }
            } label: {
                Image(systemName: showTimeline ? "clock.fill" : "clock")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(showTimeline ? Color.dsPrimary : Color.primary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            .buttonStyle(.plain)

            // FAB — Log / Add menu
            Menu {
                Button { showLogSheet = true } label: {
                    Label("Log Sighting", systemImage: "mappin.and.ellipse")
                }
                Button { showAddZoneSheet = true } label: {
                    Label("Add Zone", systemImage: "square.dashed")
                }
                if !viewModel.zones.isEmpty {
                    Button { showZonePicker = true } label: {
                        Label("Draw Zone Boundary", systemImage: "pencil.tip.crop.circle")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                    Text("Log")
                        .font(DSFont.subhead.bold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, DSSpace.lg)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [Color.dsPrimary, Color.dsPrimary.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.dsPrimary.opacity(0.45), radius: 8, x: 0, y: 4)
            }
        }
    }

    // MARK: - Draw mode banner

    private var drawModeBanner: some View {
        VStack(spacing: 0) {
            // Status line
            HStack(spacing: DSSpace.md) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.dsStatusActive)
                            .frame(width: 8, height: 8)
                        Text("Drawing boundary")
                            .font(DSFont.subhead.bold())
                            .foregroundStyle(Color.primary)
                    }
                    Text("\(drawVertices.count) vertices · tap map to add points")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if !drawVertices.isEmpty {
                    Button {
                        drawVertices.removeLast()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Undo")
                                .font(DSFont.callout.weight(.semibold))
                        }
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, DSSpace.md)
                        .padding(.vertical, 8)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpace.lg)
            .padding(.vertical, DSSpace.md)
            .background(.regularMaterial)

            Divider().opacity(0.5)

            // Action buttons
            HStack(spacing: DSSpace.md) {
                Button("Cancel") {
                    drawingZone = nil; drawVertices = []
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.dsStatusActive.opacity(0.1))
                .foregroundStyle(Color.dsStatusActive)
                .font(DSFont.subhead.weight(.semibold))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))

                Button("Save Polygon") { savePolygon() }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(drawVertices.count >= 3 ? Color.dsPrimary : Color.secondary.opacity(0.3))
                    .foregroundStyle(.white)
                    .font(DSFont.subhead.weight(.semibold))
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
                    .disabled(drawVertices.count < 3)
            }
            .padding(.horizontal, DSSpace.lg)
            .padding(.vertical, DSSpace.md)
            .background(.regularMaterial)
        }
    }

    // MARK: - Helpers

    private var mapTypeIcon: String {
        switch viewModel.mapType {
        case .hybrid:   return "globe.americas.fill"
        case .standard: return "map.fill"
        default:        return "globe"
        }
    }

    private func statusLabel(_ status: String?) -> String {
        switch status {
        case "underTreatment": return "Under Treatment"
        case "cleared": return "Cleared"
        default: return "Active"
        }
    }

    private func deleteSighting(_ sighting: SightingLog) {
        Task {
            try? await SightingRepository(persistence: appEnv.persistence).deleteSighting(sighting)
            await MainActor.run { viewModel.load() }
        }
    }

    private func deletePatrol(_ patrol: PatrolRecord) {
        Task {
            try? await PatrolRepository(persistence: appEnv.persistence).deletePatrol(patrol)
            await MainActor.run { viewModel.load() }
        }
    }

    private func deleteZone(_ zone: InfestationZone) {
        Task {
            try? await ZoneRepository(persistence: appEnv.persistence).deleteZone(zone)
            await MainActor.run { viewModel.load() }
        }
    }

    private func savePolygon() {
        guard let zone = drawingZone, drawVertices.count >= 3,
              let rangerID = appEnv.authManager.currentRangerID else { return }
        let coordinates = drawVertices.map { [$0.latitude, $0.longitude] }
        Task {
            try? await ZoneRepository(persistence: appEnv.persistence).addSnapshot(to: zone, coordinates: coordinates, area: 0, rangerID: rangerID)
            try? await Task.sleep(nanoseconds: 150_000_000)
            await MainActor.run { drawingZone = nil; drawVertices = []; viewModel.load() }
        }
    }
}

// MARK: - Zone Picker Sheet

private struct ZonePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let zones: [InfestationZone]
    let onSelect: (InfestationZone) -> Void

    var body: some View {
        NavigationStack {
            List(zones, id: \.id) { zone in
                Button {
                    onSelect(zone)
                } label: {
                    HStack {
                        SpeciesIndicator(species: InvasiveSpecies.from(legacyVariant: zone.dominantVariant ?? ""), size: 12)
                        Text(zone.name ?? "Unnamed Zone")
                        Spacer()
                        Text(zone.status?.capitalized ?? "Active")
                            .font(DSFont.caption).foregroundStyle(Color.dsInk3)
                    }
                }
                .foregroundStyle(Color.dsInk)
            }
            .navigationTitle("Select Zone to Draw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
