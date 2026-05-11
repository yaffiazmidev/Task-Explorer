import SwiftUI

struct AppNavigationModifier: ViewModifier {
    var dependencies: AppDependencies
    @Environment(HomeViewModel.self) var homeViewModel

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home:
                    let vm = dependencies.makeHomeViewModel()
                    HomeView(viewModel: vm)
                case .homeDetail(let item):
                    TaskDetailView(item: item, homeViewModel: homeViewModel)
                }
            }
    }
}

extension View {
    func withAppRouter(dependencies: AppDependencies) -> some View {
        self.modifier(AppNavigationModifier(dependencies: dependencies))
    }
}
