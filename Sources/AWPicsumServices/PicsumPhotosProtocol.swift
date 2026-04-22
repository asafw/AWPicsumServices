import Foundation

/// A protocol that provides access to the Lorem Picsum photo API.
///
/// Conform your own type to `PicsumPhotosProtocol` to get full API access via
/// protocol extension default implementations — no subclassing or object
/// injection required.
///
/// ```swift
/// // Use the ready-made concrete type:
/// let service = PicsumService()
/// let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
///
/// // Or conform your own type — e.g. a view model:
/// class MyViewModel: PicsumPhotosProtocol { }
/// let vm = MyViewModel()
/// let photo = try await vm.getPhoto(photoRequest: PicsumPhotoRequest(id: "237"))
/// ```
///
/// Override `urlSession` to inject a custom `URLSession` — for example, an
/// ephemeral session backed by a `URLProtocol` stub for unit tests.
public protocol PicsumPhotosProtocol {

    /// The `URLSession` used by the default method implementations.
    ///
    /// Override to inject a custom session. The default returns `URLSession.shared`.
    var urlSession: URLSession { get }

    /// Fetches a paginated list of photos from Lorem Picsum.
    ///
    /// - Parameter photosRequest: Page number and page size.
    /// - Returns: An array of `PicsumPhoto` values.
    /// - Throws: `PicsumAPIError.networkError` on a non-2xx response,
    ///   `PicsumAPIError.parsingError` on a decode failure.
    func getPhotos(photosRequest: PicsumPhotosRequest) async throws -> [PicsumPhoto]

    /// Fetches metadata for a single photo by its Picsum ID.
    ///
    /// - Parameter photoRequest: The request containing the photo ID.
    /// - Returns: A `PicsumPhoto` with full metadata.
    /// - Throws: `PicsumAPIError.networkError` or `PicsumAPIError.parsingError`.
    func getPhoto(photoRequest: PicsumPhotoRequest) async throws -> PicsumPhoto

    /// Downloads raw image bytes from the given URL.
    ///
    /// Requests are made with `.returnCacheDataElseLoad` cache policy so that
    /// repeated downloads of the same URL avoid redundant network round-trips.
    ///
    /// - Parameter url: The image URL to download. Use `PicsumPhoto.imageURLString(width:height:)`
    ///   or `PicsumPhoto.downloadURL` to obtain a valid URL.
    /// - Returns: The raw image `Data`.
    /// - Throws: `PicsumAPIError.networkError` on a non-2xx response.
    func downloadImageData(from url: URL) async throws -> Data
}

public extension PicsumPhotosProtocol {

    var urlSession: URLSession { .shared }

    private var service: PicsumAPIService { PicsumAPIService(session: urlSession) }

    func getPhotos(photosRequest: PicsumPhotosRequest) async throws -> [PicsumPhoto] {
        try await service.getPhotos(photosRequest: photosRequest)
    }

    func getPhoto(photoRequest: PicsumPhotoRequest) async throws -> PicsumPhoto {
        try await service.getPhoto(photoRequest: photoRequest)
    }

    func downloadImageData(from url: URL) async throws -> Data {
        try await service.downloadImageData(from: url)
    }
}
