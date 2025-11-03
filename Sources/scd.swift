import ArgumentParser

@main
struct scd: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "--- Downloader ---",
        subcommands: [
            Start.self,
            SetLinks.self,
            SetFolder.self,
            SetLatency.self
        ]
    )
}
