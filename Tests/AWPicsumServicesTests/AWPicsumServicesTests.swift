import XCTest
@testable import AWPicsumServices

// MARK: - CapturingURLProtocol

/// Captures the last request made through a URLSession configured with this protocol.
/// Responds with configurable stubbed data and status code — no network required.
final class CapturingURLProtocol: URLProtocol {
    static var lastRequest: URLRequest?
    static var stubbedData: Data = Data()
    static var stubbedStatusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        CapturingURLProtocol.lastRequest = request
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: CapturingURLProtocol.stubbedStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: CapturingURLProtocol.stubbedData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

/// Helper that builds a URLSession backed by CapturingURLProtocol.
private func makeStubbedSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [CapturingURLProtocol.self]
    return URLSession(configuration: config)
}

// MARK: - PicsumEndpoints

final class PicsumEndpointsTests: XCTestCase {

    func testBaseURLIsPicsumPhotos() {
        XCTAssertEqual(PicsumEndpoints.baseURL, "https://picsum.photos")
    }

    func testListPathIsV2List() {
        XCTAssertEqual(PicsumEndpoints.listPath, "/v2/list")
    }

    func testInfoPathContainsID() {
        let path = String(format: PicsumEndpoints.infoPath, "237")
        XCTAssertEqual(path, "/id/237/info")
    }

    func testImageURLTemplateContainsID() {
        let url = String(format: PicsumEndpoints.imageURLTemplate, "237", 400, 300)
        XCTAssertEqual(url, "https://picsum.photos/id/237/400/300")
    }
}

// MARK: - PicsumPhoto

final class PicsumPhotoTests: XCTestCase {

    private func makePhoto(
        id: String = "237",
        author: String = "Tanner Mardis",
        width: Int = 3500,
        height: Int = 2333,
        url: String = "https://unsplash.com/photos/photo",
        downloadURL: String = "https://picsum.photos/id/237/3500/2333"
    ) -> PicsumPhoto {
        let json = """
        {
            "id": "\(id)",
            "author": "\(author)",
            "width": \(width),
            "height": \(height),
            "url": "\(url)",
            "download_url": "\(downloadURL)"
        }
        """
        return try! JSONDecoder().decode(PicsumPhoto.self, from: Data(json.utf8))
    }

    func testDecodingFromJSON() {
        let photo = makePhoto()
        XCTAssertEqual(photo.id, "237")
        XCTAssertEqual(photo.author, "Tanner Mardis")
        XCTAssertEqual(photo.width, 3500)
        XCTAssertEqual(photo.height, 2333)
        XCTAssertFalse(photo.url.isEmpty)
        XCTAssertFalse(photo.downloadURL.isEmpty)
    }

    func testDownloadURLCodingKey() {
        // download_url in JSON must map to downloadURL in Swift
        let json = """
        {"id":"1","author":"A","width":100,"height":100,
         "url":"https://u.com","download_url":"https://picsum.photos/id/1/100/100"}
        """
        let photo = try! JSONDecoder().decode(PicsumPhoto.self, from: Data(json.utf8))
        XCTAssertEqual(photo.downloadURL, "https://picsum.photos/id/1/100/100")
    }

    func testImageURLString() {
        let photo = makePhoto(id: "10")
        XCTAssertEqual(photo.imageURLString(width: 800, height: 600),
                       "https://picsum.photos/id/10/800/600")
    }

    func testImageURLStringDifferentDimensions() {
        let photo = makePhoto(id: "42")
        XCTAssertEqual(photo.imageURLString(width: 200, height: 200),
                       "https://picsum.photos/id/42/200/200")
    }

    func testHashableConformance() {
        let a = makePhoto(id: "1")
        let b = makePhoto(id: "1")
        let c = makePhoto(id: "2")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
}

// MARK: - PicsumPhotosRequest

final class PicsumPhotosRequestTests: XCTestCase {

    func testDefaultLimit() {
        let req = PicsumPhotosRequest(page: 1)
        XCTAssertEqual(req.limit, 30)
        XCTAssertEqual(req.page, 1)
    }

    func testCustomLimit() {
        let req = PicsumPhotosRequest(page: 3, limit: 10)
        XCTAssertEqual(req.page, 3)
        XCTAssertEqual(req.limit, 10)
    }
}

// MARK: - PicsumPhotoRequest

final class PicsumPhotoRequestTests: XCTestCase {

    func testIDStoredCorrectly() {
        let req = PicsumPhotoRequest(id: "237")
        XCTAssertEqual(req.id, "237")
    }
}

// MARK: - PicsumAPIService (URL building via URLProtocol stub)

final class PicsumAPIServiceTests: XCTestCase {

    private var service: PicsumAPIService!

