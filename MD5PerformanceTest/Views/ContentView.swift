import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.timestamp, order: .reverse) private var runs: [Run]

    @State private var latestRun: Run?
    @State private var selectedFileSize: FileSizeOption = .oneGigaByte
    @State private var selectedChunkSize: ChunkSizeOption = .oneMegaByte
    @State private var status: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Options")) {
                    Picker("File Size", selection: $selectedFileSize) {
                        Text("1 MegaByte").tag(FileSizeOption.oneMegaByte)
                        Text("1 GigaByte").tag(FileSizeOption.oneGigaByte)
                        Text("10 GigaByte").tag(FileSizeOption.tenGigaBytes)
                    }

                    Picker("Chunk Size", selection: $selectedChunkSize) {
                        Text("100 KiloByte").tag(ChunkSizeOption.oneHundredKiloByte)
                        Text("1 MegaByte").tag(ChunkSizeOption.oneMegaByte)
                        Text("10 MegaByte").tag(ChunkSizeOption.tenMegaByte)
                    }

                    Button {
                        run()
                    } label: {
                        Text("Run")
                    }

                }.disabled(status != nil)

                if let status {
                    Section(header: Text("Status")) {
                        Text(status)
                    }
                }

                if runs.count > 0 {
                    Section {
                        if let latestRun {
                            Text("Latest run took **\(String(format: "%.1f", latestRun.duration))** seconds")
                        }

                        NavigationLink {
                            RunListView()
                        } label: {
                            Text("All Runs")
                        }
                    }.disabled(status != nil)
                }

            }.navigationTitle("MD5 Performance Test")
        }
    }

    func run() {
        Task {
            do {
                await updateStatus("Rendering file...")
                let renderer = Renderer(chunkSize: selectedChunkSize.rawValue)
                let url = try renderer.render(bytes: selectedFileSize.rawValue)

                let hashingStartTime = Date.now

                await updateStatus("Hashing file...")
                let hasher = Hasher(chunkSize: selectedChunkSize.rawValue)
                try hasher.hash(url)

                let hashingEndTime = Date.now
                let elapsedHashingTime = hashingEndTime.timeIntervalSince(hashingStartTime)

                let latestRun = Run(
                    fileSize: selectedFileSize.rawValue,
                    chunkSize: selectedChunkSize.rawValue,
                    duration: elapsedHashingTime,
                    timestamp: Date.now
                )

                modelContext.insert(latestRun)
                self.latestRun = latestRun

                await updateStatus(nil)
            } catch {
                await updateStatus("Error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func updateStatus(_ status: String?) {
        self.status = status
    }
}

#Preview {
    ContentView()
}
