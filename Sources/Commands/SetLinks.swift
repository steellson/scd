import ArgumentParser

struct SetLinks: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-links",
        abstract: "Set the path to the file with links"
    )

    @Argument(help: "Path to the file containing links")
    var path: String

    mutating func run() throws {
        var settings = try Settings.read()
        settings.links = path
        try Settings.write(settings)
        print("Links path set to: \(path)")
    }
}
