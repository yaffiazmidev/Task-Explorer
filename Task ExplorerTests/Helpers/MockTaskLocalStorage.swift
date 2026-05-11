import Foundation
@testable import Task_Explorer

final class MockTaskLocalStorage: TaskLocalStorageProtocol, @unchecked Sendable {

    private var tasks: [RemoteHomeItem] = []

    func fetchTasks() -> [RemoteHomeItem] {
        tasks
    }

    func saveTasks(_ tasks: [RemoteHomeItem]) {
        self.tasks = tasks
    }

    func updateCompletion(id: Int, completed: Bool) {
        tasks = tasks.map { task in
            guard task.id == id else { return task }
            return RemoteHomeItem(id: task.id, userId: task.userId, title: task.title, completed: completed)
        }
    }

    func getCompletionMap() -> [Int: Bool] {
        var map: [Int: Bool] = [:]
        for task in tasks {
            map[task.id ?? 0] = task.completed
        }
        return map
    }
}
