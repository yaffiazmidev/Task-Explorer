import Foundation

@Observable
class AppDependencies {

    func makeHomeViewModel() -> HomeViewModel {
        let networkService = DIContainer.shared.apiNetworkService
        let localStorage = DIContainer.shared.taskLocalStorage
        let homeService = HomeService(networkService: networkService)
        return HomeViewModel(homeService: homeService, localStorage: localStorage)
    }
}
