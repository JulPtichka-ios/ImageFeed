//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 27.10.2025.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(
                domain: "OAuth2Service",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to construct OAuth token request"]
            )
            print("[OAuth2Service]: Failed to create request")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[OAuth2Service]: Network error - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(
                    domain: "OAuth2Service",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]
                )
                print("[OAuth2Service]: Invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                let error = NSError(
                    domain: "OAuth2Service",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"]
                )
                print("[OAuth2Service]: Server error - status code \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                let error = NSError(domain: "OAuth2Service", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("[OAuth2Service]: No data received")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let oAuthTokenData = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                print("[OAuth2Service]: Successfully received token")
                DispatchQueue.main.async {
                    completion(.success(oAuthTokenData.accessToken))
                }
            } catch {
                print("[OAuth2Service]: Decoding error - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashTokenURLString) else {
            print("failed created URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = urlComponents.url else {
            print("failed created url from components")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
