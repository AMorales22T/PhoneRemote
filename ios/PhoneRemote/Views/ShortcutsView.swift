import SwiftUI

struct ShortcutsView: View {
    @EnvironmentObject var ws: WebSocketService
    @State private var showingPowerAlert = false
    @State private var powerAction: (() -> Void)?
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("Atajos")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Apps Section
                    VStack(alignment: .leading) {
                        Text("Aplicaciones")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ShortcutCard(title: "YouTube", icon: "play.rectangle.fill", color: .red) {
                                ws.send(command: RemoteCommand.OpenApp(app: "youtube"))
                            }
                            ShortcutCard(title: "Netflix", icon: "film.fill", color: .red) {
                                ws.send(command: RemoteCommand.OpenApp(app: "netflix"))
                            }
                            ShortcutCard(title: "Spotify", icon: "music.note", color: .green) {
                                ws.send(command: RemoteCommand.OpenApp(app: "spotify"))
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Power Section
                    VStack(alignment: .leading) {
                        Text("Sistema")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ShortcutCard(title: "Apagar Pantalla", icon: "display", color: .blue) {
                                confirmAction(title: "Apagar Pantalla", message: "¿Seguro que quieres apagar la pantalla del PC?") {
                                    ws.send(command: RemoteCommand.ScreenOff())
                                }
                            }
                            ShortcutCard(title: "Suspender", icon: "moon.zzz.fill", color: .purple) {
                                confirmAction(title: "Suspender PC", message: "¿Seguro que quieres suspender el PC?") {
                                    ws.send(command: RemoteCommand.SleepPC())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingPowerAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Aceptar")) {
                    powerAction?()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
    }
    
    private func confirmAction(title: String, message: String, action: @escaping () -> Void) {
        alertTitle = title
        alertMessage = message
        powerAction = action
        showingPowerAlert = true
        HapticService.playHeavy()
    }
}

struct ShortcutCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.playMedium()
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .foregroundColor(.white)
            .cornerRadius(15)
        }
    }
}
