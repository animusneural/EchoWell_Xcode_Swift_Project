// Views/ClipsListView.swift

import SwiftUI
import AVFoundation

struct ClipsListView: View {
  // pull in the shared audio manager
  @EnvironmentObject var audio: AudioManager
  @ObservedObject private var config = Config.shared

  @State private var clips: [EchoClip] = []
  @State private var lastPlayedFilename: String? = nil

  // ── New filter state ──────────────────────────────────────────────────────
  @State private var filterTag: String    = "Filter Tags"
  @State private var filterPerson: String = "Filter People"
  @State private var searchText: String   = ""
  @State private var showSearchField = false

  // apply Tag, Person & free‐text filters
  private var filteredClips: [EchoClip] {
    clips.filter { clip in
      (filterTag == "Filter Tags"       || clip.contextTag == filterTag) &&
      (filterPerson == "Filter People"    || clip.person     == filterPerson) &&
      (searchText.isEmpty       || clip.note.localizedCaseInsensitiveContains(searchText))
    }
  }

  var body: some View {
    VStack(spacing: 12) {
      // ── FILTER CONTROLS ────────────────────────────────────────────────────
      HStack(spacing: 12) {
        // Tag picker
        Picker("Tag", selection: $filterTag) {
          Text("Filter Tags").tag("Filter Tags")
          ForEach(config.tagOptions, id: \.self) {
            Text($0.capitalized).tag($0)
          }
        }
        .pickerStyle(MenuPickerStyle())

        // Person picker
        Picker("Person", selection: $filterPerson) {
          Text("Filter People").tag("Filter People")
          ForEach(config.nameOptions, id: \.self) {
            Text($0).tag($0)
          }
        }
        .pickerStyle(MenuPickerStyle())

        // Magnifying‐glass toggle
        Button {
          withAnimation { showSearchField.toggle() }
        } label: {
          Image(systemName: "magnifyingglass")
            .imageScale(.large)
            .padding(6)
            .background(Circle().fill(Color(UIColor.secondarySystemFill)))
        }
      }
      .padding(.horizontal)

      // search bar appears *below* the pickers
      if showSearchField {
        TextField("Search notes…", text: $searchText)
          .padding(8)
          .background(RoundedRectangle(cornerRadius: 20)
                         .stroke(Color.secondary, lineWidth: 1))
          .padding(.horizontal)
          .transition(.move(edge: .top).combined(with: .opacity))
      }

      // ── FILTERED LIST ──────────────────────────────────────────────────────
      List {
        ForEach(filteredClips) { clip in
          HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
              Text(clip.note)
                .font(.body)
              Text("👤 \(clip.person) • 🏷 \(clip.contextTag)")
                .font(.caption).foregroundColor(.secondary)
              HStack(spacing: 8) {
                Text(clip.timestamp
                       .formatted(.dateTime.year().month().day()
                                   .hour().minute()))
                  .font(.caption2).foregroundColor(.gray)
                Text("\(duration(of: clip))s")
                  .font(.caption2.monospacedDigit())
                  .foregroundColor(.gray)
              }
            }

            Spacer()

            Button {
              // AudioManager.playClip(at:) toggles play/pause internally
              audio.playClip(at: clip.fileURL)
              lastPlayedFilename = clip.filename
            } label: {
              Image(systemName:
                      (audio.isPlaying && lastPlayedFilename == clip.filename)
                      ? "pause.circle.fill"
                      : "play.circle"
              )
              .font(.title2)
            }
            .buttonStyle(BorderlessButtonStyle())
          }
          .padding(.vertical, 6)
        }
        .onDelete(perform: delete)
      }
    }
    .navigationTitle("Your Clips")
    .onAppear {
      clips = (try? Database.shared.fetchAll()) ?? []
    }
  }

  // MARK: — Actions

  private func delete(at offsets: IndexSet) {
    // delete from filteredClips *and* update the master list
    offsets.forEach { index in
      let clip = filteredClips[index]
      try? Database.shared.deleteClip(clip)
    }
    clips = (try? Database.shared.fetchAll()) ?? []
  }

  /// Read duration from file:
  private func duration(of clip: EchoClip) -> Int {
    guard let player = try? AVAudioPlayer(contentsOf: clip.fileURL) else {
      return 0
    }
    return Int(player.duration.rounded())
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
