//
//  ProfileModels.swift
//  ImageFeed
//
//  Created by Julia Ios on 27.11.2025.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    var bio: String?
}

struct ProfileResult: Codable {
    let username: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
