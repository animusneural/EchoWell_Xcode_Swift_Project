import SwiftUI

struct ClipRowView: View {
  let clip: EchoClip

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        // Your note + metadata
        Text(clip.note)
          .font(.body)

        Text("👤 \(clip.person) • 🏷 \(clip.contextTag)")
          .font(.caption)
          .foregroundColor(.secondary)

        Text(
          clip.timestamp
            .formatted(.dateTime.year().month().day()
                        .hour().minute())
        )
        .font(.caption2)
        .foregroundColor(.gray)

        // Now just reference the pre-computed duration
        if let secs = clip.durationSeconds {
          Text("\(secs)s")
            .font(.caption2.italic())
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      // Play button (optional hookup to your AudioManager)
      Button {
        // play logic here…
      } label: {
        Image(systemName: "play.circle")
          .font(.title2)
      }
      .buttonStyle(BorderlessButtonStyle())
    }
    .padding(.vertical, 6)
  }
}

struct ClipRowView_Previews: PreviewProvider {
  static var previews: some View {
    ClipRowView(clip: EchoClip(
      id: 1,
      filename: "sample.wav",
      timestamp: Date(),
      contextTag: "play",
      person: "Alice",
      note: "Testing duration"
    ))
    .previewLayout(.sizeThatFits)
  }
}
