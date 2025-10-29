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
            handleFailure(
                message: "Unable to construct OAuth token request",
                code: -1,
                completion: completion
            )
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.handleFailure(
                    message: "Network error - \(error.localizedDescription)",
                    error: error,
                    completion: completion
                )
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                self?.handleFailure(
                    message: "Invalid response type",
                    code: -2,
                    completion: completion
                )
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                self?.handleFailure(
                    message: "Server returned status code \(httpResponse.statusCode)",
                    code: httpResponse.statusCode,
                    completion: completion
                )
                return
            }

            guard let data = data else {
                self?.handleFailure(
                    message: "No data received",
                    code: -3,
                    completion: completion
                )
                return
            }

            self?.decodeToken(from: data, completion: completion)
        }

        task.resume()
    }

    private func handleFailure(
        message: String,
        code: Int = -999,
        error: Error? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("[OAuth2Service]: \(message)")
        let nsError = error ?? NSError(domain: "OAuth2Service", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        DispatchQueue.main.async {
            completion(.failure(nsError))
        }
    }

    private func decodeToken(from data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let decoder = JSONDecoder()
            let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            print("[OAuth2Service]: Successfully received token")
            DispatchQueue.main.async {
                completion(.success(tokenResponse.accessToken))
            }
        } catch {
            handleFailure(
                message: "Decoding error - \(error.localizedDescription)",
                error: error,
                completion: completion
            )
        }
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
