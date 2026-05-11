import XCTest
import DENNetworking
@testable import Task_Explorer

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - Factory

    private func makeSUT(
        data: Data = HomeFixtures.todosJSON(),
        statusCode: Int = 200,
        localStorage: MockTaskLocalStorage = MockTaskLocalStorage()
    ) -> (HomeViewModel, MockTaskLocalStorage) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let client = MockHTTPClient.success(data: data, statusCode: statusCode)
        let networkService = DENNetworkService(client: client, decoder: JSONResponseDecoder(decoder: decoder))
        let service = HomeService(networkService: networkService)
        let vm = HomeViewModel(homeService: service, localStorage: localStorage)
        return (vm, localStorage)
    }

    private func makeFailingSUT(
        error: DENNetworkError,
        localStorage: MockTaskLocalStorage = MockTaskLocalStorage()
    ) -> (HomeViewModel, MockTaskLocalStorage) {
        let client = MockHTTPClient.failure(error)
        let networkService = DENNetworkService(client: client)
        let service = HomeService(networkService: networkService)
        let vm = HomeViewModel(homeService: service, localStorage: localStorage)
        return (vm, localStorage)
    }

    // MARK: - loadData

    func test_loadData_setsItems() async {
        let (sut, _) = makeSUT()

        await sut.loadData()

        XCTAssertEqual(sut.allItems.count, 2)
        XCTAssertEqual(sut.allItems[0].title, "delectus aut autem")
        XCTAssertEqual(sut.allItems[0].completed, false)
        XCTAssertEqual(sut.allItems[1].completed, true)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadData_cachesToLocalStorage() async {
        let storage = MockTaskLocalStorage()
        let (sut, _) = makeSUT(localStorage: storage)

        await sut.loadData()

        let cached = storage.fetchTasks()
        XCTAssertEqual(cached.count, 2)
    }

    func test_loadData_skipsIfAlreadyLoaded() async {
        let (sut, _) = makeSUT()

        await sut.loadData()
        let firstCount = sut.allItems.count

        await sut.loadData()

        XCTAssertEqual(sut.allItems.count, firstCount)
    }

    func test_loadData_fallsBackToCache_onNetworkError() async {
        let storage = MockTaskLocalStorage()
        storage.saveTasks([
            RemoteHomeItem(id: 99, userId: 1, title: "Cached Task", completed: false)
        ])
        let (sut, _) = makeFailingSUT(error: .notConnected, localStorage: storage)

        await sut.loadData()

        XCTAssertEqual(sut.allItems.count, 1)
        XCTAssertEqual(sut.allItems[0].title, "Cached Task")
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadData_setsError_whenNoCacheAndNetworkFails() async {
        let (sut, _) = makeFailingSUT(error: .notConnected)

        await sut.loadData()

        XCTAssertTrue(sut.allItems.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - toggleCompletion

    func test_toggleCompletion_togglesItemState() async {
        let (sut, _) = makeSUT()
        await sut.loadData()
        let firstItem = sut.allItems[0]
        XCTAssertFalse(firstItem.completed)

        sut.toggleCompletion(id: firstItem.id)

        XCTAssertTrue(sut.allItems[0].completed)
    }

    func test_toggleCompletion_persistsToLocalStorage() async {
        let storage = MockTaskLocalStorage()
        let (sut, _) = makeSUT(localStorage: storage)
        await sut.loadData()

        sut.toggleCompletion(id: 1)

        let map = storage.getCompletionMap()
        XCTAssertEqual(map[1], true)
    }

    func test_toggleCompletion_doubleToggleRestoresOriginal() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.toggleCompletion(id: 1)
        sut.toggleCompletion(id: 1)

        XCTAssertFalse(sut.allItems[0].completed)
    }

    // MARK: - Filtering

    func test_filter_all_returnsAllItems() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.selectedFilter = .all

        XCTAssertEqual(sut.items.count, 2)
    }

    func test_filter_completed_returnsOnlyCompleted() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.selectedFilter = .completed

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertTrue(sut.items.allSatisfy { $0.completed })
    }

    func test_filter_pending_returnsOnlyPending() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.selectedFilter = .pending

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertTrue(sut.items.allSatisfy { !$0.completed })
    }

    // MARK: - Search

    func test_search_filtersItemsByTitle() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.searchText = "delectus"

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items[0].id, 1)
    }

    func test_search_emptyText_returnsAll() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.searchText = ""

        XCTAssertEqual(sut.items.count, 2)
    }

    func test_search_noMatch_returnsEmpty() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        sut.searchText = "nonexistent"

        XCTAssertTrue(sut.items.isEmpty)
    }

    // MARK: - isCompleted

    func test_isCompleted_returnsFalseForPendingTask() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        XCTAssertFalse(sut.isCompleted(for: 1))
    }

    func test_isCompleted_returnsTrueForCompletedTask() async {
        let (sut, _) = makeSUT()
        await sut.loadData()

        XCTAssertTrue(sut.isCompleted(for: 2))
    }

    func test_isCompleted_returnsFalseForNonexistentId() {
        let (sut, _) = makeSUT()

        XCTAssertFalse(sut.isCompleted(for: 999))
    }
}
