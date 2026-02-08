import Foundation

struct Settings: Codable {
    var links: String?
    var dir: String?
    var latency: UInt32?
    var format: AudioFormat?
    var converter: String?

    /// Common
    init(
        links: String?,
        dir: String?,
        latency: UInt32?,
        format: AudioFormat?,
        converter: String?
    ) {
        self.links = links
        self.dir = dir
        self.latency = latency
        self.format = format
        self.converter = converter
    }

    /// Default
    fileprivate init() {
        links = ""
        dir = ""
        latency = 3
        format = .wav
        converter = "/opt/homebrew/bin/ffmpeg"
    }

    /// To merge arguments from command line with stored settings
    mutating func merge(with settings: Self) -> Self {
        if let converter = settings.converter { self.converter = Self.safe(path: converter) }
        if let links = settings.links { self.links = Self.safe(path: links) }
        if let dir = settings.dir { self.dir = Self.safe(path: dir) }
        if let format = settings.format { self.format = format }

        if let latency = settings.latency,
           latency >= 3 && latency <= 300 {
            self.latency = latency
        }

        return self
    }

    private static func safe(path: String?) -> String? {
        if let path, !path.isEmpty, !path.hasPrefix("/") {
            return "/\(path)"
        } else {
            return path
        }
    }
}

// MARK: - Read / Write
extension Settings {
    static func read() throws -> Self {
        if isFirstLaunch { try initialize() }

        let data = try Data(contentsOf: url)
        var settings = try JSONDecoder().decode(Self.self, from: data)

        settings.links = safe(path: settings.links)
        settings.dir = safe(path: settings.dir)
        settings.converter = safe(path: settings.converter)

        return settings
    }

    static func write(_ settings: Self) throws {
        try JSONEncoder().encode(settings).write(to: url)
    }
}

// MARK: - Initializable
extension Settings: Initializable {
    static var url: URL {
        Store.url.appending(path: "settings/config.json")
    }

    static func initialize() throws {
        guard isFirstLaunch else { return }

        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try write(Settings())
        } catch (let error) {
            Console.error("⚠️ Settings couldnt be initialized!")
            throw error
        }
    }
}
