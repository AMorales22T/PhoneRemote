import Foundation

// Base protocol for all commands
protocol CommandBase: Codable {
    var t: String { get }
}

struct RemoteCommand {
    // Mouse
    struct MouseMove: Codable { let t = "mm"; let x: Double; let y: Double }
    struct MouseClick: Codable { let t = "mc"; let b: String } // "left" or "right"
    struct DoubleClick: Codable { let t = "md" }
    struct Scroll: Codable { let t = "ms"; let d: Double }
    struct DragStart: Codable { let t = "ds" }
    struct DragEnd: Codable { let t = "de" }
    
    // Keyboard
    struct TypeText: Codable { let t = "kt"; let text: String }
    struct PressKey: Codable { let t = "kp"; let key: String }
    struct Hotkey: Codable { let t = "kh"; let keys: [String] }
    
    // Media
    struct PlayPause: Codable { let t = "mp" }
    struct NextTrack: Codable { let t = "mn" }
    struct PrevTrack: Codable { let t = "mb" }
    struct VolumeUp: Codable { let t = "vu" }
    struct VolumeDown: Codable { let t = "vd" }
    struct Mute: Codable { let t = "vm" }
    struct SetVolume: Codable { let t = "vl"; let v: Int }
    struct Fullscreen: Codable { let t = "fs" }
    
    // System
    struct OpenApp: Codable { let t = "oa"; let app: String }
    struct SleepPC: Codable { let t = "sp" }
    struct ScreenOff: Codable { let t = "so" }
    struct ClipboardGet: Codable { let t = "cg" }
    struct ClipboardSet: Codable { let t = "cs"; let text: String }
}

// Server Response Model
struct ServerStatus: Codable {
    let t: String
    let connected: Bool?
    let volume: Int?
    let text: String? // For clipboard
}
