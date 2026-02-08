import Foundation

protocol Initializable {
    static var url: URL { get }
    static var isFirstLaunch: Bool { get }
    static func initialize() throws
}

extension Initializable {
    static var isFirstLaunch: Bool {
        !FileManager.default.fileExists(atPath: url.path)
    }
}
