// Views/ClipsListView.swift

import SwiftUI
import AVFoundation

struct ClipsListView: View {
  // pull in the shared audio manager
  @EnvironmentObject var audio: AudioManager
  @ObservedObject private var config = Config.shared

  @State private var clips: [EchoClip] = []
  @State private var lastPlayedFilename: String? = nil

  // ── Filter state ─────────────────────────────────────────────────────────
  @State private var filterTag: String    = "All"    // ← default now "All"
  @State private var filterPerson: String = "All"    // ← default now "All"
  @State private var searchText: String   = ""
  @State private var showSearchField = false

  // apply Tag, Person & free‐text filters
  private var filteredClips: [EchoClip] {
    clips.filter { clip in
      (filterTag    == "All" || clip.contextTag == filterTag) &&
      (filterPerson == "All" || clip.person     == filterPerson) &&
      (searchText.isEmpty || clip.note.localizedCaseInsensitiveContains(searchText))
    }
  }

  var body: some View {
    VStack(spacing: 12) {
      // ── FILTER CONTROLS ────────────────────────────────────────────────────
      HStack(spacing: 12) {
        // Tag picker
        Picker("Tag", selection: $filterTag) {
          Text("All Tags").tag("All")
          ForEach(config.tagOptions, id: \.self) {
            Text($0.capitalized).tag($0)
          }
        }
        .pickerStyle(MenuPickerStyle())

        // Person picker
        Picker("Person", selection: $filterPerson) {
          Text("All People").tag("All")
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

      // inline search field
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
                .font(.caption)
                .foregroundColor(.secondary)
              HStack(spacing: 8) {
                Text(
                  clip.timestamp
                    .formatted(.dateTime.year().month().day()
                                .hour().minute())
                )
                .font(.caption2)
                .foregroundColor(.gray)

                // show duration
                Text("\(duration(of: clip))s")
                  .font(.caption2.monospacedDigit())
                  .foregroundColor(.gray)
              }
            }

            Spacer()

            Button {
              audio.playClip(at: clip.fileURL)
              lastPlayedFilename = clip.filename
            } label: {
              Image(systemName:
                      (audio.isPlaying && lastPlayedFilename == clip.filename)
                      ? "pause.circle.fill"
                      : "play.circle"
              )
              .font(.title2)
              .accessibilityLabel(
                (audio.isPlaying && lastPlayedFilename == clip.filename)
                  ? "Pause clip"
                  : "Play clip"
              )
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
