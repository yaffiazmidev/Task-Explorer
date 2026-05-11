import CoreData

protocol TaskLocalStorageProtocol: Sendable {
    func fetchTasks() -> [RemoteHomeItem]
    func saveTasks(_ tasks: [RemoteHomeItem])
    func updateCompletion(id: Int, completed: Bool)
    func getCompletionMap() -> [Int: Bool]
}

final class TaskLocalStorage: TaskLocalStorageProtocol, @unchecked Sendable {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchTasks() -> [RemoteHomeItem] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }

        return results.map { entity in
            RemoteHomeItem(
                id: Int(entity.id),
                userId: Int(entity.userId),
                title: entity.title,
                completed: entity.completed
            )
        }
    }

    func saveTasks(_ tasks: [RemoteHomeItem]) {
        for task in tasks {
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", Int64(task.id ?? 0))

            let entity = (try? context.fetch(request).first) ?? TaskEntity(context: context)

            entity.id = Int64(task.id ?? 0)
            entity.userId = Int64(task.userId ?? 0)
            entity.title = task.title
            entity.completed = task.completed ?? false
        }

        try? context.save()
    }

    func updateCompletion(id: Int, completed: Bool) {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", Int64(id))

        guard let entity = try? context.fetch(request).first else { return }
        entity.completed = completed
        try? context.save()
    }

    func getCompletionMap() -> [Int: Bool] {
        let request = TaskEntity.fetchRequest()
        guard let results = try? context.fetch(request) else { return [:] }

        var map: [Int: Bool] = [:]
        for entity in results {
            map[Int(entity.id)] = entity.completed
        }
        return map
    }
}
