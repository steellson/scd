import ArgumentParser
import Foundation

struct SettingsCheck: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "settings",
        abstract: "Show current settings"
    )

    mutating func run() throws {
        let settings = try Settings.read()

        Console.bold("Current Settings")
        Console.setting(name: "Links file", value: settings.links)
        Console.setting(name: "Target folder", value: settings.dir)
        Console.setting(name: "Latency (sec)", value: settings.latency.map { "\($0)" })
    }
}
