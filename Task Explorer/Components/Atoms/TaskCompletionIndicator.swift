import SwiftUI

struct TaskCompletionIndicator: View {
    let isCompleted: Bool
    var size: CGFloat = 24
    var onToggle: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : Color.clear)
                .frame(width: size, height: size)
            Circle()
                .stroke(isCompleted ? Color.green : Color(.separator), lineWidth: 2)
                .frame(width: size, height: size)
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .onTapGesture {
            onToggle?()
        }
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}
