/// Errors thrown by AWPicsumServices.
public enum AWPicsumAPIError: Error, Equatable {
    /// A URL could not be constructed from the given parameters, or a response
    /// could not be decoded into the expected model type.
    case parsingError
    /// The server returned a non-2xx HTTP status code, or no HTTP response was
    /// received at all.
    case networkError
}
