// App/Views/Shared/CardView.swift

import SwiftUI

struct CardView<Content: View>: View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      content()
        .padding()
    }
    .background(Color("CardBackground"))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
  }
}
