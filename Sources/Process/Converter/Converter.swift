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

    /// Convert audio file to selected format using `ffmpeg`
    /// - Parameters:
    ///   - file: Target audio file
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
            .appendingPathExtension(format.rawValue)
            .path

        var args = [
            "-nostdin",       // Don't expect any input from stdin
            "-y",             // Rewrite file if exist
            "-i", inputFile   // Input file
        ]

        switch format {
        case .wav:
            args += [
                "-ar", "44100",          // Sampling rate
                "-ac", "2",              // 2 Channels (Stereo)
                "-acodec", "pcm_s16le"   // WAV codec
            ]
        case .mp3:
            args += [
                "-acodec", "libmp3lame",  // MP3 codec
                "-b:a", "320k",           // Bitrate 320 kbps (maximum quality)
                "-q:a", "0"               // Highest quality VBR (if CBR fails)
            ]
        case .flac:
            args += [
                "-ar", "44100",            // Sampling rate (same as WAV)
                "-ac", "2",                // 2 Channels (Stereo)
                "-acodec", "flac",         // FLAC codec (lossless)
                "-sample_fmt", "s16",      // 16-bit samples (same as WAV pcm_s16le)
                "-compression_level", "8"  // Max compression (smaller size, same quality)
            ]
        }

        args.append(outputFile)
        return args
    }
}
