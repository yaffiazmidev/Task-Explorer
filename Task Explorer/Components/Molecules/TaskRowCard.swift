import SwiftUI

struct TaskRowCard: View {
    let item: HomeItemViewModel
    let onTap: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TaskCompletionIndicator(isCompleted: item.completed) {
                onToggle()
            }

            Button(action: onTap) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title.capitalized)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(item.completed ? Color.secondary : Color.primary)
                            .strikethrough(item.completed, color: .secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            TaskStatusBadge(isCompleted: item.completed)
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("ID: #\(item.id)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 12)
        .padding(.trailing, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
        )
        .opacity(item.completed ? 0.7 : 1.0)
    }
}
