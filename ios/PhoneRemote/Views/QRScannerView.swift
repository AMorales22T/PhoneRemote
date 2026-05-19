import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @EnvironmentObject var ws: WebSocketService
    @State private var manualIP = ""
    @State private var showingManualEntry = false
    @State private var isConnecting = false
    
    var body: some View {
        VStack {
            Text("PhoneRemote")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding(.top, 40)
            
            Text("Escanea el código QR en tu PC")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            ZStack {
                QRCameraView { result in
                    handleQRResult(result)
                }
                .frame(width: 300, height: 300)
                .cornerRadius(20)
                
                // Scanner frame overlay
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple.opacity(0.8), lineWidth: 3)
                    .frame(width: 300, height: 300)
            }
            .padding()
            
            if let error = ws.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            
            Button(showingManualEntry ? "Ocultar" : "Ingresar URL manualmente") {
                showingManualEntry.toggle()
            }
            .padding()
            .foregroundColor(.purple)
            
            if showingManualEntry {
                HStack {
                    TextField("ws://192.168.1.5:8888/ws/token", text: $manualIP)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(size: 13))
                    
                    Button("Conectar") {
                        connectManually()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: ws.errorMessage) { error in
            if error != nil {
                isConnecting = false
            }
        }
    }
    
    private func handleQRResult(_ result: String) {
        guard !isConnecting else { return }
        
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: trimmed),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            ws.errorMessage = "QR no válido"
            return
        }

        // Direct ws:// or wss:// URL with token in path (new format)
        if ["ws", "wss"].contains(url.scheme?.lowercased() ?? ""),
           components.path.hasPrefix("/ws/") {
            isConnecting = true
            HapticService.playHeavy()
            ws.connect(webSocketURL: url)
            return
        }

        // Backward compatibility with older QR format:
        // http://192.168.1.X:8888?token=ABC
        if let token = components.queryItems?.first(where: { $0.name == "token" })?.value,
           let host = url.host {
            let wsUrl = "ws://\(host):\(url.port ?? 8888)"
            isConnecting = true
            HapticService.playHeavy()
            ws.connect(urlString: wsUrl, token: token)
            return
        }
        
        ws.errorMessage = "QR no válido. Asegúrate de escanear el código correcto."
    }
    
    private func connectManually() {
        let input = manualIP.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            ws.errorMessage = "Ingresa una dirección IP"
            return
        }
        
        // If user entered a full ws:// URL, use it directly
        if input.lowercased().hasPrefix("ws://") || input.lowercased().hasPrefix("wss://") {
            if let url = URL(string: input) {
                isConnecting = true
                HapticService.playHeavy()
                ws.connect(webSocketURL: url)
            } else {
                ws.errorMessage = "URL inválida"
            }
            return
        }
        
        // Parse host:port format
        let parts = input.split(separator: ":", maxSplits: 1)
        let host = String(parts[0])
        let port: Int
        if parts.count > 1, let p = Int(parts[1]) {
            port = p
        } else {
            port = 8888
        }
        
        // For manual connection without token, connect to the base and let server handle it
        // We need to use the health endpoint first to verify, then connect WS
        let wsUrlString = "ws://\(host):\(port)"
        isConnecting = true
        HapticService.playHeavy()
        ws.connect(urlString: wsUrlString, token: "")
    }
}

// UIKit Camera Wrapper
struct QRCameraView: UIViewControllerRepresentable {
    let onResult: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let onResult: (String) -> Void
        private var hasHandled = false
        
        init(onResult: @escaping (String) -> Void) {
            self.onResult = onResult
        }
        
        func didFindQRCode(_ code: String) {
            if !hasHandled {
                hasHandled = true
                HapticService.playMedium()
                onResult(code)
                // Reset after 3 seconds to allow scanning again if failed
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.hasHandled = false
                }
            }
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didFindQRCode(_ code: String)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            delegate?.didFindQRCode(stringValue)
        }
    }
}
