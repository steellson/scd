import Foundation

struct FileReader {
    static func readLines(_ fileURL: URL) throws -> [String] {
        try String(contentsOf: fileURL, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
            .compactMap { String($0) }
    }
}


