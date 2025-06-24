// App/Views/Shared/DropdownPicker.swift

import SwiftUI

struct DropdownPicker<Option: Hashable & CustomStringConvertible>: View {
  let title: String
  let options: [Option]
  @Binding var selection: Option?

  var body: some View {
    Menu {
      ForEach(options, id: \.self) { option in
        Button(option.description) {
          selection = option
        }
      }
      Button("Clear") {
        selection = nil
      }
    } label: {
      HStack {
        Text(selection?.description ?? title)
          .foregroundColor(selection == nil ? .secondary : .primary)
        Spacer()
        Image(systemName: "chevron.down")
          .foregroundColor(.secondary)
      }
      .padding(.vertical, 8)
      .padding(.horizontal)
      .background(Color("InputBackground"))
      .cornerRadius(8)
    }
  }
}
