import Foundation

struct Converter {
    private static let ffmpeg: URL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")

    /// Convert mp3 file to WAV format using `ffmpeg`
    /// - Parameters:
    ///   - file: Target mp3 file
    ///   - dir: Target directory for storage
    /// - Returns: Is convertation successed
   static func convert(_ file: URL, dir: URL) throws {
        let pipe = Pipe()
        let process = Process()

        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = ffmpeg
        process.arguments = arguments(file, dir: dir)

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != .zero {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            if let output = String(data: data, encoding: .utf8) {
                print("FFMPEG error:\n\(output)")
            }
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
            "-y",                   // Rewrite file if exist
            "-i", inputFile,        // Input file
            "-ar", "44100",         // Sampling rate
            "-ac", "2",             // 2 Channels (Stereo)
            "-acodec", "pcm_s16le", // Wav codec
            outputFile              // Output file
        ]
    }
}
