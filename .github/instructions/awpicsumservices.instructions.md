---
applyTo: "**"
---

# AWPicsumServices — Copilot Instructions

> Maintained automatically. Update via `.github/CONTEXT.md` + `AGENTS.md`
> and re-sync this file at the end of each session.

## Project overview

A dependency-free Swift Package for integrating the Lorem Picsum photo API in iOS and macOS apps.
Uses a **protocol mixin pattern**: consumers conform to `AWPicsumPhotosProtocol` and gain full API
access through protocol extension default implementations. No subclassing or object injection required.

No API key required — Lorem Picsum is a free, open API.

- **Repo:** `asafw/AWPicsumServices` (public) — `~/Desktop/asafw/AWPicsumServices/`
- **Active branch:** `main`
- **Authoritative state:** `.github/CONTEXT.md` — always read before making changes.

---

## Repository layout

```
AWPicsumServices/
├── Sources/AWPicsumServices/
│   ├── AWPicsumAPIError.swift      ← Public error enum (parsingError, networkError)
│   ├── PicsumAPIService.swift      ← Internal HTTP layer
│   ├── PicsumEndpoints.swift       ← Internal caseless enum of URL constants
│   ├── AWPicsumModels.swift        ← Public request & response models (Sendable)
│   ├── AWPicsumPhotosProtocol.swift ← Public protocol + default impl
│   └── AWPicsumService.swift       ← public final class AWPicsumService: AWPicsumPhotosProtocol
├── Tests/AWPicsumServicesTests/
│   └── AWPicsumServicesTests.swift ← 46 unit tests (CapturingURLProtocol stub)
├── Tests/AWPicsumServicesIntegrationTests/
│   └── AWPicsumServicesIntegrationTests.swift ← 7 live tests; skip when CI=true
├── Examples/PicsumDemoApp/         ← Shared SwiftUI sources (macOS + iOS)
├── Examples/PicsumDemoApp-iOS/     ← XcodeGen project (iOS 17+)
│   └── Screenshots/PicsumDemoScreenshots.swift ← UITest screenshot tests
├── scripts/
│   ├── macos_screenshots.sh
│   ├── ios_screenshots.sh
│   ├── capture_macos_window.py
│   └── extract_ios_screenshots.py
├── Package.swift                   ← swift-tools-version:5.9, iOS 17+, macOS 14+
├── .gitignore
├── README.md
└── AGENTS.md
```

---

## Types and APIs

### `AWPicsumPhotosProtocol`

| Method | Description |
|---|---|
| `getPhotos(photosRequest:)` | Paginated list of photos (`[AWPicsumPhoto]`) |
| `getPhoto(photoRequest:)` | Single photo metadata by ID |
| `downloadImageData(from:)` | Raw image `Data`, `.returnCacheDataElseLoad` cache policy |
| `var urlSession: URLSession` | Default: `.shared`. Override to inject a custom session. |

### `AWPicsumService`

```swift
public final class AWPicsumService: AWPicsumPhotosProtocol {
    public let urlSession: URLSession
    public init(urlSession: URLSession = .shared)
}
```

### Public models

| Type | Key fields |
|---|---|
| `AWPicsumPhoto` | `id, author, width, height, url, downloadURL`; `imageURLString(width:height:)`; conforms to `Decodable`, `Hashable`, `Identifiable`, `Sendable` |
| `AWPicsumPhotosRequest` | `page: Int`, `limit: Int` (default 30) |
| `AWPicsumPhotoRequest` | `id: String` |
| `AWPicsumAPIError` | `.parsingError`, `.networkError` |

### Internal types (do not expose publicly)

- `PicsumAPIService` — concrete HTTP implementation; `init(session:)` injects the session
- `PicsumEndpoints` — all URL templates and path strings

---

## Architecture invariants

- **Zero external dependencies** — `Foundation` only. `Package.swift` must stay dependency-free.
- **No UIKit dependency** — iOS 17+ and macOS 14+. `downloadImageData` returns `Data`; callers convert.
- **Pure `async throws` API** — all public protocol methods and `PicsumAPIService` methods are `async throws`.
- **`download_url` CodingKey** — JSON field `download_url` maps to `downloadURL` via `CodingKeys`.
- **`.returnCacheDataElseLoad`** cache policy on `downloadImageData` avoids redundant network fetches.
- **No API key** — Lorem Picsum is open. Never add authentication to the request layer.
- **Integration tests skip in CI** — check `ProcessInfo.processInfo.environment["CI"] != nil`.
- **`AWPicsumPhoto` is `Identifiable`** — conforms in the library itself (`id: String`). Do not re-add this conformance in the demo app.
- **Demo app uses `@Observable`** — `DemoViewModel` uses the Observation framework (iOS 17+/macOS 14+). No Combine, no `ObservableObject`.
- **`NavigationStack`** — used everywhere in the demo app. `NavigationView` must never be used (deprecated).
- **`.clipShape(.rect(cornerRadius:))`** — use this instead of the deprecated `.cornerRadius()` modifier.

---

## Coding conventions

- **One file per type** — each public type has its own file.
- **No imports beyond Foundation** — the source files must stay import-free of anything else.
- **Doc comments** — every `public` type and method must have a `///` doc comment.
- **Tests** — every new public method must have corresponding unit tests using `CapturingURLProtocol`
  and a corresponding integration test in `AWPicsumServicesIntegrationTests`.

---

## Build and test

```bash
cd ~/Desktop/asafw/AWPicsumServices
swift build
swift test                                            # 46 unit tests, no network
swift test --filter AWPicsumServicesIntegrationTests  # live tests (no CI)
```

---

## Session end checklist

1. Run `swift test` — all 46 unit tests must pass.
2. Update `.github/CONTEXT.md`: latest commit hash, test counts, any new types/APIs.
3. Update this file if architecture, conventions, or type descriptions changed.
4. Commit both together:
   ```bash
   git add .github/CONTEXT.md .github/instructions/awpicsumservices.instructions.md
   git commit -m "docs(context): update session state"
   git push origin main
   ```
