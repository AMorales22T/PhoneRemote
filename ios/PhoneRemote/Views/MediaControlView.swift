import SwiftUI

struct MediaControlView: View {
    @EnvironmentObject var ws: WebSocketService
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Multimedia")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding(.top)
            
            Spacer()
            
            // Main Playback Controls
            HStack(spacing: 40) {
                Button(action: {
                    HapticService.playMedium()
                    ws.send(command: RemoteCommand.PrevTrack())
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    HapticService.playHeavy()
                    ws.send(command: RemoteCommand.PlayPause())
                }) {
                    Image(systemName: "playpause.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .padding()
                        .background(Circle().fill(Color(.systemGray6)))
                }
                
                Button(action: {
                    HapticService.playMedium()
                    ws.send(command: RemoteCommand.NextTrack())
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // YouTube Specific Controls
            VStack(alignment: .leading, spacing: 15) {
                Text("Controles de YouTube")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 15) {
                    YouTubeButton(title: "Retroceder 10s", key: "j", ws: ws)
                    YouTubeButton(title: "Pausa/Play", key: "k", ws: ws)
                    YouTubeButton(title: "Avanzar 10s", key: "l", ws: ws)
                }
                
                Button(action: {
                    HapticService.playMedium()
                    ws.send(command: RemoteCommand.Fullscreen())
                }) {
                    HStack {
                        Image(systemName: "viewfinder")
                        Text("Pantalla Completa (F)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(20)
            .padding(.horizontal)
            
            Spacer()
            
            // Volume Control
            VStack {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: Binding(
                        get: { Double(ws.serverVolume) },
                        set: { 
                            let newVal = Int($0)
                            if abs(newVal - ws.serverVolume) > 2 {
                                ws.serverVolume = newVal
                                ws.send(command: RemoteCommand.SetVolume(v: newVal))
                            }
                        }
                    ), in: 0...100)
                    .accentColor(.purple)
                    Image(systemName: "speaker.wave.3.fill")
                }
                
                Button(action: {
                    HapticService.playLight()
                    ws.send(command: RemoteCommand.Mute())
                }) {
                    Image(systemName: "speaker.slash.fill")
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct YouTubeButton: View {
    let title: String
    let key: String
    let ws: WebSocketService
    
    var body: some View {
        Button(action: {
            HapticService.playLight()
            ws.send(command: RemoteCommand.PressKey(key: key))
        }) {
            VStack {
                Text(key.uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color(.systemGray5))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
