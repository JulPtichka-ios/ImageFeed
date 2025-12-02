//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 06.10.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    weak var delegate: ImagesListCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        cellImage.kf.indicatorType = .none
    }

    @IBAction func likeButtonClicked(_ sender: UIButton) {
        print("🔥 LIKE BUTTON TAPED!")
        delegate?.photosListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "likeButton" : "likeButtonOff"
        let image = UIImage(named: imageName)
        print("🔥 \(imageName): \(image != nil ? "✅ OK" : "❌ NOT FOUND")")
        likeButton.setImage(image, for: .normal)
    }
}
