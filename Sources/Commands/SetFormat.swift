import ArgumentParser

struct SetFormat: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-format",
        abstract: "Set the audio format (mp3/wav/flac)"
    )

    @Argument(help: "Format value (mp3/wav/flac)")
    var format: String

    mutating func run() throws {
        guard let value = AudioFormat(rawValue: format) else {
            throw ValidationError("Format must be between mp3/wav/flac")
        }

        var settings = try Settings.read()
        settings.format = value
        try Settings.write(settings)
        Console.success("Audio format set to: \(value)")
    }
}
