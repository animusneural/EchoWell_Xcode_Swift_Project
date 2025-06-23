import SwiftUI

struct SettingsView: View {
  @StateObject private var config = Config.shared
  @State private var newTag      = ""
  @State private var newName     = ""
  
  var body: some View {
    Form {
      // — Data Export —
      Section(header: Text("Data")) {
        Button(action: exportData) {
          Label("Export All Clips as CSV", systemImage: "square.and.arrow.up")
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
  }

  // MARK: — Handlers
  private func addTag() {
    let t = newTag.trimmingCharacters(in: .whitespaces)
    guard !t.isEmpty else { return }
    config.tagOptions.append(t)
    newTag = ""
  }
  private func deleteTags(at offsets: IndexSet) {
    config.tagOptions.remove(atOffsets: offsets)
  }
  private func addName() {
    let n = newName.trimmingCharacters(in: .whitespaces)
    guard !n.isEmpty else { return }
    config.nameOptions.append(n)
    newName = ""
  }
  private func deleteNames(at offsets: IndexSet) {
    config.nameOptions.remove(atOffsets: offsets)
  }
  private func exportData() {
    let clips = Database.shared.fetchAll()
    let csv   = generateCSV(from: clips)
    presentShareSheet(with: csv, filename: "EchoWellData.csv")
  }
}
