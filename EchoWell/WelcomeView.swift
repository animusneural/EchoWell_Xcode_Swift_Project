/* Views/WelcomeView.swift

import SwiftUI

struct WelcomeView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var draftName: String = ""

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Welcome to EchoWell")
                .font(.largeTitle).bold()

            Text("What should we call you?")
                .font(.title2)
                .foregroundColor(.secondary)

            TextField("Your name", text: $draftName)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary))
                .padding(.horizontal, 40)

            Button(action: {
                userName = draftName   // once set, userName is non-empty
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(draftName.isEmpty
                                  ? Color.gray.opacity(0.5)
                                  : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(draftName.isEmpty)
            .padding(.horizontal, 40)

            Spacer()

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .transition(.opacity.combined(with: .slide))
    }
}
*/
