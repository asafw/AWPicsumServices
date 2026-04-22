import Foundation
import Combine
import AWPicsumServices

/// Drives the demo UI. Conforms to `PicsumPhotosProtocol` so it exercises the
/// full public API surface of AWPicsumServices via the mixin pattern.
final class DemoViewModel: ObservableObject, PicsumPhotosProtocol {

    // PicsumPhotosProtocol — URLSession.shared is sufficient for the demo.
    var urlSession: URLSession { .shared }

    // MARK: - Pagination state

    @Published var photos: [PicsumPhoto] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var currentPage: Int = 1
    private let pageSize: Int = 30

    // MARK: - Detail state

    @Published var selectedPhoto: PicsumPhoto? = nil
    @Published var detailImageData: Data? = nil
    @Published var isLoadingDetail: Bool = false
    @Published var detailError: String? = nil

    // MARK: - Actions

    func loadFirstPage() {
        guard !isLoading else { return }
        currentPage = 1
        photos = []
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let newPhotos = try await getPhotos(
                    photosRequest: PicsumPhotosRequest(page: currentPage, limit: pageSize)
                )
                photos.append(contentsOf: newPhotos)
                if !newPhotos.isEmpty { currentPage += 1 }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func selectPhoto(_ photo: PicsumPhoto) {
        selectedPhoto = photo
        detailImageData = nil
        detailError = nil
        isLoadingDetail = true

        Task { @MainActor in
            do {
                let urlString = photo.imageURLString(width: 800, height: 600)
                guard let url = URL(string: urlString) else { throw PicsumAPIError.parsingError }
                detailImageData = try await downloadImageData(from: url)
            } catch {
                detailError = error.localizedDescription
            }
            isLoadingDetail = false
        }
    }

    func loadThumbnailData(for photo: PicsumPhoto) async -> Data? {
        guard let url = URL(string: photo.imageURLString(width: 200, height: 150)) else {
            return nil
        }
        return try? await downloadImageData(from: url)
    }
}
