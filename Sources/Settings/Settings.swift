import Foundation

struct Settings: Codable {
    let sourceFile: String?
    let targetDir: String?
    let latency: UInt32?
}

extension Settings {
    private static var url: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "config.json")
    }

    static func read() throws -> Self {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Self.self, from: data)
    }

    static func write(_ settings: Self) throws {
        try JSONEncoder().encode(settings).write(to: url)
    }
}
