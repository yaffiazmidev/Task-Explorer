import SwiftUI

struct TaskStatusBadge: View {
    let isCompleted: Bool
    var style: BadgeStyle = .inline

    enum BadgeStyle {
        case inline
        case prominent
    }

    var body: some View {
        switch style {
        case .inline:
            inlineBadge
        case .prominent:
            prominentBadge
        }
    }

    private var inlineBadge: some View {
        Text(isCompleted ? "Completed" : "Pending")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(isCompleted ? Color.green.opacity(0.1) : Color(.secondarySystemBackground))
            .foregroundStyle(isCompleted ? Color.green : Color.secondary)
            .clipShape(Capsule())
    }

    private var prominentBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "hourglass")
                .font(.system(size: 13))
            Text(isCompleted ? "Completed" : "Pending")
                .font(.system(size: 12, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isCompleted ? Color.green.opacity(0.12) : Color(.secondarySystemBackground))
        .foregroundStyle(isCompleted ? Color.green : Color.secondary)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}
