import XCTest
import CoreData
import MultipeerConnectivity
@testable import ewbapp

final class MeshSyncReceiveTests: XCTestCase {
    var persistence: PersistenceController!
    var engine: MeshSyncEngine!

    override func setUpWithError() throws {
        persistence = PersistenceController(inMemory: true)
        engine = MeshSyncEngine(persistence: persistence, displayName: "TestDevice")
    }

    // MARK: - diffManifest

    func testDiffManifestReturnsNewerEntries() async {
        let now = Date()
        let theirs = [
            ManifestEntry(entityName: "SightingLog", id: "aaa", updatedAt: now),
            ManifestEntry(entityName: "SightingLog", id: "bbb", updatedAt: now.addingTimeInterval(-200))
        ]
        let mine = [
            ManifestEntry(entityName: "SightingLog", id: "aaa", updatedAt: now.addingTimeInterval(-100)),
            ManifestEntry(entityName: "SightingLog", id: "bbb", updatedAt: now)
        ]
        let diff = await engine.diffManifest(theirs: theirs, mine: mine)
        XCTAssertEqual(diff.count, 1, "Only 'aaa' is newer on their side")
        XCTAssertEqual(diff.first?.id, "aaa")
    }

    func testDiffManifestIncludesNewEntries() async {
        let theirs = [ManifestEntry(entityName: "RangerTask", id: "new-id", updatedAt: Date())]
        let mine: [ManifestEntry] = []
        let diff = await engine.diffManifest(theirs: theirs, mine: mine)
        XCTAssertEqual(diff.count, 1, "Entry I don't have should be included")
    }

    func testDiffManifestExcludesEqualTimestamps() async {
        let now = Date()
        let theirs = [ManifestEntry(entityName: "SightingLog", id: "same", updatedAt: now)]
        let mine = [ManifestEntry(entityName: "SightingLog", id: "same", updatedAt: now)]
        let diff = await engine.diffManifest(theirs: theirs, mine: mine)
        XCTAssertEqual(diff.count, 0, "Equal timestamps should not be included")
    }

    // MARK: - receiveRecords

    func testReceiveSightingSetsSyncedStatus() async {
        let id = UUID()
        let records: [[String: Any]] = [
            ["type": "SightingLog", "id": id.uuidString,
             "latitude": -14.7, "longitude": 143.7,
             "variant": "red", "infestationSize": "small",
             "notes": "test", "createdAt": Date().iso8601String,
             "updatedAt": Date().iso8601String]
        ]
        let data = try! JSONSerialization.data(withJSONObject: records)
        await engine.receiveRecords(data, from: MCPeerID(displayName: "Peer"))

        let context = persistence.backgroundContext
        await context.perform {
            let pred = NSPredicate(format: "id == %@", id as CVarArg)
            let sighting = try? context.fetchFirst(SightingLog.self, predicate: pred)
            XCTAssertNotNil(sighting, "Sighting should be created")
            XCTAssertEqual(sighting?.syncStatus, SyncStatus.synced.rawValue, "Received records should be marked synced")
        }
    }

    func testReceiveTreatmentSetsCreatedAt() async {
        let id = UUID()
        let createdDate = Date().addingTimeInterval(-3600)
        let records: [[String: Any]] = [
            ["type": "TreatmentRecord", "id": id.uuidString,
             "method": "spray", "herbicideProduct": "Glyphosate",
             "outcomeNotes": "", "treatmentDate": Date().iso8601String,
             "createdAt": createdDate.iso8601String,
             "updatedAt": Date().iso8601String, "sightingID": ""]
        ]
        let data = try! JSONSerialization.data(withJSONObject: records)
        await engine.receiveRecords(data, from: MCPeerID(displayName: "Peer"))

        let context = persistence.backgroundContext
        await context.perform {
            let pred = NSPredicate(format: "id == %@", id as CVarArg)
            let treatment = try? context.fetchFirst(TreatmentRecord.self, predicate: pred)
            XCTAssertNotNil(treatment, "Treatment should be created")
            XCTAssertNotNil(treatment?.createdAt, "createdAt must be set from peer data")
            XCTAssertEqual(treatment?.syncStatus, SyncStatus.synced.rawValue)
        }
    }

    func testReceiveTaskUsesIncomingCreatedAt() async {
        let id = UUID()
        let peerCreatedAt = Date().addingTimeInterval(-7200) // 2 hours ago
        let records: [[String: Any]] = [
            ["type": "RangerTask", "id": id.uuidString,
             "title": "Follow up", "notes": "",
             "priority": "high", "isComplete": false,
             "dueDate": "", "createdAt": peerCreatedAt.iso8601String,
             "updatedAt": Date().iso8601String]
        ]
        let data = try! JSONSerialization.data(withJSONObject: records)
        await engine.receiveRecords(data, from: MCPeerID(displayName: "Peer"))

        let context = persistence.backgroundContext
        await context.perform {
            let pred = NSPredicate(format: "id == %@", id as CVarArg)
            let task = try? context.fetchFirst(RangerTask.self, predicate: pred)
            XCTAssertNotNil(task, "Task should be created")
            XCTAssertNotNil(task?.createdAt, "createdAt must be set")
            // createdAt should be close to peerCreatedAt, not Date()
            if let created = task?.createdAt {
                let diff = abs(created.timeIntervalSince(peerCreatedAt))
                XCTAssertLessThan(diff, 2.0, "createdAt should match peer's date, not local Date()")
            }
            XCTAssertEqual(task?.syncStatus, SyncStatus.synced.rawValue)
        }
    }
}
