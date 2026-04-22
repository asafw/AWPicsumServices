/// AWPicsumServices — Live Integration Tests
///
/// These tests make real HTTP calls to the Lorem Picsum API to validate that:
///   1. The JSON response shapes still match the Swift models
///   2. Photo image URLs resolve and return non-empty Data
///   3. Single-photo info endpoint works correctly
///
/// **No API key required** — Lorem Picsum is a free, open API.
///
/// **Run locally only — skip in CI to avoid network dependency.**
///
/// Usage:
///   swift test --filter AWPicsumServicesIntegrationTests
///
/// Or via xcodebuild:
///   xcodebuild -scheme AWPicsumServices \
///     -destination "platform=macOS" \
///     -only-testing:AWPicsumServicesIntegrationTests test

import XCTest
@testable import AWPicsumServices

private let isCI = ProcessInfo.processInfo.environment["CI"] != nil

final class PicsumPhotosIntegrationTests: XCTestCase {

    private var repository: PicsumAPIService!

    override func setUp() {
        super.setUp()
        repository = PicsumAPIService()
    }

    // MARK: - getPhotos

    func testGetPhotosFirstPageReturnsPhotos() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let photos = try await repository.getPhotos(
            photosRequest: PicsumPhotosRequest(page: 1, limit: 5)
        )
        XCTAssertFalse(photos.isEmpty, "First page should return at least one photo")
        XCTAssertLessThanOrEqual(photos.count, 5)
    }

    func testGetPhotosResponseHasValidFields() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let photos = try await repository.getPhotos(
            photosRequest: PicsumPhotosRequest(page: 1, limit: 1)
        )
        let photo = try XCTUnwrap(photos.first, "Expected at least one photo")
        XCTAssertFalse(photo.id.isEmpty, "Photo id must not be empty")
        XCTAssertFalse(photo.author.isEmpty, "Photo author must not be empty")
        XCTAssertGreaterThan(photo.width, 0)
        XCTAssertGreaterThan(photo.height, 0)
        XCTAssertFalse(photo.downloadURL.isEmpty)
        XCTAssertTrue(photo.downloadURL.hasPrefix("https://"), "download_url must be HTTPS")
    }

    func testGetPhotosSecondPageReturnsDifferentPhotos() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let page1 = try await repository.getPhotos(
            photosRequest: PicsumPhotosRequest(page: 1, limit: 5)
        )
        let page2 = try await repository.getPhotos(
            photosRequest: PicsumPhotosRequest(page: 2, limit: 5)
        )
        let page1IDs = Set(page1.map { $0.id })
        let page2IDs = Set(page2.map { $0.id })
        XCTAssertTrue(page1IDs.isDisjoint(with: page2IDs), "Pages 1 and 2 should not overlap")
    }

    func testGetPhotosBeyondLastPageReturnsEmpty() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let photos = try await repository.getPhotos(
            photosRequest: PicsumPhotosRequest(page: 9999, limit: 30)
        )
        XCTAssertTrue(photos.isEmpty, "A very high page number should return an empty array")
    }

    // MARK: - getPhoto (single)

    func testGetPhotoByIDReturnsCorrectPhoto() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        // Photo 237 is a well-known Picsum photo (the dog)
        let photo = try await repository.getPhoto(photoRequest: PicsumPhotoRequest(id: "237"))
        XCTAssertEqual(photo.id, "237")
        XCTAssertFalse(photo.author.isEmpty)
        XCTAssertGreaterThan(photo.width, 0)
        XCTAssertGreaterThan(photo.height, 0)
    }

    func testGetPhotoInvalidIDThrowsNetworkError() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        do {
            _ = try await repository.getPhoto(photoRequest: PicsumPhotoRequest(id: "999999999"))
            XCTFail("Expected a network error for an invalid photo ID")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .networkError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - downloadImageData

    func testDownloadImageDataReturnsNonEmptyBytes() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let url = URL(string: "https://picsum.photos/id/237/200/200")!
        let data = try await repository.downloadImageData(from: url)
        XCTAssertGreaterThan(data.count, 0, "Image data must be non-empty")
    }

    func testImageURLStringResolvesToNonEmptyData() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let photo = try await repository.getPhoto(photoRequest: PicsumPhotoRequest(id: "10"))
        let urlString = photo.imageURLString(width: 100, height: 100)
        let url = try XCTUnwrap(URL(string: urlString))
        let data = try await repository.downloadImageData(from: url)
        XCTAssertGreaterThan(data.count, 0, "Resized image URL must resolve to data")
    }
}

// MARK: - PicsumService integration

final class PicsumServiceIntegrationTests: XCTestCase {

    func testPicsumServiceConvenienceTypeWorksEndToEnd() async throws {
        try XCTSkipIf(isCI, "Skipping live network tests in CI")
        let service = PicsumService()
        let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1, limit: 3))
        XCTAssertFalse(photos.isEmpty)

        let first = try XCTUnwrap(photos.first)
        let info = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: first.id))
        XCTAssertEqual(info.id, first.id)

        let url = URL(string: info.imageURLString(width: 100, height: 100))!
        let data = try await service.downloadImageData(from: url)
        XCTAssertGreaterThan(data.count, 0)
    }
}
