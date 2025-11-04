import SwiftSoup
import Foundation

fileprivate typealias Dict = [String: Any]

struct Parser {
    static func getName(_ page: String) throws -> String? {
        let jsons = try parseTraalbumJSON(from: page)

        for json in jsons {
            guard let artist = json["artist"] as? String,
                  let current = json["current"] as? Dict,
                  let title = current["title"] as? String else {
                continue
            }

            let name = artist + " - " + title
            return name.replacingOccurrences(of: "/", with: "").capitalized
        }

        return nil
    }

    static func getEmbedLink(_ page: String) throws -> String? {
        let jsons = try parseTraalbumJSON(from: page)

        for json in jsons {
            guard let trackinfo = json["trackinfo"] as? [Dict] else {
                continue
            }

            for track in trackinfo {
                guard let file = track["file"] as? Dict,
                      let mp3 = file["mp3-128"] as? String else {
                    continue
                }

                return mp3.replacingOccurrences(of: "&amp;", with: "&")
            }
        }

        return nil
    }

    static func getTrackLinks(_ page: String) throws -> [String] {
        var trackLinks = Set<String>()

        try parseJSONLD(from: page).forEach {
            extractTrackLinks(from: $0, into: &trackLinks)
        }

        return Array(trackLinks).sorted()
    }
}

// MARK: - Private
private extension Parser {
    static func parseTraalbumJSON(from page: String) throws -> [Dict] {
        let doc = try SwiftSoup.parse(page)
        let scripts = try doc.select("script[data-tralbum]").array()

        var results: [Dict] = []
        for script in scripts {
            let jsonString = try script
                .attr("data-tralbum")
                .replacingOccurrences(of: "&quot;", with: "\"")

            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? Dict else {
                continue
            }

            results.append(json)
        }

        return results
    }

    static func parseJSONLD(from page: String) throws -> [Dict] {
        let doc = try SwiftSoup.parse(page)
        let scripts = try doc.select("script[type=\"application/ld+json\"]").array()

        var results: [Dict] = []
        for script in scripts {
            guard let jsonData = try script.html().data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? Dict else {
                continue
            }

            results.append(json)
        }

        return results
    }

    static func extractTrackLinks(from json: Dict, into trackLinks: inout Set<String>) {
        if let albumRelease = json["albumRelease"] as? [Any] {
            albumRelease
                .compactMap { $0 as? Dict }
                .filter { dict in
                    if let typeString = dict["@type"] as? String {
                        return typeString == "MusicRelease"
                    } else if let typeArray = dict["@type"] as? [String] {
                        return typeArray.contains("MusicRelease")
                    }
                    return false
                }
                .compactMap { $0["@id"] as? String }
                .filter { $0.contains("/track/") }
                .forEach { trackLinks.insert($0) }
        }

        if let track = json["track"] as? Dict,
           let itemListElement = track["itemListElement"] as? [Any] {
            itemListElement
                .compactMap { $0 as? Dict }
                .compactMap { $0["item"] as? Dict }
                .compactMap { $0["@id"] as? String }
                .filter { $0.contains("/track/") }
                .forEach { trackLinks.insert($0) }
        }
    }
}
