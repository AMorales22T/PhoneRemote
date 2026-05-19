import SwiftUI

struct KeyboardView: View {
    @EnvironmentObject var ws: WebSocketService
    @State private var typedText: String = ""
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Teclado")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding(.top)
            
            // Text preview area
            VStack {
                Text(typedText.isEmpty ? "Escribe algo..." : typedText)
                    .foregroundColor(typedText.isEmpty ? .gray : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            // Hidden text field to capture input natively
            TextField("", text: $typedText)
                .focused($isKeyboardFocused)
                .opacity(0)
                .frame(height: 0)
                .onChange(of: typedText) { newValue in
                    if !newValue.isEmpty {
                        // Send the last typed character
                        if let lastChar = newValue.last {
                            ws.send(command: RemoteCommand.TypeText(text: String(lastChar)))
                        }
                    }
                }
            
            Button(action: {
                isKeyboardFocused = true
                HapticService.playLight()
            }) {
                HStack {
                    Image(systemName: "keyboard")
                    Text(isKeyboardFocused ? "Escribiendo..." : "Toca para abrir teclado")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isKeyboardFocused ? Color.purple.opacity(0.5) : Color.purple)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
            // Special keys
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                SpecialKeyButton(title: "Enter", icon: "return", keyName: "enter", ws: ws)
                SpecialKeyButton(title: "Borrar", icon: "delete.left", keyName: "backspace", ws: ws)
                SpecialKeyButton(title: "Espacio", icon: "space", keyName: "space", ws: ws)
                SpecialKeyButton(title: "Tab", icon: "arrow.right.to.line.alt", keyName: "tab", ws: ws)
                SpecialKeyButton(title: "Esc", icon: "escape", keyName: "esc", ws: ws)
            }
            .padding()
            
            // Modifiers / Hotkeys
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                HotkeyButton(title: "Copiar", icon: "doc.on.doc", keys: ["ctrl", "c"], ws: ws)
                HotkeyButton(title: "Pegar", icon: "doc.on.clipboard", keys: ["ctrl", "v"], ws: ws)
                HotkeyButton(title: "Cortar", icon: "scissors", keys: ["ctrl", "x"], ws: ws)
                HotkeyButton(title: "Deshacer", icon: "arrow.uturn.backward", keys: ["ctrl", "z"], ws: ws)
                HotkeyButton(title: "Sel. Todo", icon: "selection.pin.in.out", keys: ["ctrl", "a"], ws: ws)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct SpecialKeyButton: View {
    let title: String
    let icon: String
    let keyName: String
    let ws: WebSocketService
    
    var body: some View {
        Button(action: {
            HapticService.playLight()
            ws.send(command: RemoteCommand.PressKey(key: keyName))
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color(.systemGray6))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct HotkeyButton: View {
    let title: String
    let icon: String
    let keys: [String]
    let ws: WebSocketService
    
    var body: some View {
        Button(action: {
            HapticService.playMedium()
            ws.send(command: RemoteCommand.Hotkey(keys: keys))
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color(.systemGray6))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
