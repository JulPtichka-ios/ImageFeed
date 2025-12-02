//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Julia Ios on 27.11.2025.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func photosListCellDidTapLike(_ cell: ImagesListCell)
}
