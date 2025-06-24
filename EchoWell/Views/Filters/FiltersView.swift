// App/Views/Filters/FiltersView.swift

import SwiftUI

struct FiltersView: View {
  @ObservedObject var viewModel: ClipsViewModel
  @Environment(\.presentationMode) var presentation

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Context Tag")) {
          TextField("e.g. Meeting", text: Binding(
            get: { viewModel.filter.tag ?? "" },
            set: { viewModel.filter.tag = $0.isEmpty ? nil : $0 }
          ))
        }
        Section(header: Text("Person")) {
          TextField("e.g. Alice", text: Binding(
            get: { viewModel.filter.person ?? "" },
            set: { viewModel.filter.person = $0.isEmpty ? nil : $0 }
          ))
        }
        Section(header: Text("Date Range")) {
          DatePicker("From", selection: Binding(
            get: { viewModel.filter.fromDate ?? Date() },
            set: { viewModel.filter.fromDate = $0 }
          ), displayedComponents: .date)
          Toggle("Use To-Date", isOn: Binding(
            get: { viewModel.filter.toDate != nil },
            set: { viewModel.filter.toDate = $0 ? Date() : nil }
          ))
          if viewModel.filter.toDate != nil {
            DatePicker("To", selection: Binding(
              get: { viewModel.filter.toDate! },
              set: { viewModel.filter.toDate = $0 }
            ), displayedComponents: .date)
          }
        }
      }
      .navigationTitle("Filters")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Apply") {
            presentation.wrappedValue.dismiss()
          }
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Clear") {
            viewModel.clearFilter()
          }
        }
      }
    }
  }
}
