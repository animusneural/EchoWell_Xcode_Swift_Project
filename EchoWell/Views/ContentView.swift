// Views/ContentView.swift

import SwiftUI
import Charts       // for AnalyticsView
import Combine
import AVFoundation // for real-time audio duration if needed

struct ContentView: View {
    // MARK: – Services & Config
    @StateObject private var db     = Database.shared
    @StateObject private var audio  = AudioManager()
    @StateObject private var config = Config.shared

    // MARK: – View State
    @State private var clips               = [EchoClip]()    // all clips for library
    @State private var note                = ""              // record note text
    @State private var selectedPerson      = ""              // chosen person tag
    @State private var tag                 = ""              // chosen activity tag
    @State private var isRecording         = false           // recording in progress?
    @State private var recordURL: URL?                        // where to save the .wav
    @State private var libraryViewType: LibraryViewType = .list
    @State private var lastPlayedFilename: String?           // track playback
    @State private var elapsedSeconds: Int = 0               // live record timer

    // Timer to tick every second
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
                            .autoconnect()

    // MARK: – Default Picker Selections
    init() {
        let cfg = Config.shared
        _selectedPerson = State(initialValue: cfg.nameOptions.first ?? "")
        _tag            = State(initialValue: cfg.tagOptions.first ?? "")
    }

    // MARK: — Main Body
    var body: some View {
        TabView {
            // — Record Tab —
            NavigationView {
                recordView
                    .navigationTitle("Record")
                    .navigationBarTitleDisplayMode(.inline)
                    // every second while recording, increment timer
                    .onReceive(timer) { _ in
                        if isRecording { elapsedSeconds += 1 }
                    }
                    // when stopping, reset timer
                    .onChange(of: isRecording) { recording in
                        if !recording { elapsedSeconds = 0 }
                    }
            }
            .tabItem {
                Label("Record", systemImage: "mic.circle")
            }

            // — Library Tab —
            NavigationView {
                ClipsListView()
                    .navigationTitle("Your Clips")
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(audio)
            }
            .tabItem {
                Label("Library", systemImage: "waveform.path.ecg")
            }

            // — Analytics Tab —
            NavigationView {
                AnalyticsView()
                    .navigationTitle("Analytics")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.bar")
            }

            // — Settings Tab —
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        // on first appearance, load saved clips
        .onAppear {
            clips = (try? db.fetchAll()) ?? []
        }
    }

    // MARK: — Record View Sub-Layout
    private var recordView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1) App title
                Text("EchoWell")
                    .font(.largeTitle).bold()

                // 2) Big timer display, center-aligned
                Text(timeString(from: elapsedSeconds))
                    .font(.system(size: 48, weight: .semibold, design: .monospaced))
                    .foregroundColor(isRecording
                                     ? (elapsedSeconds >= 15 ? .green : .red)
                                     : .primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)

                // 3) Custom Text Field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Custom Text:")
                        .font(.headline)
                    TextField("Enter note…", text: $note)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // 4) Person Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Person:")
                        .font(.headline)
                    Picker("Person", selection: $selectedPerson) {
                        ForEach(config.nameOptions, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 5) Activity Tag Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activity Tag:")
                        .font(.headline)
                    Picker("Tag", selection: $tag) {
                        ForEach(config.tagOptions, id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 6) Record / Stop Button
                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                            .font(.system(size: 50))
                            .foregroundColor(
                                isRecording
                                  ? (elapsedSeconds >= 15 ? .green : .red)
                                  : .primary
                            )
                        Text(isRecording ? "Stop" : "Record")
                            .font(.title2).bold()
                            .foregroundColor(
                                isRecording
                                  ? (elapsedSeconds >= 15 ? .green : .red)
                                  : .primary
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .accessibilityIdentifier("recordButton")  // Fixed identifier

                // 7) Status message below the button
                if isRecording {
                    Text(elapsedSeconds >= 15 ? "Good to go!" : "Hold to record…")
                        .font(.headline.monospacedDigit())
                        .foregroundColor(elapsedSeconds >= 15 ? .green : .red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: — Actions

    /// Toggles recording on/off and saves clip when stopping
    private func toggleRecording() {
        if isRecording {
            audio.stopRecording()
            isRecording = false
            if let url = recordURL {
                try? db.insertClip(url: url,
                                   tag: tag,
                                   person: selectedPerson,
                                   note: note)
            }
        } else {
            let filename = "\(Int(Date().timeIntervalSince1970)).wav"
            recordURL = documentsURL().appendingPathComponent(filename)
            audio.startRecording(to: recordURL!)
            isRecording = true
        }
    }

    /// Helper to locate Documents directory
    private func documentsURL() -> URL {
        try! FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: true)
    }

    /// Format seconds as MM:SS
    private func timeString(from seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: — Preview & Library Selector

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum LibraryViewType: String, CaseIterable {
    case list = "List"
    case grid = "Grid"
}
