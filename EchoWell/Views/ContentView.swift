import SwiftUI

struct ContentView: View {
  // MARK: Services
  @StateObject private var db     = Database.shared
  @StateObject private var audio  = AudioManager()
  @StateObject private var config = Config.shared

  // MARK: View state
  @State private var clips               = [EchoClip]()
  @State private var note                = ""      // Custom Text
  @State private var selectedPerson      = ""      // Person
  @State private var tag                 = ""      // Activity Tag
  @State private var isRecording         = false
  @State private var recordURL: URL?
  @State private var libraryViewType: LibraryViewType = .list

  // Track which clip is playing
  @State private var lastPlayedFilename: String?

  // Initialize default selections
  init() {
    let cfg = Config.shared
    _selectedPerson = State(initialValue: cfg.nameOptions.first ?? "")
    _tag            = State(initialValue: cfg.tagOptions.first ?? "")
  }

  var body: some View {
    TabView {
      recordView
        .tabItem { Label("Record", systemImage: "mic.circle") }

      libraryView
        .tabItem { Label("Library", systemImage: "waveform.path.ecg") }

      NavigationView { SettingsView() }
        .tabItem { Label("Settings", systemImage: "gearshape") }
    }
    .onAppear {
      loadClips()
    }
  }

  // MARK: — Record Tab
  private var recordView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("EchoWell")
          .font(.largeTitle).bold()

        // 1. Custom Text Field
        VStack(alignment: .leading, spacing: 4) {
          Text("Custom Text:")
            .font(.headline)
          TextField("Enter note…", text: $note)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }

        // 2. Person Picker
        VStack(alignment: .leading, spacing: 4) {
          Text("Person:")
            .font(.headline)
          Picker("Person", selection: $selectedPerson) {
            ForEach(config.nameOptions, id: \.self) { name in
              Text(name).tag(name)
            }
          }
          .pickerStyle(MenuPickerStyle())
        }

        // 3. Activity Tag Picker
        VStack(alignment: .leading, spacing: 4) {
          Text("Activity Tag:")
            .font(.headline)
          Picker("Tag", selection: $tag) {
            ForEach(config.tagOptions, id: \.self) { t in
              Text(t.capitalized).tag(t)
            }
          }
          .pickerStyle(MenuPickerStyle())
        }

        // 4. Record / Stop Button
        Button(action: toggleRecording) {
          HStack {
            Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
              .font(.system(size: 50))
              .foregroundColor(isRecording ? .red : .primary)
            Text(isRecording ? "Stop" : "Record")
              .font(.title2).bold()
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(RoundedRectangle(cornerRadius: 8).stroke())
        }

        Spacer()
      }
      .padding()
    }
  }

  // MARK: — Library Tab
  private var libraryView: some View {
    NavigationView {
      VStack {
        Picker("View", selection: $libraryViewType) {
          ForEach(LibraryViewType.allCases, id: \.self) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)

        if libraryViewType == .list {
          // List with swipe-to-delete and custom display
          List {
            ForEach(clips) { clip in
              HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                  Text(clip.note)
                    .font(.body)
                  Text("👤 \(clip.person)   •   🏷 \(clip.contextTag)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                  Text(
                    clip.timestamp
                        .formatted(
                            .dateTime
                                .year().month().day()
                                .hour().minute()
                        )
                  )
                    .font(.caption2)
                    .foregroundColor(.gray)
                }
                Spacer()
                playPauseButton(for: clip)
              }
              .padding(.vertical, 6)
            }
            .onDelete(perform: delete)
          }
        } else {
          // Grid: show same fields stacked
          ScrollView {
            LazyVGrid(
              columns: [GridItem(.flexible()), GridItem(.flexible())],
              spacing: 16
            ) {
              ForEach(clips) { clip in
                VStack(spacing: 8) {
                  Text(clip.note).font(.body)
                    Text("👤 \(clip.person)\n🏷 \(clip.contextTag)")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                  Text(
                    clip.timestamp
                        .formatted(
                            .dateTime
                                .year().month().day()
                                .hour().minute()
                        )
                  )
                    .font(.caption2)
                    .foregroundColor(.gray)
                  playPauseButton(for: clip)
                    .font(.title)
                    .padding(.top, 4)
                }
                .padding()
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
                )
              }
            }
            .padding()
          }
        }
      }
      .navigationTitle("Clips")
    }
  }

  // MARK: — Play/Pause Button
  private func playPauseButton(for clip: EchoClip) -> some View {
    Button {
      play(clip: clip)
    } label: {
      let isThisPlaying = audio.isPlaying && lastPlayedFilename == clip.filename
      Image(systemName: isThisPlaying ? "pause.circle.fill" : "play.circle")
    }
    .buttonStyle(BorderlessButtonStyle())
  }

  // MARK: — Actions

  private func toggleRecording() {
    if isRecording {
      audio.stopRecording()
      isRecording = false
      guard let url = recordURL else { return }
      db.insertClip(
        url: url,
        tag: tag,
        person: selectedPerson,
        note: note
      )
      loadClips()
    } else {
      let filename = "\(Int(Date().timeIntervalSince1970)).wav"
      recordURL = documentsURL().appendingPathComponent(filename)
      audio.startRecording(to: recordURL!)
      isRecording = true
    }
  }

  private func play(clip: EchoClip) {
    let url = documentsURL().appendingPathComponent(clip.filename)
    lastPlayedFilename = clip.filename
    audio.playClip(at: url)
  }

  private func delete(at offsets: IndexSet) {
    offsets.forEach { i in
      let clip = clips[i]
      db.deleteClip(clip)
    }
    loadClips()
  }

  private func loadClips() {
    clips = db.fetchAll()   // <- call the method with ()
  }

  private func documentsURL() -> URL {
    try! FileManager.default
      .url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
  }
}

// MARK: — Preview & Helpers
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

enum LibraryViewType: String, CaseIterable {
  case list = "List"
  case grid = "Grid"
}
