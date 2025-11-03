import Foundation

struct Loader {
    static func loadFile(_ urlString: String) async throws -> Data? {
        try await load(from: urlString)
    }
    
    static func loadHTML(_ urlString: String) async throws -> String? {
        guard let data = try await load(from: urlString) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Private
private extension Loader {
    static func load(from url: String) async throws -> Data? {
        guard let url = URL(string: url) else { return nil }
        return try await URLSession.shared.data(from: url).0
    }
}
