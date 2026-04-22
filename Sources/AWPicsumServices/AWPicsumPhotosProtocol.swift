import Foundation

/// A protocol that provides access to the Lorem Picsum photo API.
///
/// Conform your own type to `AWPicsumPhotosProtocol` to get full API access via
/// protocol extension default implementations — no subclassing or object
/// injection required.
///
/// ```swift
/// // Use the ready-made concrete type:
/// let service = AWPicsumService()
/// let photos = try await service.getPhotos(photosRequest: AWPicsumPhotosRequest(page: 1))
///
/// // Or conform your own type — e.g. a view model:
/// class MyViewModel: AWPicsumPhotosProtocol { }
/// let vm = MyViewModel()
/// let photo = try await vm.getPhoto(photoRequest: AWPicsumPhotoRequest(id: "237"))
/// ```
///
/// Override `urlSession` to inject a custom `URLSession` — for example, an
/// ephemeral session backed by a `URLProtocol` stub for unit tests.
public protocol AWPicsumPhotosProtocol {

    /// The `URLSession` used by the default method implementations.
    ///
    /// Override to inject a custom session. The default returns `URLSession.shared`.
    var urlSession: URLSession { get }

    /// Fetches a paginated list of photos from Lorem Picsum.
    ///
    /// - Parameter photosRequest: Page number and page size.
    /// - Returns: An array of `AWPicsumPhoto` values.
    /// - Throws: `AWPicsumAPIError.networkError` on a non-2xx response,
    ///   `AWPicsumAPIError.parsingError` on a decode failure.
    func getPhotos(photosRequest: AWPicsumPhotosRequest) async throws -> [AWPicsumPhoto]

    /// Fetches metadata for a single photo by its Picsum ID.
    ///
    /// - Parameter photoRequest: The request containing the photo ID.
    /// - Returns: A `AWPicsumPhoto` with full metadata.
    /// - Throws: `AWPicsumAPIError.networkError` or `AWPicsumAPIError.parsingError`.
    func getPhoto(photoRequest: AWPicsumPhotoRequest) async throws -> AWPicsumPhoto

    /// Downloads raw image bytes from the given URL.
    ///
    /// Requests are made with `.returnCacheDataElseLoad` cache policy so that
    /// repeated downloads of the same URL avoid redundant network round-trips.
    ///
    /// - Parameter url: The image URL to download. Use `AWPicsumPhoto.imageURLString(width:height:)`
    ///   or `AWPicsumPhoto.downloadURL` to obtain a valid URL.
    /// - Returns: The raw image `Data`.
    /// - Throws: `AWPicsumAPIError.networkError` on a non-2xx response.
    func downloadImageData(from url: URL) async throws -> Data
}

public extension AWPicsumPhotosProtocol {

    var urlSession: URLSession { .shared }

    private var service: PicsumAPIService { PicsumAPIService(session: urlSession) }

    func getPhotos(photosRequest: AWPicsumPhotosRequest) async throws -> [AWPicsumPhoto] {
        try await service.getPhotos(photosRequest: photosRequest)
    }

    func getPhoto(photoRequest: AWPicsumPhotoRequest) async throws -> AWPicsumPhoto {
        try await service.getPhoto(photoRequest: photoRequest)
    }

    func downloadImageData(from url: URL) async throws -> Data {
        try await service.downloadImageData(from: url)
    }
}
