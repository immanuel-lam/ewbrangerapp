import AudioToolbox
import Foundation
import UserNotifications
import Combine

@MainActor
final class SafetyCheckInViewModel: ObservableObject {
    @Published var isActive = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var intervalMinutes: Int = 60

    // SOS state
    @Published var isSOSTriggered = false
    @Published var receivedSOSFrom: String? = nil
    @Published var sosDistance: String = "~120m"
    @Published var sosBearing: Double = 0

    private var timer: Timer?
    private var alarmTimer: Timer?
    private var bearingTimer: Timer?
    private var totalTime: TimeInterval { TimeInterval(intervalMinutes * 60) }

    // MARK: - Computed

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return timeRemaining / totalTime
    }

    var timeFormatted: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Actions

    func startTimer() {
        isActive = true
        timeRemaining = totalTime
        scheduleNotification()
        fireTimer()
    }

    func checkIn() {
        guard isActive else { return }
        cancelNotifications()
        timeRemaining = totalTime
        scheduleNotification()
    }

    func stopTimer() {
        isActive = false
        timeRemaining = 0
        timer?.invalidate()
        timer = nil
        cancelNotifications()
    }

    // MARK: - SOS

    func triggerSOS() {
        isActive = false
        timer?.invalidate()
        timer = nil
        isSOSTriggered = true
        startAlarm()
    }

    func dismissSOS() {
        isSOSTriggered = false
        stopAlarm()
        cancelNotifications()
    }

    // MARK: - Demo helpers

    func simulateTimerExpiry() {
        triggerSOS()
    }

    func simulateSOSReceived() {
        receivedSOSFrom = "Bob Smith"
        sosDistance = "~120m"
        sosBearing = 0
        startBearingAnimation()
    }

    func dismissReceivedSOS() {
        receivedSOSFrom = nil
        stopBearingAnimation()
        sosBearing = 0
    }

    // MARK: - Private

    private func fireTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.triggerSOS()
                }
            }
        }
    }

    private func startAlarm() {
        // Fire immediately then repeat every 3 seconds
        fireAlarmSound()
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fireAlarmSound()
            }
        }
    }

    private func fireAlarmSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(1005) // SOS-style alert tone
    }

    private func stopAlarm() {
        alarmTimer?.invalidate()
        alarmTimer = nil
    }

    private func startBearingAnimation() {
        bearingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // Oscillate ±25° around a fixed bearing to simulate live directional update
                let t = Date().timeIntervalSinceReferenceDate
                self.sosBearing = 42 + sin(t * 0.8) * 25
            }
        }
    }

    private func stopBearingAnimation() {
        bearingTimer?.invalidate()
        bearingTimer = nil
    }

    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Safety Check-In Required"
            content.body = "Your check-in timer has expired. Please confirm you are safe."
            content.sound = .defaultCritical

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: self.totalTime,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "safety.checkin",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    private func cancelNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["safety.checkin"])
    }
}
