//
//  testDidTapLikeCallsPresenter.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import XCTest
@testable import ImageFeed

final class testDidTapLikeCallsPresenter: XCTestCase {
    func testDidTapLikeCallsPresenter() {
        // given
        let presenter = ImagesListPresenterSpy()
        let sut = ImagesListViewController()
        
        // when
        sut.configure(presenter)
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled == false)
        XCTAssertEqual(presenter.photosCount, 1)
    }
}
