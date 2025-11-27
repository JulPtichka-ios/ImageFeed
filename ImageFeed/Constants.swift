//
//  Constants.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 23.10.2025.
//

import UIKit

// MARK: - OAuth
enum Constants {
    static let accessKey = "4aHjhhCclbd47ZcqBJ4qvudEBfCY95gLocwXNITtkmM"
    static let secretKey = "YPo1nAnYuIoniFxsRhTNzeKXWy6ksdXmsraHWIgi8Go"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static let unsplashProfileURLString = "https://api.unsplash.com/me"
}

// MARK: - Progress
enum Progress {
    static let completedValue: Double = 1.0
    static let hideThreshold: Double = 0.0001
}

// MARK: - Alerts
enum Alerts {
    static let errorTitle = "Что-то пошло не так("
    static let authErrorPrefix = "Не удалось войти в систему. Ошибка: "
    static let okButtonTitle = "OK"
}
