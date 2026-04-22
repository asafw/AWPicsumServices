import SwiftUI
import AWPicsumServices

struct ContentView: View {

    @State private var viewModel = DemoViewModel()

    var body: some View {
        Group {
            NavigationStack { navigationContent }
        }
        .onAppear { viewModel.loadFirstPage() }
        .sheet(item: $viewModel.selectedPhoto) { photo in
            #if os(iOS)
            NavigationView {
                PhotoDetailView(photo: photo, viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { viewModel.selectedPhoto = nil }
                        }
                    }
            }
            #else
            PhotoDetailView(photo: photo, viewModel: viewModel)
                .frame(minWidth: 500, minHeight: 400)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { viewModel.selectedPhoto = nil }
                    }
                }
            #endif
        }
    }

    private var navigationContent: some View {
        VStack(spacing: 0) {
            if let error = viewModel.errorMessage {
                errorBanner(message: error)
            }
            PhotoGridView(viewModel: viewModel)
        }
        .navigationTitle("Lorem Picsum")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.loadFirstPage()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
    }

    private func errorBanner(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.footnote)
            Spacer()
            Button("Retry") { viewModel.loadFirstPage() }
                .font(.footnote)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemRed).opacity(0.1))
    }
}

extension PicsumPhoto: Identifiable {}
