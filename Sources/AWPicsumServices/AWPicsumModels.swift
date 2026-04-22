import Foundation

/// A single photo from the Lorem Picsum library.
public struct AWPicsumPhoto: Decodable, Hashable, Sendable {
    /// The unique identifier for this photo.
    public let id: String
    /// The photographer's name.
    public let author: String
    /// The native width of the photo in pixels.
    public let width: Int
    /// The native height of the photo in pixels.
    public let height: Int
    /// A URL to the Picsum detail page for this photo.
    public let url: String
    /// The direct download URL for the full-resolution photo.
    public let downloadURL: String

    private enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }

    /// Returns a URL string for a resized version of this photo.
    ///
    /// - Parameters:
    ///   - width: Desired width in pixels.
    ///   - height: Desired height in pixels.
    public func imageURLString(width: Int, height: Int) -> String {
        String(format: PicsumEndpoints.imageURLTemplate, id, width, height)
    }
}

/// Parameters for fetching a paginated list of photos.
public struct AWPicsumPhotosRequest: Sendable {
    /// The page number to fetch (1-based).
    public let page: Int
    /// The number of photos per page. Picsum's maximum is 100.
    public let limit: Int

    public init(page: Int, limit: Int = 30) {
        self.page = page
        self.limit = limit
    }
}

/// Parameters for fetching info about a single photo by its ID.
public struct AWPicsumPhotoRequest: Sendable {
    /// The Picsum photo ID (e.g. `"0"`, `"237"`).
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
