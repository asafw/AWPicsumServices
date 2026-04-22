import Foundation

/// A concrete service type that conforms to `PicsumPhotosProtocol`.
///
/// Use `PicsumService` when you want a ready-made object without defining your
/// own conforming type:
///
/// ```swift
/// // Default session (URLSession.shared)
/// let service = PicsumService()
///
/// // Custom session — e.g. inject a URLProtocol stub for tests
/// let service = PicsumService(urlSession: stubbedSession)
///
/// // Fetch the first page of photos
/// let photos = try await service.getPhotos(photosRequest: PicsumPhotosRequest(page: 1))
///
/// // Fetch a single photo's info
/// let photo = try await service.getPhoto(photoRequest: PicsumPhotoRequest(id: "237"))
///
/// // Download image bytes
/// if let url = URL(string: photo.imageURLString(width: 400, height: 300)) {
///     let data = try await service.downloadImageData(from: url)
/// }
/// ```
///
/// All network behaviour is provided by the `PicsumPhotosProtocol` extension
/// default implementations via the stored `urlSession`.
public final class PicsumService: PicsumPhotosProtocol {

    /// The `URLSession` used by all default protocol method implementations.
    ///
    /// Defaults to `URLSession.shared`. Pass a custom session at init to
    /// intercept requests (e.g. with a `URLProtocol` stub) or to apply custom
    /// configuration such as timeouts or caching policies.
    public let urlSession: URLSession

    /// Creates a `PicsumService` with the given session.
    ///
    /// - Parameter urlSession: The session to use for all network requests.
    ///   Defaults to `URLSession.shared`.
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}
