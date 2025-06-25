import SwiftUI
import AVFoundation

struct ClipsListView: View {
    @EnvironmentObject var audio: AudioManager
    @ObservedObject private var config = Config.shared

    @State private var clips: [EchoClip] = []
    @State private var lastPlayedFilename: String? = nil

    // Filters
    @State private var filterTag: String    = "All Tags"
    @State private var filterPerson: String = "All People"
    @State private var searchText: String   = ""
    @State private var showSearchField = false

    private var filteredClips: [EchoClip] {
        clips.filter { clip in
            (filterTag == "All Tags" || clip.contextTag == filterTag) &&
            (filterPerson == "All People" || clip.person == filterPerson) &&
            (searchText.isEmpty || clip.note.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // ── FILTER CONTROLS ──
            HStack(spacing: 12) {
                Picker("Tag", selection: $filterTag) {
                    Text("All Tags").tag("All Tags")
                    ForEach(config.tagOptions, id:\.self) {
                        Text($0.capitalized).tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Person", selection: $filterPerson) {
                    Text("All People").tag("All People")
                    ForEach(config.nameOptions, id:\.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Button {
                    withAnimation { showSearchField.toggle() }
                } label: {
                    Image(systemName: "magnifyingglass")
                      .imageScale(.large)
                      .padding(8)
                      .background(Circle().fill(Color(UIColor.secondarySystemFill)))
                }
            }
            .padding(.horizontal)

            if showSearchField {
                TextField("Search notes…", text: $searchText)
                  .padding(8)
                  .background(RoundedRectangle(cornerRadius:20)
                                 .stroke(Color.secondary,lineWidth:1))
                  .padding(.horizontal)
                  .transition(.move(edge:.top).combined(with:.opacity))
            }

            // ── FILTERED LIST ──
            List {
                ForEach(filteredClips) { clip in
                    HStack(alignment:.top, spacing:12) {
                        VStack(alignment:.leading, spacing:4) {
                            Text(clip.note).font(.body)
                            Text("👤 \(clip.person) • 🏷 \(clip.contextTag)")
                              .font(.caption).foregroundColor(.secondary)
                            Text("\(duration(of: clip))s")
                              .font(.caption2.monospacedDigit())
                              .foregroundColor(.gray)
                        }

                        Spacer()

                        // Play/Pause button
                        Button {
                            if audio.isPlaying && lastPlayedFilename == clip.filename {
                                audio.pauseClip()
                            } else {
                                audio.playClip(at: clip.fileURL)
                                lastPlayedFilename = clip.filename
                            }
                        } label: {
                            Image(systemName:
                                (audio.isPlaying && lastPlayedFilename == clip.filename)
                                  ? "pause.circle.fill" : "play.circle"
                            )
                            .font(.title2)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .accessibilityLabel("Play")
                        .accessibilityIdentifier("play.circle")

                        // Share button
                        Button {
                            presentShareSheet(items:[clip.fileURL])
                        } label: {
                            Image(systemName:"square.and.arrow.up")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 8)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = filteredClips.firstIndex(where: { $0.id == clip.id }) {
                                delete(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
        }
        .navigationTitle("Your Clips")
        .onAppear {
            clips = (try? Database.shared.fetchAll()) ?? []
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach { i in
            let clip = filteredClips[i]
            try? Database.shared.deleteClip(clip)
        }
        clips = (try? Database.shared.fetchAll()) ?? []
    }

    private func duration(of clip: EchoClip) -> Int {
        guard let p = try? AVAudioPlayer(contentsOf: clip.fileURL) else { return 0 }
        return Int(p.duration.rounded())
    }
}

struct ClipsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClipsListView()
              .environmentObject(AudioManager())
        }
    }
}
