import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Bin] = []

    /// Free-tier cap. Kept comfortably above the seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 10

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Screwbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("items.json")
        load()
        if items.isEmpty {
            items = Self.seedData()
            save()
        }
    }

    static func seedData() -> [Bin] {
        [
        Bin(date: Date().addingTimeInterval(-0*86400*3), label: "Bin A3", contents: "M4 wood screws, 1in", qty: "~120", rating: 2),
        Bin(date: Date().addingTimeInterval(-1*86400*3), label: "Bin A3", contents: "M4 wood screws, 1in", qty: "~120", rating: 3),
        Bin(date: Date().addingTimeInterval(-2*86400*3), label: "Bin A3", contents: "M4 wood screws, 1in", qty: "~120", rating: 4),
        Bin(date: Date().addingTimeInterval(-3*86400*3), label: "Bin A3", contents: "M4 wood screws, 1in", qty: "~120", rating: 2)
        ]
    }

    var canAddMore: Bool { items.count < Self.freeLimit }

    func add(_ item: Bin) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Bin) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Bin) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Bin].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
