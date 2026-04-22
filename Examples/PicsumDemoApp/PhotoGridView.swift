import SwiftUI
import AWPicsumServices

/// An async-loaded thumbnail for a single `PicsumPhoto`.
struct PhotoThumbnailView: View {
    let photo: PicsumPhoto
    let viewModel: DemoViewModel

    @State private var imageData: Data? = nil

    var body: some View {
        ZStack {
            Color(.gray).opacity(0.15)

            if let data = imageData, let img = PlatformImage.from(data: data) {
                Image(platformImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                ProgressView()
                    .tint(.secondary)
            }
        }
        .task {
            imageData = await viewModel.loadThumbnailData(for: photo)
        }
    }
}

/// A grid of all loaded Picsum photos, with infinite-scroll pagination.
struct PhotoGridView: View {
    var viewModel: DemoViewModel

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160), spacing: 4)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.photos, id: \.id) { photo in
                    Button {
                        viewModel.selectPhoto(photo)
                    } label: {
                        PhotoThumbnailView(photo: photo, viewModel: viewModel)
                            .aspectRatio(4 / 3, contentMode: .fit)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Photo by \(photo.author)")
                    .onAppear {
                        // Trigger next page when the last photo appears
                        if photo.id == viewModel.photos.last?.id {
                            viewModel.loadNextPage()
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .gridCellColumns(columns.count)
                }
            }
            .padding(4)
        }
    }
}
