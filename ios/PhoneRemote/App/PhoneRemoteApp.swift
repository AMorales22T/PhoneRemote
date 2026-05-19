import SwiftUI

@main
struct PhoneRemoteApp: App {
    @StateObject private var webSocketService = WebSocketService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(webSocketService)
                .preferredColorScheme(.dark)
        }
    }
}
