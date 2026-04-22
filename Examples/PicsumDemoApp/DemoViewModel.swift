import Foundation
import Observation
import AWPicsumServices

/// Drives the demo UI. Conforms to `PicsumPhotosProtocol` so it exercises the
/// full public API surface of AWPicsumServices via the mixin pattern.
@Observable
final class DemoViewModel: PicsumPhotosProtocol {

    // PicsumPhotosProtocol — URLSession.shared is sufficient for the demo.
    var urlSession: URLSession { .shared }

    // MARK: - Pagination state

    var photos: [PicsumPhoto] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private var currentPage: Int = 1
    private let pageSize: Int = 30

    // MARK: - Detail state

    var selectedPhoto: PicsumPhoto? = nil
    var detailImageData: Data? = nil
    var isLoadingDetail: Bool = false
    var detailError: String? = nil

    // MARK: - Init

    init() {
        #if DEBUG
        let env = ProcessInfo.processInfo.environment

        // MOCK_DETAIL seam: pre-selects the first loaded photo as a sheet so
        // script-driven macOS screenshots can capture it without mouse clicks.
        // Works together with the photos array being populated on appear.
        if env["MOCK_DETAIL"] != nil {
            // Observe photos array so we can select the first one once loaded.
            DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) { [weak self] in
                guard let self else { return }
                if let first = self.photos.first {
                    self.selectPhoto(first)
                }
            }
        }
        #endif
    }

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
