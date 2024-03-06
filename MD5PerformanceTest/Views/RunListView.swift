import SwiftData
import SwiftUI

struct RunListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.timestamp, order: .reverse) private var runs: [Run]

    var body: some View {
        List {
            ForEach(runs) { run in
                NavigationLink {
                    RunView(run: run)
                } label: {
                    Text(run.description)
                }
            }
        }.navigationTitle("Previous Runs")
    }
}

#Preview {
    RunListView()
}
