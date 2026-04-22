import SwiftUI

@main
struct LamaLamaRangersApp: App {
    @StateObject private var appEnv = AppEnvironment.shared
    @StateObject private var safetyCheckInViewModel: SafetyCheckInViewModel

    init() {
        let vm = SafetyCheckInViewModel(persistence: PersistenceController.shared)
        _safetyCheckInViewModel = StateObject(wrappedValue: vm)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnv)
                .environmentObject(appEnv.authManager)
                .environmentObject(safetyCheckInViewModel)
                .onAppear {
                    Task {
                        await appEnv.syncEngine.startMonitoring()
                    }
                }
        }
    }
}
