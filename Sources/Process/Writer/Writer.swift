import Foundation

struct Writer {
    static func write(with name: String, file: Data) throws -> URL? {
        checkFolder()
        let url = createFileURL(name)

        do {
            try file.write(to: url)
            return url
        } catch {
            Console.error("Can't write file to: \(url)")
            return nil
        }
    }

    static func deleteFolder(withLog: Bool = true) {
        if withLog { Console.progress("Cleaning up temp folder...") }
        try? FileManager.default.removeItem(at: tempDir)
    }
}

// MARK: - Private
private extension Writer {
    static var tempDir: URL {
        Store.url.appending(path: "temp")
    }

    static func checkFolder() {
        var isDir = ObjCBool(true)
        let isTempDirExist = FileManager.default.fileExists(
            atPath: tempDir.path(percentEncoded: false),
            isDirectory: &isDir
        )

        guard !isTempDirExist else { return }
        createFolder()
    }

    static func createFolder() {
        do {
            try FileManager.default.createDirectory(
                at: tempDir,
                withIntermediateDirectories: false
            )
        } catch {
            Console.error("Can't create temp directory: \(error)")
        }
    }

    static func createFileURL(_ name: String) -> URL {
        let manager = FileManager.default
        let url = tempDir.appending(path: name)
        let path = url.path(percentEncoded: false)
        let isDuplicate = manager.fileExists(atPath: path)

        guard isDuplicate else { return url }
        let tempPath = tempDir.path(percentEncoded: false)
        let duplicatesCount = (try? manager
            .contentsOfDirectory(atPath: tempPath)
            .filter { $0.contains(name) }
            .count) ?? 0

        let numberOfDuplicate = String(duplicatesCount + 1)
        let updatedName = name + "_" + numberOfDuplicate
        return tempDir.appending(path: updatedName)
    }
}
