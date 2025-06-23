import Foundation
import Combine

/// Central store for app settings, persisted via UserDefaults.
class Config: ObservableObject {
  static let shared = Config()

  // MARK: — Recording parameters
  @Published var recordDuration: Double
  @Published var sampleRate: Double

  // MARK: — Dynamic lists
  @Published var tagOptions: [String]
  @Published var nameOptions: [String]

  private var cancellables = Set<AnyCancellable>()
  private let defaults = UserDefaults.standard

  private init() {
    // Load or default recording duration
    let rd = defaults.double(forKey: "recordDuration")
    recordDuration = rd > 0 ? rd : 5.0

    // Load or default sample rate
    let sr = defaults.double(forKey: "sampleRate")
    sampleRate = sr > 0 ? sr : 16000.0

    // Load or default tags
    if let data = defaults.data(forKey: "tagOptions"),
       let arr  = try? JSONDecoder().decode([String].self, from: data) {
      tagOptions = arr
    } else {
      tagOptions = ["play", "calm", "humming", "stimming", "other"]
    }

    // Load or default names
    if let data = defaults.data(forKey: "nameOptions"),
       let arr  = try? JSONDecoder().decode([String].self, from: data) {
      nameOptions = arr
    } else {
      nameOptions = []
    }

    // Persist changes to recordDuration
    $recordDuration
      .sink { [weak self] newValue in
        self?.defaults.set(newValue, forKey: "recordDuration")
      }
      .store(in: &cancellables)

    // Persist changes to sampleRate
    $sampleRate
      .sink { [weak self] newValue in
        self?.defaults.set(newValue, forKey: "sampleRate")
      }
      .store(in: &cancellables)

    // Persist changes to tags
    $tagOptions
      .sink { [weak self] arr in
        guard let data = try? JSONEncoder().encode(arr) else { return }
        self?.defaults.set(data, forKey: "tagOptions")
      }
      .store(in: &cancellables)

    // Persist changes to names
    $nameOptions
      .sink { [weak self] arr in
        guard let data = try? JSONEncoder().encode(arr) else { return }
        self?.defaults.set(data, forKey: "nameOptions")
      }
      .store(in: &cancellables)
  }
}
