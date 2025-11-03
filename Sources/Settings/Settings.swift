import Foundation

struct Settings: Codable {
    var links: String?
    var dir: String?
    var latency: UInt32?
}

extension Settings {
    private static var url: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "config.json")
    }

    static func read() throws -> Self {
        let data = try Data(contentsOf: url)
        var settings = try JSONDecoder().decode(Self.self, from: data)

        if let links = settings.links, !links.isEmpty, !links.hasPrefix("/") {
            settings.links = "/\(links)"
        }

        if let dir = settings.dir, !dir.isEmpty, !dir.hasPrefix("/") {
            settings.dir = "/\(dir)"
        }

        return settings
    }

    static func write(_ settings: Self) throws {
        try JSONEncoder().encode(settings).write(to: url)
    }
}
