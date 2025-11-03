import ArgumentParser
import Foundation

let dir = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()

@main
struct scd: ParsableCommand {
    mutating func run() throws { process() }

    func process() {
        let sem = DispatchSemaphore(value: 0)

        Task {
            do {
                let settings = try Settings.read()
                let files = try await download(settings)
                let converted = try convert(files, settings)
                log(files.count == converted)

                sem.signal()
            } catch {
                assertionFailure("Something went wrong: \(error.localizedDescription)")
                sem.signal()
            }
        }

        sem.wait()
    }

    // MARK: - Loading
    func download(_ settings: Settings) async throws -> [URL] {
        guard let sourceFile = settings.sourceFile else {
            assertionFailure("Missing links! Try sdc -set-links <path>")
            return []
        }

        let source = dir.appending(path: sourceFile)
        let links = try Reader.readLines(source)

        print("Total: \(links.count)")

        var files = [URL]()
        for link in links {
            sleep(settings.latency ?? 15)

            guard let html = try await Loader.loadHTML(link) else {
                print("Cant load html page from link: \(link)")
                break
            }
            guard let downloadLink = try Parser.getEmbedLink(html) else {
                print("Cant parse download link!")
                break
            }
            guard let name = try Parser.getName(html) else {
                print("Cant extract file name!")
                break
            }
            guard let file = try await Loader.loadFile(downloadLink) else {
                print("Cant load file from link: \(downloadLink)")
                break
            }
            guard let wrirted = try Writer.write(with: name, file: file) else {
                print("Cant write file with name: \(name)")
                break
            }

            files.append(wrirted)
        }

        return files
    }

    // MARK: - Convertation
    func convert(_ files: [URL], _ settings: Settings) throws -> Int {
        guard let dir = settings.targetDir, let url = URL(string: dir) else {
            assertionFailure("Missing targer directory! Try scd set-folder <path>")
            return .zero
        }

        var converted: Int = .zero

        for file in files {
            try Converter.convert(file, dir: url)
            converted += 1
        }

        Writer.deleteFolder()
        return converted
    }

    // MARK: - Logging
    func log(_ isSuccess: Bool) {
        let log = isSuccess
        ? "Completed!"
        : "Warning: Some files cant be handled"

        print(log)
    }
}
