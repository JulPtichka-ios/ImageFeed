//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 09.10.2025.
//

import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared

    private var profile: Profile?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Gray") ?? .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logoutButton"), for: .normal)
        button.tintColor = UIColor(named: "YP Red") ?? .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(">>> ProfileViewController загружен!")
        view.backgroundColor = UIColor(named: "YP Black") ?? .black

        [avatarImageView, nameLabel, usernameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }

        applyConstraints()
        updateProfile()

        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.updateAvatar()
            }
        )

        updateAvatar()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }
        logoutAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        let processor = RoundCornerImageProcessor(cornerRadius: 35)

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { result in
            switch result {
            case let .success(value):
                print("Image loaded from: \(value.source)")
            case let .failure(error):
                print("Failed to load image: \(error)")
            }
        }
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),

            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        usernameLabel.text = profile.username.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }

    private func updateProfile() {
        guard let token = OAuth2TokenStorage.shared.token else { return }

        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(profile):
                DispatchQueue.main.async {
                    self.profile = profile
                    self.updateProfileDetails(profile: profile)
                }
            case let .failure(error):
                print("Не удалось получить профиль:", error)
            }
        }
    }
}
