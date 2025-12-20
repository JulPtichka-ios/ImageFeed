//
//  estViewControllerCallsPresenterViewDidLoad.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {

    func testProfileVCCallsPresenterViewDidLoad() {
        // given
        let sut = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        sut.configure(presenter)

        // when
        _ = sut.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

