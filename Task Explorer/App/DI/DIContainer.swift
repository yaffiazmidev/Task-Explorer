import Foundation
import DENNetworking

class DIContainer {
    static let shared = DIContainer()

    lazy var appConfiguration = AppConfiguration()

    lazy var apiNetworkService: DENNetworkingServiceProtocol = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let config = DENApiNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            headers: ["Content-Type": "application/json"]
        )

        let httpClient = DENNetworkURLSessionHTTPClient()

        let authenticatedClient = AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            config: config
        )

        return DENNetworkService(
            client: authenticatedClient,
            decoder: JSONResponseDecoder(decoder: decoder)
        )
    }()

    lazy var taskLocalStorage: TaskLocalStorageProtocol = {
        TaskLocalStorage(context: CoreDataStack.shared.context)
    }()
}
