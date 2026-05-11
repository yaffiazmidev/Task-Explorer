import Foundation

struct RemoteHomeItem: Decodable, Sendable {
    let id: Int?
    let userId: Int?
    let title: String?
    let completed: Bool?
}
