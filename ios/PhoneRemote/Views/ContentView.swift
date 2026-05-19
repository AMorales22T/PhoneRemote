import SwiftUI

struct ContentView: View {
    @EnvironmentObject var webSocketService: WebSocketService
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            if webSocketService.isConnected {
                VStack(spacing: 0) {
                    ConnectionStatusBar()
                    
                    TabView {
                        TouchpadView()
                            .tabItem {
                                Label("Touchpad", systemImage: "hand.draw.fill")
                            }
                        
                        KeyboardView()
                            .tabItem {
                                Label("Teclado", systemImage: "keyboard.fill")
                            }
                        
                        MediaControlView()
                            .tabItem {
                                Label("Media", systemImage: "play.circle.fill")
                            }
                        
                        ShortcutsView()
                            .tabItem {
                                Label("Atajos", systemImage: "square.grid.2x2.fill")
                            }
                    }
                    .accentColor(.purple)
                }
            } else {
                QRScannerView()
            }
        }
    }
}

struct ConnectionStatusBar: View {
    @EnvironmentObject var ws: WebSocketService
    
    var body: some View {
        HStack {
            Circle()
                .fill(ws.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(ws.isConnected ? "Conectado" : "Desconectado")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}
