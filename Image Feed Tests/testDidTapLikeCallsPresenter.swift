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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        sut.configure(presenter)
        _ = sut.view

        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first!
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as! ImagesListCell

        // when
        sut.photosListCellDidTapLike(cell)

        // then
        XCTAssertEqual(presenter.didTapLikeIndex, 0)
    }
}
