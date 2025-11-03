import Foundation

struct FileLoader {
    static func load(_ urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        return try await URLSession.shared.data(from: url).0
    }

    static func load(_ urlString: String) async throws -> String? {
        guard let url = URL(string: urlString) else { return nil }

        return String(
            data: try await URLSession.shared.data(from: url).0,
            encoding: .utf8
        )
    }
}
