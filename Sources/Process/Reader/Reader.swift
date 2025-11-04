import Foundation

struct Reader {
    enum Content: String {
        case track = "/track/"
        case album = "/album/"
    }

    static func read(_ fileURL: URL, content: Content) throws -> [String] {
        try String(contentsOf: fileURL, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
            .compactMap { String($0) }
            .filter { $0.contains(content.rawValue) }
    }
}
