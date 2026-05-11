import Foundation

enum HomeFixtures {

    static func todosJSON() -> Data {
        let json = """
        [
            {
                "userId": 1,
                "id": 1,
                "title": "delectus aut autem",
                "completed": false
            },
            {
                "userId": 1,
                "id": 2,
                "title": "quis ut nam facilis et officia qui",
                "completed": true
            }
        ]
        """
        return Data(json.utf8)
    }

    static let emptyJSON = Data("[]".utf8)

    static let invalidJSON = Data("not json".utf8)
}
