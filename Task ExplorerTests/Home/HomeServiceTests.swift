import XCTest
import DENNetworking
@testable import Task_Explorer

final class HomeServiceTests: XCTestCase {

    private func makeService(data: Data, statusCode: Int = 200) -> HomeService {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let client = MockHTTPClient.success(data: data, statusCode: statusCode)
        let networkService = DENNetworkService(client: client, decoder: JSONResponseDecoder(decoder: decoder))
        return HomeService(networkService: networkService)
    }

    private func makeFailingService(error: DENNetworkError) -> HomeService {
        let client = MockHTTPClient.failure(error)
        let networkService = DENNetworkService(client: client)
        return HomeService(networkService: networkService)
    }

    // MARK: - getTodos Success

    func test_getTodos_decodesResponse() async throws {
        let sut = makeService(data: HomeFixtures.todosJSON())

        let items = try await sut.getTodos()

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, 1)
        XCTAssertEqual(items[0].title, "delectus aut autem")
        XCTAssertEqual(items[0].completed, false)
        XCTAssertEqual(items[1].id, 2)
        XCTAssertEqual(items[1].completed, true)
    }

    func test_getTodos_emptyArray() async throws {
        let sut = makeService(data: HomeFixtures.emptyJSON)

        let items = try await sut.getTodos()

        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - getTodos Errors

    func test_getTodos_throwsOnServerError() async {
        let sut = makeFailingService(error: .serverError(statusCode: 500))

        do {
            _ = try await sut.getTodos()
            XCTFail("Expected error")
        } catch let error as DENNetworkError {
            XCTAssertEqual(error, .serverError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_getTodos_throwsOnNotConnected() async {
        let sut = makeFailingService(error: .notConnected)

        do {
            _ = try await sut.getTodos()
            XCTFail("Expected error")
        } catch let error as DENNetworkError {
            XCTAssertEqual(error, .notConnected)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
