import Combine
import UIKit

@MainActor
final class RecordingProtectionService: ObservableObject {
    @Published private(set) var warning: String?
    private var observers: [NSObjectProtocol] = []

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        observers = [
            NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { [weak self] _ in self?.checkBattery() },
            NotificationCenter.default.addObserver(forName: ProcessInfo.thermalStateDidChangeNotification, object: nil, queue: .main) { [weak self] _ in self?.checkThermal() }
        ]
    }

    deinit { observers.forEach(NotificationCenter.default.removeObserver) }

    func beginPreventingAutoLock() { UIApplication.shared.isIdleTimerDisabled = true; checkBattery(); checkThermal() }
    func endPreventingAutoLock() { UIApplication.shared.isIdleTimerDisabled = false; warning = nil }

    func checkStorage() {
        let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let free = values?.volumeAvailableCapacityForImportantUsage, free < 500_000_000 { warning = "Depolama kritik seviyede." }
    }

    private func checkBattery() { let level = UIDevice.current.batteryLevel; if level >= 0 && level < 0.10 { warning = "Pil %10’un altında." } else if level >= 0 && level < 0.20 { warning = "Pil %20’nin altında." } }
    private func checkThermal() { if ProcessInfo.processInfo.thermalState == .serious || ProcessInfo.processInfo.thermalState == .critical { warning = "Cihaz ısınıyor; kaydı kısa süre içinde bitirin." } }
}
