import XCTest
@testable import Task_Explorer

final class HomeModelTests: XCTestCase {

    // MARK: - RemoteHomeItem Decoding

    func test_remoteHomeItem_decodesFromJSON() throws {
        let data = HomeFixtures.todosJSON()
        let items = try JSONDecoder().decode([RemoteHomeItem].self, from: data)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, 1)
        XCTAssertEqual(items[0].userId, 1)
        XCTAssertEqual(items[0].title, "delectus aut autem")
        XCTAssertEqual(items[0].completed, false)
    }

    func test_remoteHomeItem_decodesEmptyArray() throws {
        let data = HomeFixtures.emptyJSON
        let items = try JSONDecoder().decode([RemoteHomeItem].self, from: data)

        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - asViewModels Mapping

    func test_asViewModels_mapsCorrectly() {
        let remote = [
            RemoteHomeItem(id: 1, userId: 1, title: "Task 1", completed: false),
            RemoteHomeItem(id: 2, userId: 2, title: "Task 2", completed: true)
        ]

        let viewModels = remote.asViewModels

        XCTAssertEqual(viewModels.count, 2)
        XCTAssertEqual(viewModels[0].id, 1)
        XCTAssertEqual(viewModels[0].title, "Task 1")
        XCTAssertEqual(viewModels[0].completed, false)
        XCTAssertEqual(viewModels[1].id, 2)
        XCTAssertEqual(viewModels[1].completed, true)
    }

    func test_asViewModels_handlesNilFieldsWithDefaults() {
        let remote = [
            RemoteHomeItem(id: nil, userId: nil, title: nil, completed: nil)
        ]

        let viewModels = remote.asViewModels

        XCTAssertEqual(viewModels[0].id, 0)
        XCTAssertEqual(viewModels[0].userId, 0)
        XCTAssertEqual(viewModels[0].title, "")
        XCTAssertEqual(viewModels[0].completed, false)
    }
}
