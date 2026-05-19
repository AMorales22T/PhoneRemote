import UIKit

class HapticService {
    static let shared = HapticService()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    static func playLight() {
        shared.lightGenerator.impactOccurred()
        shared.lightGenerator.prepare()
    }
    
    static func playMedium() {
        shared.mediumGenerator.impactOccurred()
        shared.mediumGenerator.prepare()
    }
    
    static func playHeavy() {
        shared.heavyGenerator.impactOccurred()
        shared.heavyGenerator.prepare()
    }
    
    static func playSelection() {
        shared.selectionGenerator.selectionChanged()
        shared.selectionGenerator.prepare()
    }
}
