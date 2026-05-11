import Foundation
import DENNetworking

protocol HomeServiceProtocol {
    func getTodos() async throws -> [RemoteHomeItem]
}

final class HomeService: HomeServiceProtocol {

    private let networkService: DENNetworkingServiceProtocol

    init(networkService: DENNetworkingServiceProtocol) {
        self.networkService = networkService
    }

    func getTodos() async throws -> [RemoteHomeItem] {
        let request = try HomeEndpoint.getTodos.makeRequest()
        return try await networkService.execute(request)
    }
}
