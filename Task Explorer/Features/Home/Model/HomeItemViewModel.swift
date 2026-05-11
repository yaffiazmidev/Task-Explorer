import Foundation

struct HomeItemViewModel: Identifiable, Sendable, Hashable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

extension Array where Element == RemoteHomeItem {
    var asViewModels: [HomeItemViewModel] {
        map { .init(id: $0.id ?? 0, userId: $0.userId ?? 0, title: $0.title ?? "", completed: $0.completed ?? false) }
    }
}
