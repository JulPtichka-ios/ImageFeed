//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 13.11.2025.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
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

final class ProfileService {
    static let shared = ProfileService()
    private init() { }

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Полученный JSON профиля: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(ProfileResult.self, from: data)

                let nameToShow: String
                if let name = result.name, !name.isEmpty {
                    nameToShow = name
                } else {
                    let fullName = [result.firstName, result.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    nameToShow = fullName.isEmpty ? "Имя не указано" : fullName
                }

                let username = result.username ?? ""

                let profile = Profile(
                    username: username,
                    name: nameToShow,
                    loginName: username.isEmpty ? "@неизвестный_пользователь" : "@\(username)",
                    bio: result.bio
                )

                self?.profile = profile

                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            } catch {
                print("[fetchProfile]: Ошибка декодирования: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
