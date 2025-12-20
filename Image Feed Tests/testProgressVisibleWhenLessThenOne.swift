//
//  testProgressVisibleWhenLessThenOne.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import XCTest
@testable import ImageFeed

final class testProgressVisibleWhenLessThenOne: XCTestCase {

    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(shouldHideProgress)
    }
}
