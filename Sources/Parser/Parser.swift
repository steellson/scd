import SwiftSoup
import Foundation

struct Parser {
    typealias Dict = [String: Any]

    static func getEmbedLink(_ page: String) throws -> String? {
        let doc = try SwiftSoup.parse(page)
        let scripts = try doc.select("script[data-tralbum]").array()

        for script in scripts {
            let jsonString = try script
                .attr("data-tralbum")
                .replacingOccurrences(of: "&quot;", with: "\"")

            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: jsonData) as? Dict,
                  let trackinfo = json["trackinfo"] as? [Dict] else {
                return nil
            }

            for track in trackinfo {
                guard let file = track["file"] as? Dict,
                      let mp3 = file["mp3-128"] as? String else {
                    return nil
                }

                return mp3.replacingOccurrences(of: "&amp;", with: "&")
            }
        }

        return nil
    }
}
