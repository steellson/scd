import ArgumentParser
import Foundation

struct Start: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "start",
        abstract: "Start program"
    )

    mutating func run() throws {
        let process = MainProcess()
        process.run()
    }
}
