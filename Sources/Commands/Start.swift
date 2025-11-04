import ArgumentParser
import Foundation

struct Start: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "start",
        abstract: "Start program"
    )

    @Option(name: .customShort("l"), help: "File with links")
    var links: String?

    @Option(name: .customShort("d"), help: "Target directory")
    var dir: String?

    @Option(name: .customShort("t"), help: "Latency time")
    var time: UInt32?

    @Option(name: .customShort("f"), help: "Preffered audio format")
    var format: String?

    @Option(name: .customShort("c"), help: "Path to ffmpeg converter")
    var converter: String?

    mutating func run() throws {
        let process = MainProcess()
        let settings = try readSettings()
        process.run(with: settings)
    }

    /// Merge arguements settings with local config on start
    /// Without rewriting local
    private func readSettings() throws -> Settings {
        var local = try Settings.read()
        return local.merge(
            with: Settings(
                links: links,
                dir: dir,
                latency: time,
                format: AudioFormat(rawValue: format ?? ""),
                converter: converter
            )
        )
    }
}
