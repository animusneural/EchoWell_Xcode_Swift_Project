import SwiftUI
import AVFoundation

struct ClipsListView: View {
    @EnvironmentObject var audio: AudioManager
    @State private var clips: [EchoClip] = []
    @State private var lastPlayedFilename: String? = nil

    var body: some View {
        List {
            ForEach(clips) { clip in
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
                                    .formatted(.dateTime
                                        .year().month().day()
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
                        // toggle play/pause:
                        if audio.isPlaying && lastPlayedFilename == clip.filename {
                            audio.pauseClip()
                        } else {
                            audio.playClip(at: clip.fileURL)
                            lastPlayedFilename = clip.filename
                        }
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
        .navigationTitle("Your Clips")
        .onAppear {
            clips = (try? Database.shared.fetchAll()) ?? []
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            let clip = clips[i]
            try? Database.shared.deleteClip(clip)
        }
        clips.remove(atOffsets: offsets)
    }

    /// Synchronously reads the audio file's duration
    private func duration(of clip: EchoClip) -> Int {
        guard let player = try? AVAudioPlayer(contentsOf: clip.fileURL) else {
            return 0
        }
        return Int(player.duration.rounded())
    }
}
