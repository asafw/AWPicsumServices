/// Namespace for all Lorem Picsum API URL strings.
enum PicsumEndpoints {
    static let baseURL = "https://picsum.photos"
    static let listPath = "/v2/list"
    static let infoPath = "/id/%@/info"            // %@ = photo id
    static let imageURLTemplate = "https://picsum.photos/id/%@/%d/%d"  // id, width, height
}
