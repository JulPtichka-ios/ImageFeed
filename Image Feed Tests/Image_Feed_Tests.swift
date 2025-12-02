//
//  Image_Feed_Tests.swift
//  Image Feed Tests
//
//  Created by Julia Ios on 27.11.2025.
//
//
//@testable import ImageFeed
//import XCTest
//
//final class ImagesListServiceTests: XCTestCase {
//    func testFetchPhotos() {
//        let service = ImagesListService()
//        
//        let expectation = self.expectation(description: "Wait for Notification")
//        NotificationCenter.default.addObserver(
//            forName: ImagesListService.didChangeNotification,
//            object: nil,
//            queue: .main) { _ in
//                expectation.fulfill()
//            }
//        
//        service.fetchPhotosNextPage()
//        wait(for: [expectation], timeout: 10)
//        
//        XCTAssertEqual(service.photos.count, 10)
//    }
//}
