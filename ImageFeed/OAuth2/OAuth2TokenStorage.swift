//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 27.10.2025.
//

import UIKit

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
    func clean() -> Void
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case token
    }

    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: Keys.token.rawValue)
            } else {
                userDefaults.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }

    func clean() {
        userDefaults.removeObject(forKey: Keys.token.rawValue)
    }
}
