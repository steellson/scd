import Foundation

struct Writer {
    private let manager = FileManager.default

    func write(with name: String, file: Data) throws -> URL? {
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

    func deleteFolder() {
        do {
            try manager.removeItem(at: tempDir)
        } catch {
            print("Cant delete temp directory \(error)")
        }
    }
}

// MARK: - Private
private extension Writer {
    func checkFolder() {
        var isDir = ObjCBool(true)
        let isTempDirExist = manager.fileExists(
            atPath: tempDir.path(),
            isDirectory: &isDir
        )

        guard !isTempDirExist else { return }
        createFolder()
    }

    func createFolder() {
        do {
            try manager.createDirectory(
                at: tempDir,
                withIntermediateDirectories: false
            )
        } catch {
            print("Cant create temp directory \(error)")
        }
    }
}
