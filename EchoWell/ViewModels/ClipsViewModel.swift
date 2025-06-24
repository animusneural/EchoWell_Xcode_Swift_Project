// App/ViewModels/ClipsViewModel.swift

import Foundation
import Combine

class ClipsViewModel: ObservableObject {
  @Published private(set) var allClips: [EchoClip] = []
  @Published var filter = ClipFilter()
  @Published private(set) var filteredClips: [EchoClip] = []

  private var cancellables = Set<AnyCancellable>()

  init() {
    // fetch once
    loadClips()

    // re-filter whenever source or filter changes
    Publishers.CombineLatest($allClips, $filter)
      .map { clips, filter in
        clips.filter { filter.matches($0) }
      }
      .assign(to: &$filteredClips)
  }

  func loadClips() {
    do {
      allClips = try Database.shared.fetchAll()
    } catch {
      print("Error fetching clips:", error)
      allClips = []
    }
  }

  func clearFilter() {
    filter = ClipFilter()
  }
}
