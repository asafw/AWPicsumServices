import SwiftUI
import AWPicsumServices

struct PhotoDetailView: View {
    let photo: AWPicsumPhoto
    var viewModel: DemoViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imageArea
                metadataSection
                Spacer()
            }
            .padding()
        }
        .navigationTitle(photo.author)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var imageArea: some View {
        if viewModel.isLoadingDetail {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, minHeight: 200)
        } else if let data = viewModel.detailImageData, let img = PlatformImage.from(data: data) {
            Image(platformImage: img)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 4)
        } else if let err = viewModel.detailError {
            Label(err, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            metaRow(label: "Photographer", value: photo.author)
            metaRow(label: "Dimensions", value: "\(photo.width) × \(photo.height) px")
            metaRow(label: "Photo ID", value: photo.id)

            if let url = URL(string: photo.url) {
                Link(destination: url) {
                    Label("View on Unsplash", systemImage: "arrow.up.right.square")
                        .font(.footnote)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private func metaRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.callout)
        }
    }
}
