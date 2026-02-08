import Foundation

struct Store: Initializable {
    static var url: URL {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "scd")
    }

    static func initialize() throws {
        guard isFirstLaunch else { return }

        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        } catch (let error) {
            Console.error("⚠️ Store couldnt be initialized!")
            throw error
        }
    }
}
