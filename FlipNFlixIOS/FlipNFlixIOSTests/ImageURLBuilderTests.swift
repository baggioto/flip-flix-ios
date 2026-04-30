@testable import FlipNFlixIOS
import Foundation
import XCTest

final class ImageURLBuilderTests: XCTestCase {
    func testURLBuildsExpectedTMDBImageURL() {
        let builder = ImageURLBuilder()

        let url = builder.url(for: "/poster.jpg", size: .poster)

        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w500/poster.jpg")
    }

    func testURLAcceptsPathWithoutLeadingSlash() {
        let builder = ImageURLBuilder()

        let url = builder.url(for: "backdrop.jpg", size: .backdrop)

        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w780/backdrop.jpg")
    }

    func testURLWhenPathIsEmptyReturnsNil() {
        let builder = ImageURLBuilder()

        XCTAssertNil(builder.url(for: "", size: .poster))
        XCTAssertNil(builder.url(for: nil, size: .poster))
    }
}
