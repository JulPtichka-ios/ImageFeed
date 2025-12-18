//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private(set) var viewDidLoadCalled = false
    private(set) var didTapLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
