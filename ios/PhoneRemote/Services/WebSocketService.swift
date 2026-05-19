import Foundation
import Combine
import SwiftUI

@MainActor
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var serverVolume: Int = 50
    @Published var errorMessage: String? = nil
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var currentURL: URL?
    private var pingTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
    init() {
        self.urlSession = URLSession(configuration: .default)
    }

    func connect(webSocketURL: URL) {
        errorMessage = nil
        reconnectAttempts = 0
        currentURL = webSocketURL
        connectToCurrentURL()
    }
    
    func connect(urlString: String, token: String) {
        // Build WS url: ws://ip:port/ws/token
        var components = URLComponents(string: urlString)
        let originalScheme = components?.scheme
        components?.scheme = originalScheme == "https" ? "wss" : "ws"
        components?.path = "/ws/\(token)"
        
        guard let url = components?.url else {
            errorMessage = "URL inválida"
            return
        }
        
        connect(webSocketURL: url)
    }
    
    private func connectToCurrentURL() {
        guard let url = currentURL else { return }
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
        startPingTimer()
    }
    
    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
        currentURL = nil
    }
    
    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendPing()
            }
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    print("Ping failed: \(error)")
                    self?.handleDisconnect(reason: "No se pudo hacer ping al PC: \(error.localizedDescription)")
                } else if self?.isConnected == false {
                    self?.isConnected = true
                    self?.reconnectAttempts = 0
                }
            }
        }
    }
    
    private func handleDisconnect(reason: String? = nil) {
        isConnected = false
        pingTimer?.invalidate()
        
        guard reconnectAttempts < maxReconnectAttempts else {
            if let reason = reason {
                errorMessage = reason
            } else {
                errorMessage = "Conexión perdida. Revisa que el PC y el iPhone estén en la misma Wi-Fi y que el firewall permita PhoneRemote."
            }
            return
        }
        
        let delay = pow(2.0, Double(reconnectAttempts))
        reconnectAttempts += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connectToCurrentURL()
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    print("WebSocket receive error: \(error)")
                    self.handleDisconnect(reason: "No se pudo conectar al PC: \(error.localizedDescription)")
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.handleIncomingJSON(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleIncomingJSON(text)
                        }
                    @unknown default:
                        break
                    }
                    // Continue receiving
                    self.receiveMessage()
                }
            }
        }
    }
    
    private func handleIncomingJSON(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            let status = try JSONDecoder().decode(ServerStatus.self, from: data)
            if status.t == "status" {
                if let conn = status.connected {
                    isConnected = conn
                    reconnectAttempts = 0
                }
                if let vol = status.volume {
                    serverVolume = vol
                }
            }
        } catch {
            print("Error decoding status: \(error)")
        }
    }
    
    // MARK: - Sending Commands
    
    func send<T: Codable>(command: T) {
        guard isConnected else { return }
        
        do {
            let data = try JSONEncoder().encode(command)
            if let jsonString = String(data: data, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("Send error: \(error)")
                        Task { @MainActor in
                            self.handleDisconnect()
                        }
                    }
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }
}
