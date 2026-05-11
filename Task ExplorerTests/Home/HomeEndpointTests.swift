import XCTest
@testable import Task_Explorer

final class HomeEndpointTests: XCTestCase {

    // MARK: - getTodos

    func test_getTodos_buildsCorrectPath() throws {
        let request = try HomeEndpoint.getTodos.makeRequest()

        XCTAssertEqual(request.url?.path, "todos")
    }

    func test_getTodos_defaultsToGET() throws {
        let request = try HomeEndpoint.getTodos.makeRequest()

        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_getTodos_hasNoBody() throws {
        let request = try HomeEndpoint.getTodos.makeRequest()

        XCTAssertNil(request.httpBody)
    }

    func test_getTodos_hasNoQueryItems() throws {
        let request = try HomeEndpoint.getTodos.makeRequest()
        let queryItems = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems

        XCTAssertNil(queryItems)
    }
}
