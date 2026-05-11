import SwiftUI

struct TaskDetailView: View {
    @Environment(AppRouter.self) var router
    let item: HomeItemViewModel
    let homeViewModel: HomeViewModel

    private var isCompleted: Bool {
        homeViewModel.isCompleted(for: item.id)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                metaSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .safeAreaInset(edge: .bottom) {
            bottomAction
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.body.weight(.semibold))
                    }
                }
                .tint(.primary)
            }

            ToolbarItem(placement: .principal) {
                Text("Task #\(item.id)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TaskStatusBadge(isCompleted: isCompleted, style: .prominent)

            Text(item.title.capitalized)
                .font(.system(size: 34, weight: .bold, design: .default))
                .lineSpacing(4)
                .strikethrough(isCompleted, color: .secondary)
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .animation(.easeInOut(duration: 0.2), value: isCompleted)
        }
    }

    // MARK: - Meta

    private var metaSection: some View {
        HStack(spacing: 12) {
            MetaCard(icon: "number", label: "Task ID", value: "#\(item.id)")
            MetaCard(icon: "person", label: "User ID", value: "#\(item.userId)")
        }
    }

    // MARK: - Bottom Action

    private var bottomAction: some View {
        Button {
            homeViewModel.toggleCompletion(id: item.id)
        } label: {
            Text(isCompleted ? "Mark as Pending" : "Mark as Complete")
        }
        .buttonStyle(.borderedProminent)
        .tint(isCompleted ? .gray : .primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    let deps = AppDependencies()
    let vm = deps.makeHomeViewModel()
    NavigationStack {
        TaskDetailView(item: .init(id: 1, userId: 1, title: "delectus aut autem", completed: false), homeViewModel: vm)
            .environment(AppRouter())
    }
}
