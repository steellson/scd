import Foundation

enum AudioFormat: String, Codable {
    case mp3
    case wav
    case flac
}

struct Converter {
    private let format: AudioFormat
    private let converter: URL
    private let dir: URL

    init(
        format: AudioFormat,
        converter: URL,
        dir: URL
    ) {
        self.format = format
        self.converter = converter
        self.dir = dir
    }

    /// Convert mp3 file to selected format using `ffmpeg`
    /// - Parameters:
    ///   - file: Target mp3 file
    ///   - dir: Target directory for storage
    /// - Returns: Is convertation successed
    func convert(_ file: URL) throws {
       let process = Process()
       process.executableURL = converter
       process.arguments = arguments(file)

       /// Redirect all I/O to prevent blocking
       let devNull = FileHandle.nullDevice
       process.standardInput = devNull
       process.standardOutput = devNull
       process.standardError = devNull

       try process.run()
       process.waitUntilExit()

       if process.terminationStatus != .zero {
           Console.error("FFMPEG failed with exit code: \(process.terminationStatus)")
       }
    }
}

// MARK: - Private
private extension Converter {
    /// Collect args for convertation
    func arguments(_ file: URL) -> [String] {
        let inputFile = file
            .path(percentEncoded: false)

        let outputFile = dir
            .appendingPathComponent(file.lastPathComponent)
            .deletingPathExtension()
            .appendingPathExtension("wav")
            .path

        return [
            "-nostdin",             // Don't expect any input from stdin
            "-y",                   // Rewrite file if exist
            "-i", inputFile,        // Input file
            "-ar", "44100",         // Sampling rate
            "-ac", "2",             // 2 Channels (Stereo)
            "-acodec", "pcm_s16le", // Wav codec
            outputFile              // Output file
        ]
    }
}
