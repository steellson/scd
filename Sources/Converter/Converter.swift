import Foundation

struct Converter {
    private let folder: URL
    private let ffmpeg: URL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")

    init(_ folder: URL) {
        self.folder = folder
    }

    /// Convert mp3 file to WAV format using `ffmpeg`
    /// - Parameters:
    ///   - file: Target mp3 file
    /// - Returns: Is convertation successed
    func convert(_ file: URL) throws -> Bool {
        let pipe = Pipe()
        let process = Process()

        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = ffmpeg
        process.arguments = arguments(file)

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == .zero else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("Convert error:\n\(output)")
            }
            return false
        }

        print("Converted: \(file)")
        return true
    }

    /// Collect args for convertation
    /// - Parameter file: File to convert
    /// - Returns: Array of required arguments
    private func arguments(_ file: URL) -> [String] {
        let inputFile = file.path()
        let outputFile = folder
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
