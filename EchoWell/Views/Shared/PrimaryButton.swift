// App/Views/Shared/PrimaryButton.swift

import SwiftUI

struct PrimaryButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(Typography.body)
        .frame(maxWidth: .infinity)
        .padding()
    }
    .background(Color.accentColor)
    .foregroundColor(.white)
    .cornerRadius(8)
  }
}
