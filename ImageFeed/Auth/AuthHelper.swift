//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        let url = authURL()
        print("🔗 authURL = \(url?.absoluteString ?? "nil")")
        guard let url else { return nil }
        return URLRequest(url: url)
    }
    
   func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        print("🔍 Parsing URL: \(url.absoluteString)")
        let urlComponents = URLComponents(string: url.absoluteString)
        let code = urlComponents?.queryItems?.first(where: { $0.name == "code" })?.value
        print("🔍 Extracted code: \(code ?? "nil")")
        return code
    }
}
