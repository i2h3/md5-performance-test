import Foundation
import SwiftData

@Model
final class Run {
    var fileSize: UInt
    var chunkSize: UInt
    var duration: TimeInterval
    var timestamp: Date

    init(fileSize: UInt, chunkSize: UInt, duration: TimeInterval, timestamp: Date) {
        self.fileSize = fileSize
        self.chunkSize = chunkSize
        self.duration = duration
        self.timestamp = timestamp
    }
}

extension Run: CustomStringConvertible {
    var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return "Run at \(formatter.string(from: timestamp))"
    }
}
