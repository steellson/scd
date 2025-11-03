import Foundation

struct Converter {
    private static let ffmpeg: URL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")

    /// Convert mp3 file to WAV format using `ffmpeg`
    /// - Parameters:
    ///   - file: Target mp3 file
    ///   - dir: Target directory for storage
    /// - Returns: Is convertation successed
   static func convert(_ file: URL, dir: URL) throws {
       let process = Process()
       process.executableURL = ffmpeg
       process.arguments = arguments(file, dir: dir)

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
    static func arguments(_ file: URL, dir: URL) -> [String] {
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
