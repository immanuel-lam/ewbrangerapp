import Foundation
import CoreData

/// Last-Write-Wins conflict resolver shared by cloud sync and mesh sync.
struct ConflictResolver {
    struct ZoneBoundaryVersion: Equatable {
        let rangerName: String
        let editedAt: Date
        let areaM2: Int
    }

    struct ZoneMergePreview: Equatable {
        enum BaseVersion: Equatable {
            case mine
            case theirs
        }

        let baseVersion: BaseVersion
        let baseRangerName: String
        let comparedRangerName: String
        let mergedAreaM2: Int
        let areaDeltaM2: Int
        let reviewNote: String
    }

    /// Resolves a conflict between a local CoreData object and incoming server/peer data.
    /// Server wins on all scalar fields. Photo filenames are merged (union, never lost).
    /// Returns true if local record was updated.
    @discardableResult
    static func resolve(
        local: NSManagedObject,
        incomingUpdatedAt: Date,
        incomingApply: (NSManagedObject) -> Void,
        localUpdatedAt: Date,
        localPhotoFilenames: [String]?
    ) -> Bool {
        // On equal timestamps, incoming wins (deterministic tiebreaker)
        guard incomingUpdatedAt >= localUpdatedAt else { return false }
        // Server wins — apply incoming data
        incomingApply(local)
        // Merge photo filenames: union of both arrays
        if let localPhotos = localPhotoFilenames,
           let existingPhotos = local.value(forKey: "photoFilenames") as? [String] {
            let merged = Array(Set(localPhotos).union(Set(existingPhotos)))
            local.setValue(merged, forKey: "photoFilenames")
        }
        return true
    }

    /// First-pass merge strategy for zone boundary conflicts.
    /// The newest edit becomes the draft base geometry while the larger area is preserved as a review cue.
    static func previewZoneMerge(
        mine: ZoneBoundaryVersion,
        theirs: ZoneBoundaryVersion
    ) -> ZoneMergePreview {
        let baseVersion: ZoneMergePreview.BaseVersion
        let base: ZoneBoundaryVersion
        let compared: ZoneBoundaryVersion

        if theirs.editedAt > mine.editedAt {
            baseVersion = .theirs
            base = theirs
            compared = mine
        } else {
            baseVersion = .mine
            base = mine
            compared = theirs
        }

        let mergedAreaM2 = max(mine.areaM2, theirs.areaM2)
        let areaDeltaM2 = abs(mine.areaM2 - theirs.areaM2)
        let reviewNote: String

        if areaDeltaM2 == 0 {
            reviewNote = "Areas match. Keep the newest boundary as the merged draft."
        } else {
            reviewNote = "Using the newest boundary as base. Review the \(areaDeltaM2) m² area difference on the map before finalising."
        }

        return ZoneMergePreview(
            baseVersion: baseVersion,
            baseRangerName: base.rangerName,
            comparedRangerName: compared.rangerName,
            mergedAreaM2: mergedAreaM2,
            areaDeltaM2: areaDeltaM2,
            reviewNote: reviewNote
        )
    }
}
