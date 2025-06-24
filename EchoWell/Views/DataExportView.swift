import SwiftUI

/// A button + sheet UI for previewing & exporting all clips.
struct DataExportView: View {
  @State private var showSheet   = false
  @State private var dataFormat  = DataFormat.table
  @State private var dataPreview = ""
  @State private var previewClips = [EchoClip]()

  enum DataFormat: String, CaseIterable, Identifiable {
    case table = "Table", json = "JSON", csv = "CSV"
    var id: String { rawValue }
  }

  var body: some View {
    Button("View & Export Data") {
      loadPreview()
      showSheet = true
    }
    .sheet(isPresented: $showSheet) {
      NavigationView {
        VStack(spacing: 16) {
          Picker("", selection: $dataFormat) {
            ForEach(DataFormat.allCases) { fmt in
              Text(fmt.rawValue).tag(fmt)
            }
          }
          .pickerStyle(.segmented)
          .padding(.horizontal)
          .onChange(of: dataFormat) { _ in loadPreview() }

          Group {
            switch dataFormat {
            case .table:
              List {
                HStack {
                  Text("Filename").bold().frame(width:100, alignment:.leading)
                  Text("Date").bold().frame(maxWidth:.infinity, alignment:.leading)
                  Text("Person").bold().frame(width:80, alignment:.leading)
                  Text("Tag").bold().frame(width:80, alignment:.leading)
                  Text("Note").bold().frame(maxWidth:.infinity, alignment:.leading)
                }
                .font(.caption)

                ForEach(previewClips) { clip in
                  HStack {
                    Text(clip.filename).frame(width:100, alignment:.leading)
                    Text(clip.timestamp.formatted(.dateTime.year().month().day()))
                      .frame(maxWidth:.infinity, alignment:.leading)
                    Text(clip.person).frame(width:80, alignment:.leading)
                    Text(clip.contextTag).frame(width:80, alignment:.leading)
                    Text(clip.note.replacingOccurrences(of: "\n", with: " "))
                      .frame(maxWidth:.infinity, alignment:.leading)
                  }
                  .font(.system(.caption, design: .monospaced))
                  .padding(.vertical,2)
                }
              }

            case .json:
              ScrollView {
                Text(previewJSON())
                  .font(.system(.body, design: .monospaced))
                  .padding()
              }

            case .csv:
              ScrollView {
                Text(previewCSV())
                  .font(.system(.body, design: .monospaced))
                  .padding()
              }
            }
          }

          Spacer()

          Button("Export as CSV") {
            exportCSV()
          }
          .buttonStyle(.borderedProminent)
          .padding(.horizontal)
        }
        .navigationTitle("All Clips")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Close") { showSheet = false }
          }
        }
      }
      .onAppear(perform: loadPreview)
    }
  }

  // MARK: — Helpers

  private func loadPreview() {
    let all = (try? Database.shared.fetchAll()) ?? []
    previewClips = all
    dataPreview = (dataFormat == .csv) ? previewCSV() : ""
  }

  private func previewCSV() -> String {
    generateCSV(from: previewClips)
  }

  private func previewJSON() -> String {
    guard let d = try? JSONEncoder().encode(previewClips),
          let s = String(data: d, encoding: .utf8)
    else { return "Failed to generate JSON" }
    return s
  }

  private func exportCSV() {
    let csv = previewCSV()
    let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent("EchoWellData.csv")
    do {
      try csv.write(to: tmp, atomically: true, encoding: .utf8)
      presentShareSheet(items: [tmp])
    } catch {
      print("CSV export failed:", error)
    }
  }
}
