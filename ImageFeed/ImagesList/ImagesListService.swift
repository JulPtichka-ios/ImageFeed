//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Julia Ios on 27.11.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let photosURL = "https://api.unsplash.com/photos"
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage = 0
    private let perPage = 10
    private let urlSession = URLSession(configuration: .default)
    
    private var fetchPhotosTask: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard fetchPhotosTask == nil else {
            print("❌ [fetchPhotosNextPage]: Загрузка уже выполняется")
            return
        }
        
        guard OAuth2TokenStorage.shared.token != nil else {
            print("❌ [fetchPhotosNextPage]: Требуется авторизация")
            return
        }
        
        let accessKey = Constants.accessKey
        print("🔥 Access Key: \(accessKey.count) символов")
        
        lastLoadedPage += 1
        let nextPage = lastLoadedPage
        
        var urlComponents = URLComponents(string: photosURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents.url else {
            print("❌ [fetchPhotosNextPage page:\(nextPage)]: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.fetchPhotosTask = nil
                
                if let error {
                    print("❌ [fetchPhotosNextPage page:\(nextPage)]: Network error: \(error.localizedDescription)")
                    return
                }
                
                print("🔥 /PHOTOS STATUS: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                
                guard let data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("❌ [fetchPhotosNextPage page:\(nextPage)]: HTTP error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔥 /PHOTOS JSON ПЕРВЫЕ 300: \(jsonString.prefix(300))...")
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
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ [fetchPhotosNextPage page:\(nextPage)]: Decoding error: \(error.localizedDescription). Data: \(jsonString.prefix(500))")
                    } else {
                        print("❌ [fetchPhotosNextPage page:\(nextPage)]: Decoding error: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        fetchPhotosTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            print("❌ [changeLike photoId:\(photoId)]: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"])
            print("❌ [changeLike photoId:\(photoId)]: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        urlSession.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error {
                    print("❌ [changeLike photoId:\(photoId)]: Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                    let error = NSError(domain: "HTTP", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"])
                    print("❌ [changeLike photoId:\(photoId)]: HTTP error: status \(statusCode)")
                    completion(.failure(error))
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
        fetchPhotosTask?.cancel()
        fetchPhotosTask = nil
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
    }
}
