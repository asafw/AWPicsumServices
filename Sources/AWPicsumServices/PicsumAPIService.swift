import Foundation

struct PicsumAPIService {

    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public methods

    func getPhotos(photosRequest: AWPicsumPhotosRequest) async throws -> [AWPicsumPhoto] {
        let queryParams: [String: String] = [
            "page": String(photosRequest.page),
            "limit": String(photosRequest.limit),
        ]
        guard let url = generateURL(path: PicsumEndpoints.listPath, queryParams: queryParams) else {
            throw AWPicsumAPIError.parsingError
        }
        let (data, response) = try await session.data(for: URLRequest(url: url))
        guard validateHTTPResponse(response) else { throw AWPicsumAPIError.networkError }
        do {
            return try JSONDecoder().decode([AWPicsumPhoto].self, from: data)
        } catch {
            throw AWPicsumAPIError.parsingError
        }
    }

    func getPhoto(photoRequest: AWPicsumPhotoRequest) async throws -> AWPicsumPhoto {
        let path = String(format: PicsumEndpoints.infoPath, photoRequest.id)
        guard let url = generateURL(path: path) else {
            throw AWPicsumAPIError.parsingError
        }
        let (data, response) = try await session.data(for: URLRequest(url: url))
        guard validateHTTPResponse(response) else { throw AWPicsumAPIError.networkError }
        do {
            return try JSONDecoder().decode(AWPicsumPhoto.self, from: data)
        } catch {
            throw AWPicsumAPIError.parsingError
        }
    }

    func downloadImageData(from url: URL) async throws -> Data {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let (data, response) = try await session.data(for: request)
        guard validateHTTPResponse(response) else { throw AWPicsumAPIError.networkError }
        return data
    }

    // MARK: - Private helpers

    private func generateURL(path: String, queryParams: [String: String]? = nil) -> URL? {
        guard var components = URLComponents(string: PicsumEndpoints.baseURL) else { return nil }
        components.path = path
        if let queryParams {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url
    }

    private func validateHTTPResponse(_ response: URLResponse?) -> Bool {
        guard let http = response as? HTTPURLResponse else { return false }
        return (200..<300).contains(http.statusCode)
    }
}
