import Foundation
import DENNetworking

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case pending = "Pending"
}

@Observable
class HomeViewModel {

    private let homeService: HomeServiceProtocol
    private let localStorage: TaskLocalStorageProtocol
    private(set) var allItems: [HomeItemViewModel] = []

    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String? = nil
    var searchText: String = ""
    var selectedFilter: TaskFilter = .all

    var items: [HomeItemViewModel] {
        let filtered: [HomeItemViewModel]

        switch selectedFilter {
        case .all:
            filtered = allItems
        case .completed:
            filtered = allItems.filter { $0.completed }
        case .pending:
            filtered = allItems.filter { !$0.completed }
        }

        guard !searchText.isEmpty else { return filtered }
        return filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    init(homeService: HomeServiceProtocol, localStorage: TaskLocalStorageProtocol) {
        self.homeService = homeService
        self.localStorage = localStorage
    }

    // MARK: - Initial Load

    func loadData() async {
        guard allItems.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let remote = try await homeService.getTodos()
            let merged = mergeWithLocalOverrides(remote)
            localStorage.saveTasks(merged)
            allItems = merged.asViewModels
            isLoading = false
        } catch {
            let cached = localStorage.fetchTasks()
            if !cached.isEmpty {
                allItems = cached.asViewModels
                isLoading = false
            } else {
                isLoading = false
                let networkError = error as? DENNetworkError
                errorMessage = networkError?.errorDescription ?? "An unexpected error occurred."
            }
        }
    }

    // MARK: - Pull to Refresh

    func refresh() async {
        isRefreshing = true
        errorMessage = nil

        do {
            let remote = try await homeService.getTodos()
            let merged = mergeWithLocalOverrides(remote)
            localStorage.saveTasks(merged)
            allItems = merged.asViewModels
        } catch {
            let networkError = error as? DENNetworkError
            errorMessage = networkError?.errorDescription ?? "An unexpected error occurred."
        }

        isRefreshing = false
    }

    // MARK: - Toggle Completion

    func toggleCompletion(id: Int) {
        guard let index = allItems.firstIndex(where: { $0.id == id }) else { return }
        let current = allItems[index]
        let newCompleted = !current.completed

        allItems[index] = HomeItemViewModel(
            id: current.id,
            userId: current.userId,
            title: current.title,
            completed: newCompleted
        )

        localStorage.updateCompletion(id: id, completed: newCompleted)
    }

    func isCompleted(for id: Int) -> Bool {
        allItems.first(where: { $0.id == id })?.completed ?? false
    }

    // MARK: - Merge

    private func mergeWithLocalOverrides(_ remoteTasks: [RemoteHomeItem]) -> [RemoteHomeItem] {
        let localMap = localStorage.getCompletionMap()
        guard !localMap.isEmpty else { return remoteTasks }

        return remoteTasks.map { remote in
            guard let localCompleted = localMap[remote.id ?? 0] else { return remote }
            return RemoteHomeItem(
                id: remote.id,
                userId: remote.userId,
                title: remote.title,
                completed: localCompleted
            )
        }
    }
}
