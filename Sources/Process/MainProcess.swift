import Foundation

/// *Programm working directory*
let dir = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()


/// Handle force exit using `CTRL+C`
/// Catch signal and remove temp folder if needed
/// Working on `.global` queue
nonisolated(unsafe) private var exitHandler: DispatchSourceSignal?


/// `` PROCESS PIPELINE ``
/// ** Check requirements *
/// ** Download **
/// ** Convert **
/// ** Log **
struct MainProcess {
    func run() {
        setupExitHandler()

        let sem = DispatchSemaphore(value: 0)

        Task {
            do {
                /// Check required links
                let settings = try Settings.read()
                guard let linksPath = settings.links, !linksPath.isEmpty else {
                    Console.error("Missing links! Try scd set-links <path>")
                    sem.signal()
                    return
                }
                guard let dirPath = settings.dir, !dirPath.isEmpty else {
                    Console.error("Missing target directory! Try scd set-folder <path>")
                    sem.signal()
                    return
                }

                /// Initialize and start process
                let links = URL(fileURLWithPath: linksPath)
                let dir = URL(fileURLWithPath: dirPath)

                let latency = settings.latency ?? 15
                let files = try await download(links: links, latency: latency)
                let converted = try convert(files: files, dir: dir)

                /// Logging when complete
                files.count == converted
                ? Console.success("Completed! Downloaded and converted \(converted) files")
                : Console.warning("Some files couldn't be handled")

                sem.signal()
            } catch {
                Console.error("Something went wrong: \(error.localizedDescription)")
                Writer.deleteFolder()
                sem.signal()
            }
        }

        sem.wait()
    }

    // MARK: - Loading
    private func download(links: URL, latency: UInt32) async throws -> [URL] {
        let links = try Reader.readLines(links)
        Console.info("Total links: \(links.count)")

        var files = [URL]()
        for (num, link) in links.enumerated() {
            sleep(latency)

            guard let html = try await Loader.loadHTML(link) else {
                Console.error("Can't load HTML page from link: \(link)")
                break
            }
            guard let downloadLink = try Parser.getEmbedLink(html) else {
                Console.error("Can't parse download link!")
                break
            }
            guard let name = try Parser.getName(html) else {
                Console.error("Can't extract file name!")
                break
            }
            guard let file = try await Loader.loadFile(downloadLink) else {
                Console.error("Can't load file from link: \(downloadLink)")
                break
            }
            guard let wrirted = try Writer.write(with: name, file: file) else {
                Console.error("Can't write file with name: \(name)")
                break
            }

            files.append(wrirted)
            Console.download("[\(num + 1)/\(links.count)] \(name)")
        }

        return files
    }

    // MARK: - Convertation
    private func convert(files: [URL], dir: URL) throws -> Int {
        var converted: Int = .zero
        Console.progress("Processing files...")

        for file in files {
            try Converter.convert(file, dir: dir)
            converted += 1
        }

        Writer.deleteFolder()
        return converted
    }

    // MARK: - Force exit handling
    private func setupExitHandler() {
        exitHandler = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
        exitHandler?.setEventHandler { Writer.deleteFolder(); exit(0) }
        exitHandler?.resume()
        signal(SIGINT, SIG_IGN)
    }
}
