import SwiftUI

struct TaskRowSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .frame(width: 70, height: 14)
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 4, height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 14)
                }
            }

            Spacer()

            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray5))
                .frame(width: 8, height: 14)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
        )
        .shimmer()
    }
}

struct TaskRowSkeletonList: View {
    var count: Int = 8

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                TaskRowSkeleton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}
