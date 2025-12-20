//
//  testProgressVisibleWhenOne.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import XCTest
@testable import ImageFeed

final class testProgressHiddenWhenOne: XCTestCase {

    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertTrue(shouldHideProgress)
    }
}
