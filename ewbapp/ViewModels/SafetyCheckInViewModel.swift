import Combine
import CoreData
import Foundation
import UserNotifications

// MARK: - CheckInHistoryEntry
// Lightweight struct representing a past check-in moment (kept in memory; not a separate CoreData entity)
struct CheckInHistoryEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
}

// MARK: - SafetyCheckInViewModel

@MainActor
final class SafetyCheckInViewModel: ObservableObject {
    // MARK: Published state
    @Published var isActive: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var intervalMinutes: Int = 60
    @Published var isOverdue: Bool = false
    @Published var checkInHistory: [CheckInHistoryEntry] = []
    @Published var notificationsAuthorized: Bool = false

    // MARK: Private
    private let persistence: PersistenceController
    private var countdownTimer: Timer?
    private var activeRecord: SafetyCheckIn?

    // Available interval options in minutes
    static let intervalOptions: [Int] = [30, 60, 90, 120]

    init(persistence: PersistenceController) {
        self.persistence = persistence
        restoreActiveSession()
        requestNotificationPermission()
    }

    // MARK: - Public API

    func startTimer(intervalMinutes: Int) {
        stopTimer()
        self.intervalMinutes = intervalMinutes
        self.isOverdue = false

        let context = persistence.mainContext
        let record = SafetyCheckIn(context: context)
        record.id = UUID()
        record.startTime = Date()
        record.intervalMinutes = Int16(intervalMinutes)
        record.isActive = true
        persistence.save(context: context)
        activeRecord = record

        isActive = true
        timeRemaining = TimeInterval(intervalMinutes * 60)
        checkInHistory.removeAll()
        startCountdown()
        scheduleOverdueNotification(after: timeRemaining)
    }

    func checkIn() {
        guard isActive else { return }

        // Cancel any pending overdue notification and reschedule
        cancelPendingNotification()

        let now = Date()
        activeRecord?.lastCheckInTime = now
        if let context = activeRecord?.managedObjectContext {
            persistence.save(context: context)
        }

        // Prepend to history (keep last 5)
        let entry = CheckInHistoryEntry(timestamp: now)
        checkInHistory.insert(entry, at: 0)
        if checkInHistory.count > 5 { checkInHistory = Array(checkInHistory.prefix(5)) }

        isOverdue = false
        timeRemaining = TimeInterval(intervalMinutes * 60)
        scheduleOverdueNotification(after: timeRemaining)
    }

    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        cancelPendingNotification()

        if let record = activeRecord, let context = record.managedObjectContext {
            record.isActive = false
            persistence.save(context: context)
        }
        activeRecord = nil
        isActive = false
        isOverdue = false
        timeRemaining = 0
    }

    // MARK: - Notification permission

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            Task { @MainActor [weak self] in
                self?.notificationsAuthorized = granted
            }
        }
    }

    // MARK: - Countdown

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    if self.timeRemaining == 0 {
                        self.isOverdue = true
                    }
                }
            }
        }
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }

    // MARK: - Local Notifications

    private func scheduleOverdueNotification(after interval: TimeInterval) {
        guard notificationsAuthorized else { return }
        cancelPendingNotification()

        let content = UNMutableNotificationContent()
        content.title = "Safety Check-In Overdue"
        content.body = "You haven't checked in. Are you OK? Open the app to confirm your safety."
        content.sound = .defaultCritical
        content.interruptionLevel = .critical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        let request = UNNotificationRequest(identifier: "safety.checkin.overdue", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("SafetyCheckIn notification error: \(error)")
            }
        }
    }

    private func cancelPendingNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["safety.checkin.overdue"])
    }

    // MARK: - Session restore on launch

    private func restoreActiveSession() {
        let context = persistence.mainContext
        let predicate = NSPredicate(format: "isActive == YES")
        guard let record = try? context.fetchFirst(SafetyCheckIn.self, predicate: predicate) else { return }

        activeRecord = record
        let savedInterval = Int(record.intervalMinutes)
        intervalMinutes = savedInterval

        // Determine how much time has elapsed since the last check-in (or start)
        let reference = record.lastCheckInTime ?? record.startTime ?? Date()
        let elapsed = Date().timeIntervalSince(reference)
        let totalInterval = TimeInterval(savedInterval * 60)
        let remaining = totalInterval - elapsed

        isActive = true
        if remaining > 0 {
            timeRemaining = remaining
            startCountdown()
            scheduleOverdueNotification(after: remaining)
        } else {
            timeRemaining = 0
            isOverdue = true
            startCountdown()
        }
    }

    // MARK: - Formatted helpers

    /// e.g. "14:32" or "1:02:45"
    var timeRemainingFormatted: String {
        let totalSeconds = Int(timeRemaining)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    /// Progress 0.0 → 1.0 for the ring (1.0 = full, 0.0 = depleted)
    var progress: Double {
        let total = Double(intervalMinutes * 60)
        guard total > 0 else { return 0 }
        return min(max(timeRemaining / total, 0), 1)
    }
}
