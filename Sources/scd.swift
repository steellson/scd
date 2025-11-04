import ArgumentParser

@main
struct scd: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "--- Downloader ---",
        subcommands: [
            Start.self,
            SetLinks.self,
            SetFFMPEG.self,
            SetFolder.self,
            SetFormat.self,
            SetLatency.self,
            SettingsCheck.self
        ]
    )
}
