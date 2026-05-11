import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) var router
    @State var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: Bindable(viewModel).searchText, placeholder: "Search tasks...")
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

            filterChips
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            Divider()

            list
        }
        .navigationTitle("Task Explorer")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadData()
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
        }
    }

    private var list: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.isLoading {
                TaskRowSkeletonList()
            } else if let message = viewModel.errorMessage {
                ErrorStateView(message: message) {
                    Task { await viewModel.loadData() }
                }
            } else if viewModel.items.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No tasks found",
                    subtitle: "Try changing your search or filter"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
                        TaskRowCard(item: item) {
                            router.push(.homeDetail(item))
                        } onToggle: {
                            viewModel.toggleCompletion(id: item.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    NavigationStack {
        let dependencies = AppDependencies()
        let viewModel = dependencies.makeHomeViewModel()
        HomeView(viewModel: viewModel)
            .environment(AppRouter())
    }
}
