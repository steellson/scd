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

                guard let linksPath = settings.links, !linksPath.isEmpty else {
                    preconditionFailure("Missing links! Try sdc -set-links <path>")
                }
                guard let dirPath = settings.dir, !dirPath.isEmpty else {
                    preconditionFailure("Missing targer directory! Try scd set-folder <path>")
                }

                let links = URL(fileURLWithPath: linksPath)
                let dir = URL(fileURLWithPath: dirPath)

                let latency = settings.latency ?? 15
                let files = try await download(links: links, latency: latency)
                let converted = try convert(files: files, dir: dir)

                log(files.count == converted)
                sem.signal()
            } catch {
                print("Something went wrong: \(error.localizedDescription)")
                Writer.deleteFolder()
                fatalError()
            }
        }

        sem.wait()
    }

    // MARK: - Loading
    func download(links: URL, latency: UInt32) async throws -> [URL] {
        let links = try Reader.readLines(links)
        print("Total: \(links.count)")

        var files = [URL]()
        for link in links {
            sleep(latency)

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
    func convert(files: [URL], dir: URL) throws -> Int {
        var converted: Int = .zero

        for file in files {
            try Converter.convert(file, dir: dir)
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
