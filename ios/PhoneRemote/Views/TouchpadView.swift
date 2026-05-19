import SwiftUI

struct TouchpadView: View {
    @EnvironmentObject var ws: WebSocketService
    @State private var sensitivity: Double = 2.0
    
    // For drag state
    @State private var isDragging = false
    @State private var lastDragPosition: CGPoint? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            // Touchpad Area
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("Touchpad")
                    .font(.headline)
                    .foregroundColor(Color(.systemGray3))
                
                // Overlay for gestures
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let last = lastDragPosition {
                                    let dx = Double(value.location.x - last.x) * sensitivity
                                    let dy = Double(value.location.y - last.y) * sensitivity
                                    ws.send(command: RemoteCommand.MouseMove(x: dx, y: dy))
                                }
                                lastDragPosition = value.location
                            }
                            .onEnded { _ in
                                lastDragPosition = nil
                            }
                    )
                    .simultaneousGesture(
                        TapGesture(count: 2).onEnded {
                            HapticService.playMedium()
                            ws.send(command: RemoteCommand.DoubleClick())
                        }
                    )
                    .simultaneousGesture(
                        TapGesture(count: 1).onEnded {
                            HapticService.playLight()
                            ws.send(command: RemoteCommand.MouseClick(b: "left"))
                        }
                    )
            }
            .frame(maxHeight: .infinity)
            .padding()
            
            // Mouse Buttons
            HStack(spacing: 20) {
                Button(action: {
                    HapticService.playMedium()
                    ws.send(command: RemoteCommand.MouseClick(b: "left"))
                }) {
                    Text("Click Izquierdo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                }
                
                Button(action: {
                    HapticService.playMedium()
                    ws.send(command: RemoteCommand.MouseClick(b: "right"))
                }) {
                    Text("Click Derecho")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            // Sensitivity Slider
            HStack {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(.gray)
                Slider(value: $sensitivity, in: 0.5...4.0, step: 0.1)
                    .accentColor(.purple)
                Image(systemName: "hare.fill")
                    .foregroundColor(.gray)
            }
            .padding()
            
            Spacer().frame(height: 20)
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}
