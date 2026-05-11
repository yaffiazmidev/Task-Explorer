import Foundation
import DENNetworking

enum HomeEndpoint {
    case getTodos

    func makeRequest() throws -> URLRequest {
        switch self {
        case .getTodos:
            return try URLRequest
                .path("todos")
                .build()
        }
    }
}
