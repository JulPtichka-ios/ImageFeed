//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Julia Ios on 27.11.2025.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String?
    let tokenType: String?
    let refreshToken: String?
    let scope: String?
    let createdAt: Int?
    let userId: Int?
    let username: String?
}
