import SwiftUI
import UIKit    // for UIActivityViewController

// MARK: – UIKit share‐sheet helper

extension UIApplication {
  /// Finds the topmost UIViewController to present from.
  var topViewController: UIViewController? {
    connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController?
      .topMost()
  }
}

private extension UIViewController {
  func topMost() -> UIViewController {
    if let presented = presentedViewController {
      return presented.topMost()
    }
    if let nav = self as? UINavigationController {
      return nav.visibleViewController?.topMost() ?? nav
    }
    if let tab = self as? UITabBarController {
      return tab.selectedViewController?.topMost() ?? tab
    }
    return self
  }
}

func presentShareSheet(items: [Any]) {
  DispatchQueue.main.async {
    let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
    UIApplication.shared.topViewController?.present(activity, animated: true)
  }
}

// MARK: – SettingsView

struct SettingsView: View {
  @StateObject private var config    = Config.shared
  @State private var newTag         = ""
  @State private var newName        = ""
  
  // Data‐preview sheet state
  @State private var showDataSheet  = false
  @State private var dataPreview    = ""
  @State private var dataFormat     = DataFormat.table
  @State private var previewClips   = [EchoClip]()

  enum DataFormat: String, CaseIterable, Identifiable {
    case table      = "Table"
    case json     = "JSON"
    case csv    = "CSV"
    var id: String { rawValue }
  }

  var body: some View {
    Form {
      // — Data Section —
      Section(header: Text("Data")) {
        Button("View & Export Data") {
            //force csv as the selected segment
         // dataFormat = .csv
         // updatePreview(for: .csv)
          updatePreview(for: dataFormat)
          showDataSheet = true
        }
      }
      
      // — Activity Tags —
      Section(header: Text("Activity Tags")) {
        ForEach(config.tagOptions, id: \.self) { tag in
          Text(tag.capitalized)
        }
        .onDelete(perform: deleteTags)
        HStack {
          TextField("New tag", text: $newTag)
          Button(action: addTag) {
            Image(systemName: "plus.circle.fill")
          }
          .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }

      // — People Names —
      Section(header: Text("People")) {
        ForEach(config.nameOptions, id: \.self) { name in
          Text(name)
        }
        .onDelete(perform: deleteNames)
        HStack {
          TextField("New person", text: $newName)
          Button(action: addName) {
            Image(systemName: "plus.circle.fill")
          }
          .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)

    // Data‐preview & export sheet
    .sheet(isPresented: $showDataSheet) {
      NavigationView {
        VStack(spacing: 16) {
          Picker("", selection: $dataFormat) {
            ForEach(DataFormat.allCases) { fmt in
              Text(fmt.rawValue).tag(fmt)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.horizontal)
          .onChange(of: dataFormat) { updatePreview(for: $0) }

          Group {
            switch dataFormat {
            case .csv:
              ScrollView {
                Text(dataPreview)
                  .font(.system(.body, design: .monospaced))
                  .padding()
              }
            case .json:
              ScrollView {
                if let jsonData = try? JSONEncoder().encode(Database.shared.fetchAll()),
                   let s = String(data: jsonData, encoding: .utf8)
                {
                  Text(s)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                } else {
                  Text("Failed to generate JSON")
                    .foregroundColor(.red)
                    .padding()
                }
              }
            case .table:
              List {
                HStack {
                  Text("ID").bold().frame(width:40, alignment:.leading)
                  Text("File").bold().frame(width:100, alignment:.leading)
                  Text("Date").bold().frame(maxWidth:.infinity, alignment:.leading)
                  Text("Person").bold().frame(width:80, alignment:.leading)
                  Text("Tag").bold().frame(width:80, alignment:.leading)
                  Text("Note").bold().frame(maxWidth:.infinity, alignment:.leading)
                }
                .font(.caption)
                ForEach(previewClips) { clip in
                  HStack(alignment:.top) {
                    Text("\(clip.id)").frame(width:40, alignment:.leading)
                    Text(clip.filename).frame(width:100, alignment:.leading)
                    Text(clip.timestamp.formatted(.dateTime.year().month().day()))
                      .frame(maxWidth:.infinity, alignment:.leading)
                    Text(clip.person).frame(width:80, alignment:.leading)
                    Text(clip.contextTag).frame(width:80, alignment:.leading)
                    Text(clip.note).frame(maxWidth:.infinity, alignment:.leading)
                  }
                  .font(.system(.caption, design:.monospaced))
                  .padding(.vertical,2)
                }
              }
            }
          }
          .animation(.default, value: dataFormat)

          Spacer()

          Button("Export as CSV") {
            doExport()
          }
          .buttonStyle(.borderedProminent)
          .padding(.horizontal)
        }
        .navigationTitle("All Clips")
        .toolbar {
          ToolbarItem(placement:.cancellationAction) {
            Button("Close") { showDataSheet = false }
          }
        }
      }
      .onAppear { updatePreview(for: dataFormat) }
    }
  }

  // MARK: — Helpers

  private func updatePreview(for format: DataFormat) {
    let clips = Database.shared.fetchAll()
    previewClips = clips
    dataPreview = (format == .csv) ? generateCSV(from: clips) : ""
  }

  private func doExport() {
    let clips = Database.shared.fetchAll()
    let csv   = generateCSV(from: clips)
    let tmp   = FileManager.default.temporaryDirectory
      .appendingPathComponent("EchoWellData.csv")
    do {
      try csv.write(to: tmp, atomically: true, encoding: .utf8)
      presentShareSheet(items: [tmp])
    } catch {
      print("❌ CSV export failed:", error)
    }
  }

  private func addTag() {
    let t = newTag.trimmingCharacters(in:.whitespaces)
    guard !t.isEmpty else { return }
    config.tagOptions.append(t)
    newTag = ""
  }
  private func deleteTags(at offs:IndexSet) {
    config.tagOptions.remove(atOffsets:offs)
  }
  private func addName() {
    let n = newName.trimmingCharacters(in:.whitespaces)
    guard !n.isEmpty else { return }
    config.nameOptions.append(n)
    newName = ""
  }
  private func deleteNames(at offs:IndexSet) {
    config.nameOptions.remove(atOffsets:offs)
  }
}
