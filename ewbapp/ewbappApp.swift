import SwiftUI

@main
struct LamaLamaRangersApp: App {
    @StateObject private var appEnv = AppEnvironment.shared
    @StateObject private var themeVM = AppThemeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnv)
                .environmentObject(appEnv.authManager)
                .environmentObject(themeVM)
                .preferredColorScheme(themeVM.colorScheme)
                .modifier(RedLightModifier(isActive: themeVM.isRedLightMode))
                .onAppear {
                    Task {
                        await appEnv.syncEngine.startMonitoring()
                    }
                }
        }
    }
}
