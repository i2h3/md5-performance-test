import SwiftUI

struct RunView: View {
    let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    let run: Run

    var body: some View {
        Form {
            HStack {
                Text("Date")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(dateFormatter.string(from: run.timestamp))
            }
            HStack {
                Text("File Size")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(byteCountFormatter.string(fromByteCount: Int64(run.fileSize)))
            }
            HStack {
                Text("Chunk Size")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(byteCountFormatter.string(fromByteCount: Int64(run.chunkSize)))
            }
            HStack {
                Text("Duration")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(dateComponentsFormatter.string(from: run.duration) ?? "nil")
            }
        }.navigationTitle("Run Details")
    }
}

#Preview {
    RunView(run: Run(fileSize: 157274621385, chunkSize: 1288593, duration: 17.5, timestamp: Date.now))
}
