import Foundation

struct Bin: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var label: String
    var contents: String
    var qty: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), label: String, contents: String, qty: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.label = label
        self.contents = contents
        self.qty = qty
        self.rating = rating
    }
}
