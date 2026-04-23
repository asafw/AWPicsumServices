# AWPicsumServices — Project Context

> Authoritative state document for AI-assisted development.
> Update this file at the end of every session that makes code changes.

## Latest commit
- **Hash:** (pending)
- **Branch:** main
- **Message:** fix(ci): remove --filter from swift test; integration tests auto-skip via CI env

## Repository layout

```
AWPicsumServices/
├── Sources/AWPicsumServices/
│   ├── AWPicsumAPIError.swift      ← AWPicsumAPIError (parsingError, networkError)
│   ├── PicsumAPIService.swift      ← Internal HTTP layer
│   ├── PicsumEndpoints.swift       ← URL constants (internal caseless enum)
│   ├── AWPicsumModels.swift        ← AWPicsumPhoto, AWPicsumPhotosRequest, AWPicsumPhotoRequest
│   ├── AWPicsumPhotosProtocol.swift ← Public protocol + default impl
│   └── AWPicsumService.swift       ← public final class AWPicsumService: AWPicsumPhotosProtocol
├── Tests/AWPicsumServicesTests/
│   └── AWPicsumServicesTests.swift ← 46 unit tests (CapturingURLProtocol, no network)
├── Tests/AWPicsumServicesIntegrationTests/
│   └── AWPicsumServicesIntegrationTests.swift ← 7 live tests, auto-skip when CI=true
├── Examples/PicsumDemoApp/         ← Shared SwiftUI sources (macOS + iOS)
│   ├── PicsumDemoApp.swift
│   ├── ContentView.swift
│   ├── DemoViewModel.swift         ← @Observable, AWPicsumPhotosProtocol conformance
│   ├── PhotoGridView.swift         ← LazyVGrid with infinite scroll
│   ├── PhotoDetailView.swift       ← Author, dimensions, Unsplash link
│   └── PlatformImage.swift         ← UIImage/NSImage cross-platform bridge
├── Examples/PicsumDemoApp-iOS/
│   ├── project.yml                 ← XcodeGen spec (iOS 17+)
│   └── Screenshots/PicsumDemoScreenshots.swift ← UITest screenshot tests
├── scripts/
│   ├── macos_screenshots.sh        ← capture_macos_window.py, 2 screenshots
│   ├── ios_screenshots.sh          ← run UITests, extract PNGs from .xcresult
│   ├── capture_macos_window.py     ← screencapture -l <windowID>
│   └── extract_ios_screenshots.py  ← extract PNGs from .xcresult bundles
├── screenshots/
│   ├── macos/                      ← macOS screenshots
│   └── ios/                        ← iOS screenshots
├── Package.swift                   ← swift-tools-version:5.9, iOS 17+, macOS 14+
├── .gitignore                      ← .build/, *.xcodeproj/, DerivedData/ etc.
├── README.md
├── AGENTS.md
└── .github/
    ├── CONTEXT.md                  ← This file
    ├── workflows/
    │   ├── ios.yml                 ← iOS CI (macos-15, xcodebuild, AWPicsumServicesTests only)
    │   ├── macos.yml               ← macOS CI (macos-15, xcodebuild, AWPicsumServicesTests only)
    │   └── swift.yml               ← Swift Package CI (macos-15, swift test, integration auto-skips via CI env)
    └── instructions/
        └── awpicsumservices.instructions.md
```

## Test counts
- Unit tests: **46** (AWPicsumServicesTests)
- Integration tests: **7** (AWPicsumServicesIntegrationTests — auto-skip in CI)

## Public API surface

### `AWPicsumPhotosProtocol`
- `getPhotos(photosRequest: AWPicsumPhotosRequest) async throws -> [AWPicsumPhoto]`
- `getPhoto(photoRequest: AWPicsumPhotoRequest) async throws -> AWPicsumPhoto`
- `downloadImageData(from: URL) async throws -> Data`
- `var urlSession: URLSession` (default: `.shared`)

### `AWPicsumService`
```swift
public final class AWPicsumService: AWPicsumPhotosProtocol {
    public let urlSession: URLSession
    public init(urlSession: URLSession = .shared)
}
```

### `AWPicsumPhoto`
- `id: String`, `author: String`, `width: Int`, `height: Int`
- `url: String` (Unsplash page), `downloadURL: String`
- `imageURLString(width:height:) -> String`
- Conforms to `Decodable`, `Hashable`, `Identifiable`, `Sendable`

### `AWPicsumPhotosRequest`
- `page: Int`, `limit: Int` (default: 30)

### `AWPicsumPhotoRequest`
- `id: String`

### `AWPicsumAPIError`
- `parsingError`, `networkError`
- Conforms to `Error`, `Equatable`

## Architecture invariants
- **Zero external dependencies** — `Foundation` only.
- **Pure `async throws` API** — no completion handlers.
- **`returnCacheDataElseLoad`** cache policy on `downloadImageData`.
- **No API key required** — Lorem Picsum is a free, open API.
- **`download_url` CodingKey** — JSON field maps to Swift `downloadURL` via `CodingKeys`.
- **Integration tests skip in CI** — check `ProcessInfo.processInfo.environment["CI"]`.
- **`AWPicsumPhoto` is `Identifiable`** — conforms in the library (not the demo app).
- **Demo app uses `@Observable`** — `DemoViewModel` uses Observation framework (iOS 17+/macOS 14+), no Combine.
- **iOS 17+ / macOS 14+** — platforms bumped for `@Observable` and `NavigationStack`/`clipShape` APIs.

## Commit history
| Hash | Message |
|------|---------|
| (pending) | fix(ci): remove --filter from swift test; integration tests auto-skip via CI env |
| 2b24962 | ci: add Swift Package CI workflow and badge |
| 02d4c2c | docs(readme): add iOS and macOS CI badges |
| 920530d | ci: add iOS and macOS GitHub Actions workflows |
| b0eba30 | docs(readme): update all type names to AW prefix, fix platform versions, update mixin example |
| 78b19c5 | audit: fix deprecated APIs, add Identifiable to library, update docs |
| e0be8dd | chore: add .gitignore, remove .build from tracking |
| 7857a26 | refactor: add AW prefix to all public types |

## Pending / future work
- SPM release tag v1.0.0
