import ArgumentParser
import Foundation

let sourceFile = "links.txt"
let tempDir: URL = dir.appending(path: "temp")
let targetDir = URL.desktopDirectory.appending(path: "target")
let dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()

@main
struct scd: ParsableCommand {
    mutating func run() throws {
        process()
    }

    func process() {
        let loader = Loader()
        let writer = Writer()
        let converter = Converter(targetDir)
        let sem = DispatchSemaphore(value: 0)

        Task {
            do {
                let source = dir.appending(path: sourceFile)
                let links = try Reader.readLines(source)

                var files = [URL]()
                var converted = 0

                print("Total: \(links.count)")

                for (num, link) in links.enumerated() {
                    sleep(2)

                    guard let html = try await loader.loadHTML(link) else {
                        print("Cant load html page from link: \(link)")
                        break
                    }

                    guard let downloadLink = try Parser.getEmbedLink(html) else {
                        print("Cant parse download link from html")
                        break
                    }

                    guard let file = try await loader.loadFile(downloadLink) else {
                        print("Cant load file from link: \(downloadLink)")
                        break
                    }

                    let name = "\(num + 1).mp3"
                    print("\(name) downloaded")

                    if let wrirted = try writer.write(with: name, file: file) {
                        files.append(wrirted)
                    }
                }

                for file in files { try converter.convert(file) ? converted += 1 : () }
                writer.deleteFolder()

                if files.count == converted {
                    print("Completed! All files downloaded and converted")
                } else {
                    print("Warning: Some files cant be converted")
                }

                sem.signal()
            } catch {
                print("Error: \(error)")
                sem.signal()
            }
        }

        sem.wait()
    }
}
