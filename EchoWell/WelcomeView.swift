// Views/WelcomeView.swift

import SwiftUI

struct WelcomeView: View {
  @Binding var didLaunch: Bool

  var body: some View {
    VStack(spacing: 40) {
      Spacer()

      Text("Bun venit, Matei!")
        .font(.largeTitle).bold()
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Text("Înregistrează-ți gândurile și revino oricând.")
        .font(.title3)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Spacer()

      Button(action: {
        // marchează că am trecut de ecranul de bun-venit
        didLaunch = true
      }) {
        Text("Începe")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding()
          .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
          .foregroundColor(.white)
      }
      .padding(.horizontal)

      Spacer()
    }
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView(didLaunch: .constant(false))
  }
}
