import SwiftUI
import DENNetworking

@main
struct Task_ExplorerApp: App {
    @State private var router = AppRouter()
    @State private var dependencies = AppDependencies()
    @State private var homeViewModel: HomeViewModel

    init() {
        let deps = AppDependencies()
        _dependencies = State(initialValue: deps)
        _homeViewModel = State(initialValue: deps.makeHomeViewModel())

        #if DEBUG
        DENNetworkLogger.isEnabled = true
        #endif
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeView(viewModel: homeViewModel)
                    .withAppRouter(dependencies: dependencies)
            }
            .environment(router)
            .environment(homeViewModel)
        }
    }
}
