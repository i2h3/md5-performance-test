import CryptoKit
import Foundation
import os

struct Hasher {
    let chunkSize: UInt
    let signposter = OSSignposter(subsystem: "MD5PerformanceTest", category: "Renderer")

    init(chunkSize: UInt) {
        self.chunkSize = chunkSize
    }

    @discardableResult
    func hash(_ url: URL) throws -> Insecure.MD5.Digest {
        let signpostID = signposter.makeSignpostID()
        let signpostIntervalState = signposter.beginInterval(#function, id: signpostID)

        defer {
            signposter.endInterval(#function, signpostIntervalState)
        }

        var hash = Insecure.MD5()

        let handle = try FileHandle(forReadingFrom: url)
        var incomplete = true

        while incomplete {
            autoreleasepool {
                let chunk = handle.readData(ofLength: Int(chunkSize))

                if chunk.isEmpty {
                    incomplete = false
                }

                hash.update(data: chunk)
            }
        }

        try handle.close()

        return hash.finalize()
    }
}
