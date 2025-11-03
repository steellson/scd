import ArgumentParser

struct SetFolder: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-folder",
        abstract: "Set the path to the folder for converted files"
    )

    @Argument(help: "Path to the folder for converted files")
    var path: String

    mutating func run() throws {
        var settings = try Settings.read()
        settings.dir = path
        try Settings.write(settings)
        Console.success("Folder path set to: \(path)")
    }
}
