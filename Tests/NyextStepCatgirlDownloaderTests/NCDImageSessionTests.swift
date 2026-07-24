import Foundation
@testable import NyextStepCatgirlDownloader
import Testing

@MainActor
struct NCDImageSessionTests {
    @Test func reloadCachesOneImageAndHistoryNavigationSwapsDirections() async throws {
        let firstImage = try NCDImage(data: Data([1]), sourceURL: #require(URL(string: "https://example.com/one")), suggestedFilename: "one.jpg")
        let secondImage = try NCDImage(data: Data([2]), sourceURL: #require(URL(string: "https://example.com/two")), suggestedFilename: "two.jpg")
        var images = [firstImage, secondImage]
        let session = NCDImageSession(loadNextImage: { images.removeFirst() })

        await session.reload()
        #expect(session.currentImage == firstImage)
        #expect(session.previousImage == nil)

        await session.reload()
        #expect(session.currentImage == secondImage)
        #expect(session.previousImage == firstImage)

        session.navigateHistory()
        #expect(session.currentImage == firstImage)
        #expect(session.previousImage == secondImage)
        #expect(session.historyDirection == .forward)

        session.navigateHistory()
        #expect(session.currentImage == secondImage)
        #expect(session.previousImage == firstImage)
        #expect(session.historyDirection == .backward)
    }
}
