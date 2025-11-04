import Foundation

struct Settings: Codable {
    var links: String?
    var dir: String?
    var latency: UInt32?
    var format: AudioFormat?
    var converter: String?

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
}

// MARK: - Read / Write
extension Settings {
    private static var url: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "config.json")
    }

    static func read() throws -> Self {
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

// MARK: - Private
private extension Settings {
    static func safe(path: String?) -> String? {
        if let path, !path.isEmpty, !path.hasPrefix("/") {
            return "/\(path)"
        } else {
            return path
        }
    }
}
