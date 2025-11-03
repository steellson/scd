import Foundation

struct PageLoader {
    static func load(_ urlString: String) async throws -> String? {
        guard let url = URL(string: urlString) else { return nil }

        return String(
            data: try await URLSession.shared.data(from: url).0,
            encoding: .utf8
        )
    }
}
