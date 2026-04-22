# AWPicsumServices — Project Context

> Authoritative state document for AI-assisted development.
> Update this file at the end of every session that makes code changes.

## Latest commit
- **Hash:** (initial)
- **Branch:** main
- **Message:** feat: initial AWPicsumServices v1.0

## Repository layout

```
AWPicsumServices/
├── Sources/AWPicsumServices/
│   ├── PicsumAPIError.swift        ← PicsumAPIError (parsingError, networkError)
│   ├── PicsumAPIService.swift      ← Internal HTTP layer
│   ├── PicsumEndpoints.swift       ← URL constants (internal caseless enum)
│   ├── PicsumModels.swift          ← PicsumPhoto, PicsumPhotosRequest, PicsumPhotoRequest
│   ├── PicsumPhotosProtocol.swift  ← Public protocol + default impl
│   └── PicsumService.swift         ← public final class PicsumService: PicsumPhotosProtocol
├── Tests/AWPicsumServicesTests/
│   └── AWPicsumServicesTests.swift ← 37 unit tests (CapturingURLProtocol, no network)
├── Tests/AWPicsumServicesIntegrationTests/
│   └── AWPicsumServicesIntegrationTests.swift ← 7 live tests, auto-skip when CI=true
├── Examples/PicsumDemoApp/         ← Shared SwiftUI sources (macOS + iOS)
│   ├── PicsumDemoApp.swift
│   ├── ContentView.swift
│   ├── DemoViewModel.swift         ← ObservableObject, PicsumPhotosProtocol conformance
│   ├── PhotoGridView.swift         ← LazyVGrid with infinite scroll
│   ├── PhotoDetailView.swift       ← Author, dimensions, Unsplash link
│   └── PlatformImage.swift         ← UIImage/NSImage cross-platform bridge
├── Examples/PicsumDemoApp-iOS/
│   └── project.yml                 ← XcodeGen spec
├── Package.swift                   ← swift-tools-version:5.9, iOS 16+, macOS 12+
├── README.md
├── AGENTS.md
└── .github/
    ├── CONTEXT.md                  ← This file
    └── instructions/
        └── awpicsumservices.instructions.md
```

## Test counts
- Unit tests: **37** (AWPicsumServicesTests)
- Integration tests: **7** (AWPicsumServicesIntegrationTests — auto-skip in CI)

## Public API surface

### `PicsumPhotosProtocol`
- `getPhotos(photosRequest: PicsumPhotosRequest) async throws -> [PicsumPhoto]`
- `getPhoto(photoRequest: PicsumPhotoRequest) async throws -> PicsumPhoto`
- `downloadImageData(from: URL) async throws -> Data`
- `var urlSession: URLSession` (default: `.shared`)

### `PicsumService`
```swift
public final class PicsumService: PicsumPhotosProtocol {
    public let urlSession: URLSession
    public init(urlSession: URLSession = .shared)
}
```

### `PicsumPhoto`
- `id: String`, `author: String`, `width: Int`, `height: Int`
- `url: String` (Unsplash page), `downloadURL: String`
- `imageURLString(width:height:) -> String`
- Conforms to `Decodable`, `Hashable`, `Sendable`, `Identifiable` (via demo app extension)

### `PicsumPhotosRequest`
- `page: Int`, `limit: Int` (default: 30)

### `PicsumPhotoRequest`
- `id: String`

### `PicsumAPIError`
- `parsingError`, `networkError`
- Conforms to `Error`, `Equatable`

## Architecture invariants
- **Zero external dependencies** — `Foundation` only.
- **Pure `async throws` API** — no completion handlers.
- **`returnCacheDataElseLoad`** cache policy on `downloadImageData`.
- **No API key required** — Lorem Picsum is a free, open API.
- **`download_url` CodingKey** — JSON field maps to Swift `downloadURL` via `CodingKeys`.
- **Integration tests skip in CI** — check `ProcessInfo.processInfo.environment["CI"]`.

## Commit history
| Hash | Message |
|------|---------|
| (initial) | feat: initial AWPicsumServices v1.0 |

## Pending / future work
- macOS screenshots script (`scripts/macos_screenshots.sh`)
- iOS screenshots script (`scripts/ios_screenshots.sh` + UITest target)
- GitHub Actions CI (unit tests on macOS)
- SPM release tag v1.0.0
