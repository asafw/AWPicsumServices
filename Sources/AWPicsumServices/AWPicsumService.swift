import Foundation

/// A concrete service type that conforms to `AWPicsumPhotosProtocol`.
///
/// Use `AWPicsumService` when you want a ready-made object without defining your
/// own conforming type:
///
/// ```swift
/// // Default session (URLSession.shared)
/// let service = AWPicsumService()
///
/// // Custom session — e.g. inject a URLProtocol stub for tests
/// let service = AWPicsumService(urlSession: stubbedSession)
///
/// // Fetch the first page of photos
/// let photos = try await service.getPhotos(photosRequest: AWPicsumPhotosRequest(page: 1))
///
/// // Fetch a single photo's info
/// let photo = try await service.getPhoto(photoRequest: AWPicsumPhotoRequest(id: "237"))
///
/// // Download image bytes
/// if let url = URL(string: photo.imageURLString(width: 400, height: 300)) {
///     let data = try await service.downloadImageData(from: url)
/// }
/// ```
///
/// All network behaviour is provided by the `AWPicsumPhotosProtocol` extension
/// default implementations via the stored `urlSession`.
public final class AWPicsumService: AWPicsumPhotosProtocol {

    /// The `URLSession` used by all default protocol method implementations.
    ///
    /// Defaults to `URLSession.shared`. Pass a custom session at init to
    /// intercept requests (e.g. with a `URLProtocol` stub) or to apply custom
    /// configuration such as timeouts or caching policies.
    public let urlSession: URLSession

    /// Creates a `AWPicsumService` with the given session.
    ///
    /// - Parameter urlSession: The session to use for all network requests.
    ///   Defaults to `URLSession.shared`.
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}
