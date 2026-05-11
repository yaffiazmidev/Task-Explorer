import Foundation
import SwiftUI

enum AppRoute: Hashable {
    case home
    case homeDetail(HomeItemViewModel)
}

@Observable
final class AppRouter {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
