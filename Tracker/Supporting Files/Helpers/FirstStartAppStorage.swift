import Foundation

final class FirstStartAppStorage {
    private let userDefaults = UserDefaults.standard
    
    func getIsFirstStartApp() -> Bool {
        return userDefaults.bool(forKey: "hasShownOnboarding")
    }
    
    func setIsFirstStartApp() {
        userDefaults.set(true, forKey: "hasShownOnboarding")
    }
}

