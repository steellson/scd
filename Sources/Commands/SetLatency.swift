import ArgumentParser

struct SetLatency: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-latency",
        abstract: "Set the latency between downloads (1-300 seconds)"
    )

    @Argument(help: "Latency value (1-300 seconds)")
    var value: Int

    mutating func run() throws {
        guard value >= 1 && value <= 300 else {
            throw ValidationError("Latency must be between 1 and 300 seconds")
        }

        var settings = try Settings.read()
        settings.latency = UInt32(value)
        try Settings.write(settings)
        Console.success("Latency set to: \(value) seconds")
    }
}
