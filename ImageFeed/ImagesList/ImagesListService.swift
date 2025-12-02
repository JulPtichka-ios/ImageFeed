//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Julia Ios on 27.11.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let photosURL = "https://api.unsplash.com/photos"
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage = 0
    private let perPage = 10
    private let urlSession = URLSession(configuration: .default)
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard OAuth2TokenStorage.shared.token != nil else {
            print("❌ fetchPhotosNextPage: Требуется авторизация")
            return
        }
        let accessKey = Constants.accessKey
        print("🔥 Access Key: \(accessKey.count) символов")
        
        lastLoadedPage += 1
        
        var urlComponents = URLComponents(string: photosURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(lastLoadedPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            print("🔥 /PHOTOS STATUS: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("🔥 /PHOTOS JSON ПЕРВЫЕ 300: \(jsonString.prefix(300))...")
            }
            
            guard let data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ /PHOTOS ОШИБКА: Status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
                print("🔥 ПЕРВЫЕ 3 createdAt ИЗ API:")
                photoResults.prefix(3).forEach { result in
                    print("   \(result.id): '\(result.createdAt ?? "nil")'")
                }
                
                let newPhotos = photoResults.map { result -> Photo in
                    return Photo(from: result)
                }
                
                print("🔥 ПЕРВЫЕ 3 Photo createdAt:")
                newPhotos.prefix(3).forEach { photo in
                    print("   \(photo.id): \(photo.createdAt?.description ?? "nil")")
                }
                
                self.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                print("✅ Загружено фото: \(newPhotos.count)")
                
            } catch {
                print("❌ Ошибка парсинга: \(error)")
            }
        }.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        guard let token = OAuth2TokenStorage.shared.token else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        urlSession.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "HTTP",
                                                code: (response as? HTTPURLResponse)?.statusCode ?? 500)))
                    return
                }
                
                if let self, let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index].isLiked.toggle()
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
                
                completion(.success(()))
            }
        }.resume()
    }
    
    func reset() {
        photos.removeAll()
        lastLoadedPage = 0
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
    }
}
