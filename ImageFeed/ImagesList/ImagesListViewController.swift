//
//  ViewController.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 03.10.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var photosObserver: NSObjectProtocol?
    private var likeRequestsInProgress = Set<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard OAuth2TokenStorage.shared.token != nil else {
            print("❌ ImagesListViewController: Требуется авторизация")
            return
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = nil
        
        photosObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        ImagesListService.shared.fetchPhotosNextPage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }

            let photo = photos[indexPath.row]
            viewController.imageURL = photo.fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func photosListCellDidTapLike(_ cell: ImagesListCell) {
        print("🔥 DELEGATE: photosListCellDidTapLike")
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("🔥 indexPath НЕ НАЙДЕН")
            return
        }
        
        let photo = photos[indexPath.row]
        
        if likeRequestsInProgress.contains(photo.id) {
            print("🔥 Запрос лайка уже выполняется для photo.id = \(photo.id)")
            return
        }

        likeRequestsInProgress.insert(photo.id)
        
        ImagesListService.shared.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] (result: Result<Void, Error>) in
            guard let self else { return }
            
            self.likeRequestsInProgress.remove(photo.id)
            
            switch result {
            case .success:
                print("🔥 changeLike SUCCESS")
                self.photos[indexPath.row].isLiked.toggle()
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("🔥 changeLike FAILURE: \(error)")
            }
        }
    }
    
    private func updateTableViewAnimated() {
        photos = ImagesListService.shared.photos
        tableView.reloadData()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        guard let thumbURL = URL(string: photo.thumbImageURL) else {
            cell.cellImage.image = UIImage(named: "photoPlaceholder")
            return
        }
        
        cell.cellImage.kf.setImage(
            with: thumbURL,
            placeholder: UIImage(named: "photoPlaceholder")
        )
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "Дата неизвестна"
        }
        
        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if likeRequestsInProgress.contains(photo.id) {
            tableView.deselectRow(at: indexPath, animated: true)
            print("🙅‍♂ Tap по ячейке заблокирован: идёт запрос лайка для \(photo.id)")
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let width = max(photo.size.width, 1)
        let height = max(photo.size.height, 1)
        
        let scale = imageViewWidth / width
        let cellHeight = height * scale + imageInsets.top + imageInsets.bottom
        print("⚙️ row \(indexPath.row) size=\(photo.size) -> height=\(cellHeight)")
        return max(cellHeight, 44)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}
