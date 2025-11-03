import Foundation

struct Settings: Codable {
    let sourceFile: String?
    let targetDir: String?
}

extension Settings {
    static func read() throws -> Self {
        let url = URL(filePath: #filePath)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Self.self, from: data)
    }

    static func write(_ settings: Self) throws {
        let url = URL(filePath: #filePath)
        try JSONEncoder().encode(settings).write(to: url)
    }
}
