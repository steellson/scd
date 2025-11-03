import ArgumentParser
import Foundation

struct SettingsCheck: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "settings",
        abstract: "Show current settings"
    )

    mutating func run() throws {
        let settings = try Settings.read()

        printHeader()
        printSetting("Links file", value: settings.links)
        printSetting("Target folder", value: settings.dir)
        printSetting("Latency (sec)", value: settings.latency.map { "\($0)" })
    }
}

// MARK: - Private
private extension SettingsCheck {
    func printHeader() {
        let header = "Current Settings"
        print(header.padding(toLength: 50, withPad: " ", startingAt: 0))
    }

    func printSetting(_ name: String, value: String?) {
        let formattedName = "\(name):".padding(toLength: 20, withPad: " ", startingAt: 0)
        let formattedValue = if let value, !value.isEmpty {
            value
        } else {
            "Not set"
        }
        print("\(formattedName) \(formattedValue)")
    }
}
