import Foundation

struct Writer {
    static let tempDir: URL = dir.appending(path: "temp")

    static func write(with name: String, file: Data) throws -> URL? {
        checkFolder()
        let url = tempDir.appending(path: name)

        do {
            try file.write(to: url)
            return url
        } catch {
            print("Cant write file with url: \(url)")
            return nil
        }
    }

    static func deleteFolder() {
        do {
            try FileManager.default.removeItem(at: tempDir)
        } catch {
            print("Cant delete temp directory \(error)")
        }
    }
}

// MARK: - Private
private extension Writer {
    static func checkFolder() {
        var isDir = ObjCBool(true)
        let isTempDirExist = FileManager.default.fileExists(
            atPath: tempDir.path(),
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
            print("Cant create temp directory \(error)")
        }
    }
}
