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
                    print("Missing links! Try sdc -set-links <path>")
                    return
                }
                guard let dirPath = settings.dir, !dirPath.isEmpty else {
                    print("Missing targer directory! Try scd set-folder <path>")
                    return
                }

                /// Initialize and start process
                let links = URL(fileURLWithPath: linksPath)
                let dir = URL(fileURLWithPath: dirPath)

                let latency = settings.latency ?? 15
                let files = try await download(links: links, latency: latency)
                let converted = try convert(files: files, dir: dir)

                /// Logging when complete
                let log = files.count == converted
                ? "Completed!"
                : "Warning: Some files cant be handled"
                print(log)

                sem.signal()
            } catch {
                print("Something went wrong: \(error.localizedDescription)")
                Writer.deleteFolder()
                sem.signal()
            }
        }

        sem.wait()
    }

    // MARK: - Loading
    private func download(links: URL, latency: UInt32) async throws -> [URL] {
        let links = try Reader.readLines(links)
        print("Total: \(links.count)")

        var files = [URL]()
        for (num, link) in links.enumerated() {
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
            print("Downloaded: \(num). \(name)")
        }

        return files
    }

    // MARK: - Convertation
    private func convert(files: [URL], dir: URL) throws -> Int {
        var converted: Int = .zero
        print("Processing files ...")

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
