import ArgumentParser

struct SetFFMPEG: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-ffmpeg",
        abstract: "Set the path to the FFMPEG"
    )

    @Argument(help: "Path to the FFMPEG")
    var path: String

    mutating func run() throws {
        var settings = try Settings.read()
        settings.converter = path
        try Settings.write(settings)
        Console.success("FFMPEG path set to: \(path)")
    }
}
