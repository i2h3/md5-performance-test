import Foundation
import os

///
/// Facility to render an arbitrarily sized file with random content.
///
struct Renderer {
    let chunkSize: UInt
    let signposter = OSSignposter(subsystem: "MD5PerformanceTest", category: "Renderer")

    init(chunkSize: UInt) {
        self.chunkSize = chunkSize
    }

    func makeChunk(bytes count: UInt) -> Data {
        let signpostID = signposter.makeSignpostID()
        let signpostIntervalState = signposter.beginInterval(#function, id: signpostID)

        defer {
            signposter.endInterval(#function, signpostIntervalState)
        }

        var data = Data(count: Int(count))

        data.withUnsafeMutableBytes { mutableBytes in
            if let bytes = mutableBytes.baseAddress {
                _ = SecRandomCopyBytes(kSecRandomDefault, Int(count), bytes)
            }
        }

        return data
    }

    func render(bytes: UInt) throws -> URL {
        let signpostID = signposter.makeSignpostID()
        let signpostIntervalState = signposter.beginInterval(#function, id: signpostID)

        defer {
            signposter.endInterval(#function, signpostIntervalState)
        }

        let maximumChunkSize: UInt = chunkSize
        let url = FileManager.default.temporaryDirectory.appending(component: "\(UUID().uuidString).random")
        var offset: UInt = 0

        FileManager.default.createFile(atPath: url.path, contents: nil)

        let handle = try FileHandle(forWritingTo: url)

        while offset < bytes {
            let remainingBytes = bytes - offset
            var currentChunkSize = maximumChunkSize

            if remainingBytes < maximumChunkSize {
                currentChunkSize = remainingBytes
            }

            offset += currentChunkSize

            let data = makeChunk(bytes: currentChunkSize)
            try handle.write(contentsOf: data)
        }

        try handle.close()

        return url
    }
}
