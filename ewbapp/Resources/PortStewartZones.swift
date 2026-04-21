import Foundation
import CoreLocation

struct PortStewartZones {
    // Approximate GPS centroids for each predefined patrol area around Port Stewart, Cape York
    static let areaCoordinates: [String: CLLocationCoordinate2D] = [
        "North Beach Dunes":       CLLocationCoordinate2D(latitude: -14.677, longitude: 143.702),
        "River Mouth Flats":       CLLocationCoordinate2D(latitude: -14.711, longitude: 143.722),
        "Camping Ground Perimeter":CLLocationCoordinate2D(latitude: -14.700, longitude: 143.699),
        "Airstrip Corridor":       CLLocationCoordinate2D(latitude: -14.720, longitude: 143.690),
        "Southern Scrub Belt":     CLLocationCoordinate2D(latitude: -14.740, longitude: 143.703),
        "Creek Line East":         CLLocationCoordinate2D(latitude: -14.708, longitude: 143.730),
        "Creek Line West":         CLLocationCoordinate2D(latitude: -14.708, longitude: 143.678),
        "Headland Track":          CLLocationCoordinate2D(latitude: -14.688, longitude: 143.718),
        "Mangrove Edge":           CLLocationCoordinate2D(latitude: -14.728, longitude: 143.712),
        "Central Clearing":        CLLocationCoordinate2D(latitude: -14.710, longitude: 143.700),
    ]

    static let patrolAreas: [String] = [
        "North Beach Dunes",
        "River Mouth Flats",
        "Camping Ground Perimeter",
        "Airstrip Corridor",
        "Southern Scrub Belt",
        "Creek Line East",
        "Creek Line West",
        "Headland Track",
        "Mangrove Edge",
        "Central Clearing"
    ]

    static let defaultChecklist: [PatrolChecklistItem] = [
        PatrolChecklistItem(label: "Check GPS is recording", timeEstimateMins: 2),
        PatrolChecklistItem(label: "Photograph new infestations", timeEstimateMins: 15),
        PatrolChecklistItem(label: "Record all invasive plant sightings", timeEstimateMins: 20),
        PatrolChecklistItem(label: "Check previous treatment sites", timeEstimateMins: 15),
        PatrolChecklistItem(label: "Note regrowth on treated plants", timeEstimateMins: 10),
        PatrolChecklistItem(label: "Check herbicide supply before departing", timeEstimateMins: 5)
    ]

    static func defaultChecklist(for area: String) -> [PatrolChecklistItem] {
        var items = Self.defaultChecklist
        items.insert(PatrolChecklistItem(label: "Walk full boundary of \(area)", timeEstimateMins: 20), at: 0)
        return items
    }
}