    override func setUp() {
        super.setUp()
        CapturingURLProtocol.lastRequest = nil
        CapturingURLProtocol.stubbedStatusCode = 200
        CapturingURLProtocol.stubbedData = Data()
        service = PicsumAPIService(session: makeStubbedSession())
    }

    // MARK: getPhotos — URL construction

    func testGetPhotosRequestContainsPageQueryParam() async throws {
        CapturingURLProtocol.stubbedData = Data("[]".utf8)
        _ = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 2, limit: 10))
        let url = try XCTUnwrap(CapturingURLProtocol.lastRequest?.url)
        XCTAssertTrue(url.absoluteString.contains("page=2"), "Expected page=2 in \(url)")
        XCTAssertTrue(url.absoluteString.contains("limit=10"), "Expected limit=10 in \(url)")
    }

    func testGetPhotosRequestURLContainsListPath() async throws {
        CapturingURLProtocol.stubbedData = Data("[]".utf8)
        _ = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
        let url = try XCTUnwrap(CapturingURLProtocol.lastRequest?.url)
        XCTAssertTrue(url.absoluteString.contains("/v2/list"), "Expected /v2/list in \(url)")
    }

    func testGetPhotosRequestHostIsPicsumPhotos() async throws {
        CapturingURLProtocol.stubbedData = Data("[]".utf8)
        _ = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
        let url = try XCTUnwrap(CapturingURLProtocol.lastRequest?.url)
        XCTAssertEqual(url.host, "picsum.photos")
    }

    // MARK: getPhotos — response decoding

    func testGetPhotosReturnsDecodedPhotos() async throws {
        CapturingURLProtocol.stubbedData = Data("""
        [
            {"id":"1","author":"Alice","width":800,"height":600,
             "url":"https://u.com/1","download_url":"https://picsum.photos/id/1/800/600"},
            {"id":"2","author":"Bob","width":1000,"height":750,
             "url":"https://u.com/2","download_url":"https://picsum.photos/id/2/1000/750"}
        ]
        """.utf8)

        let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
        XCTAssertEqual(photos.count, 2)
        XCTAssertEqual(photos[0].id, "1")
        XCTAssertEqual(photos[0].author, "Alice")
        XCTAssertEqual(photos[1].id, "2")
    }

    func testGetPhotosEmptyArrayReturnsEmptyArray() async throws {
        CapturingURLProtocol.stubbedData = Data("[]".utf8)
        let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 999))
        XCTAssertTrue(photos.isEmpty)
    }

    func testGetPhotosThrowsNetworkErrorOnNon200() async {
        CapturingURLProtocol.stubbedStatusCode = 500
        CapturingURLProtocol.stubbedData = Data()
        do {
            _ = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
            XCTFail("Expected throw")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .networkError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetPhotosThrowsParsingErrorOnMalformedJSON() async {
        CapturingURLProtocol.stubbedData = Data("not_json".utf8)
        do {
            _ = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
            XCTFail("Expected throw")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .parsingError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: getPhoto — URL construction

    func testGetPhotoRequestURLContainsPhotoID() async throws {
        CapturingURLProtocol.stubbedData = Data("""
        {"id":"237","author":"Tanner Mardis","width":3500,"height":2333,
         "url":"https://u.com","download_url":"https://picsum.photos/id/237/3500/2333"}
        """.utf8)
        _ = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: "237"))
        let url = try XCTUnwrap(CapturingURLProtocol.lastRequest?.url)
        XCTAssertTrue(url.absoluteString.contains("/id/237/info"), "Expected /id/237/info in \(url)")
    }

    func testGetPhotoReturnsCorrectPhoto() async throws {
        CapturingURLProtocol.stubbedData = Data("""
        {"id":"237","author":"Tanner Mardis","width":3500,"height":2333,
         "url":"https://u.com","download_url":"https://picsum.photos/id/237/3500/2333"}
        """.utf8)
        let photo = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: "237"))
        XCTAssertEqual(photo.id, "237")
        XCTAssertEqual(photo.author, "Tanner Mardis")
        XCTAssertEqual(photo.width, 3500)
    }

    func testGetPhotoThrowsNetworkErrorOn404() async {
        CapturingURLProtocol.stubbedStatusCode = 404
        CapturingURLProtocol.stubbedData = Data()
        do {
            _ = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: "bad_id"))
            XCTFail("Expected throw")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .networkError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetPhotoThrowsParsingErrorOnMalformedJSON() async {
        CapturingURLProtocol.stubbedData = Data("{bad".utf8)
        do {
            _ = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: "1"))
            XCTFail("Expected throw")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .parsingError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: downloadImageData

    func testDownloadImageDataReturnsData() async throws {
        let fakeImageData = Data([0xFF, 0xD8, 0xFF, 0xE0]) // JPEG magic bytes
        CapturingURLProtocol.stubbedData = fakeImageData
        let url = URL(string: "https://picsum.photos/id/237/400/300")!
        let data = try await service.downloadImageData(from: url)
        XCTAssertEqual(data, fakeImageData)
    }

    func testDownloadImageDataThrowsNetworkErrorOn403() async {
        CapturingURLProtocol.stubbedStatusCode = 403
        CapturingURLProtocol.stubbedData = Data()
        let url = URL(string: "https://picsum.photos/id/237/400/300")!
        do {
            _ = try await service.downloadImageData(from: url)
            XCTFail("Expected throw")
        } catch let error as PicsumAPIError {
            XCTAssertEqual(error, .networkError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testDownloadImageDataUsesCachePolicy() async throws {
        CapturingURLProtocol.stubbedData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG magic bytes
        let url = URL(string: "https://picsum.photos/id/1/200/200")!
        _ = try await service.downloadImageData(from: url)
        let cachePolicy = try XCTUnwrap(CapturingURLProtocol.lastRequest?.cachePolicy)
        XCTAssertEqual(cachePolicy, .returnCacheDataElseLoad)
    }
}

// MARK: - PicsumPhotosProtocol (mixin conformance via protocol extension)

final class PicsumPhotosProtocolTests: XCTestCase {

    private class MockConformer: PicsumPhotosProtocol {
        var urlSession: URLSession
        init(session: URLSession) { self.urlSession = session }
    }

    private var conformer: MockConformer!

    override func setUp() {
        super.setUp()
        CapturingURLProtocol.lastRequest = nil
        CapturingURLProtocol.stubbedStatusCode = 200
        CapturingURLProtocol.stubbedData = Data()
        conformer = MockConformer(session: makeStubbedSession())
    }

    func testGetPhotosRoutesThroughURLSession() async throws {
        CapturingURLProtocol.stubbedData = Data("[]".utf8)
        _ = try await conformer.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
        XCTAssertNotNil(CapturingURLProtocol.lastRequest)
    }

    func testGetPhotoRoutesThroughURLSession() async throws {
        CapturingURLProtocol.stubbedData = Data("""
        {"id":"1","author":"A","width":100,"height":100,
         "url":"https://u.com","download_url":"https://picsum.photos/id/1/100/100"}
        """.utf8)
        _ = try await conformer.getPhoto(photoRequest: PicsumPhotoRequest(id: "1"))
        XCTAssertNotNil(CapturingURLProtocol.lastRequest)
    }

    func testDownloadImageDataRoutesThroughURLSession() async throws {
        CapturingURLProtocol.stubbedData = Data([0x00, 0x01])
        let url = URL(string: "https://picsum.photos/id/1/100/100")!
        _ = try await conformer.downloadImageData(from: url)
        XCTAssertNotNil(CapturingURLProtocol.lastRequest)
    }

    func testDefaultURLSessionIsShared() {
        // A conformer with no urlSession override should use .shared
        class Bare: PicsumPhotosProtocol {}
        let bare = Bare()
        XCTAssertEqual(bare.urlSession, URLSession.shared)
    }
}

// MARK: - PicsumService

final class PicsumServiceTests: XCTestCase {

    func testPicsumServiceConformsToPicsumPhotosProtocol() {
        let service = PicsumService()
        XCTAssertNotNil(service as PicsumPhotosProtocol)
    }

    func testPicsumServiceIsInstantiableWithNoArguments() {
        XCTAssertNotNil(PicsumService())
    }

    func testPicsumServiceGetPhotosReturnsPhotosViaInjectedSession() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CapturingURLProtocol.self]
        CapturingURLProtocol.stubbedStatusCode = 200
        CapturingURLProtocol.stubbedData = Data("""
        [{"id":"5","author":"Eve","width":500,"height":400,
          "url":"https://u.com","download_url":"https://picsum.photos/id/5/500/400"}]
        """.utf8)
        let service = PicsumService(urlSession: URLSession(configuration: config))
        let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
        XCTAssertEqual(photos.count, 1)
        XCTAssertEqual(photos.first?.id, "5")
    }
}

// MARK: - PicsumAPIError

final class PicsumAPIErrorTests: XCTestCase {

    func testParsingErrorIsEquatable() {
        XCTAssertEqual(PicsumAPIError.parsingError, PicsumAPIError.parsingError)
    }

    func testNetworkErrorIsEquatable() {
        XCTAssertEqual(PicsumAPIError.networkError, PicsumAPIError.networkError)
    }

    func testErrorsAreNotEqual() {
        XCTAssertNotEqual(PicsumAPIError.parsingError, PicsumAPIError.networkError)
    }

    func testParsingErrorConformsToError() {
        let error: Error = PicsumAPIError.parsingError
        XCTAssertNotNil(error)
    }
}
