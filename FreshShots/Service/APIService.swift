//
//  APIService.swift
//  FreshShots
//
//  Created by Jeba Moses on 17/10/22.
//

import Foundation
import Combine

/// Error Handling enum for all HTTP requests
enum HTTPError: LocalizedError {
    case statusCode(Int)
    case failure(String)
    case noResponse
    case invalidURL
}

/// Service that handles all request and responses
class APIService {
    var cancellable: AnyCancellable?
    var imageDownloadCancellables = Set<AnyCancellable>()
    
    /// Public method for request images from gallery with given search text
    /// - Parameter searchText: Text to be searched
    /// - Returns: Result: Array of ImageData in success and HTTPError in case of failure.l
    func galleryRequest(_ searchText: String?) async -> Result<[ImageData], HTTPError> {
        let url = getRequestURL(searchText)
        return await requestGalleryImages(url)
    }
    
    /// Public method for request images from gallery with given search text
    /// - Parameter url: URL to invoke the data task
    /// - Returns:  Result: Array of ImageData in success and HTTPError in case of failure.
    func requestGalleryImages(_ url: URL?) async -> Result<[ImageData], HTTPError> {
        /// Cancel the previous request
        cancellable?.cancel()
        
        guard let url else {  return .failure(.invalidURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Client-ID \(Constants.clientId)", forHTTPHeaderField: "Authorization")
        
        return await withCheckedContinuation { continuation in
            cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse else {
                        throw HTTPError.noResponse
                    }
                    
                    guard response.statusCode == 200 else {
                        throw HTTPError.statusCode(response.statusCode)
                    }
                    
                    return output.data
                    
                }
                .decode(type: ImgurResponse.self, decoder: JSONDecoder())
                .map { $0.data }
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        var httpError = HTTPError.failure(error.localizedDescription)
                        if let error = error as? HTTPError {
                            httpError = error
                        }
                        
                        continuation.resume(returning: .failure(httpError))
                    }
                } receiveValue: { images in
                    continuation.resume(returning: .success(images))
                }
        }
    }
    
    /// Downloads image from given URL
    /// - Parameter url: image URL string
    /// - Returns: Result, ImageData in success case otherwise HTTPError
    func downloadImage(from url: String) async -> Result<Data, HTTPError> {
        guard let url = URL(string: url) else { return .failure(.invalidURL) }
        return await withCheckedContinuation { continuation in
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse else {
                        throw HTTPError.noResponse
                    }
                    
                    guard response.statusCode == 200 else {
                        throw HTTPError.statusCode(response.statusCode)
                    }
                    
                    return output.data
                }.sink { completion in
                    
                    switch completion {
                        
                    case .finished:
                        break
                    case .failure(let error):
                        var httpError = HTTPError.failure(error.localizedDescription)
                        if let error = error as? HTTPError {
                            httpError = error
                        }
                        continuation.resume(returning: .failure(httpError))
                    }
                    
                } receiveValue: { imageData in
                    continuation.resume(returning: .success(imageData))
                }.store(in: &imageDownloadCancellables)
        }
    }
    
    /// Provides base URL
    /// - Returns: Base URL string
    func getBaseURL() -> String {
        let url = Constants.baseURL
        let version = Constants.version
        return "\(url)/\(version)"
    }
    
    /// Builds request URL with search text
    /// - Parameter searchText: Text to be searched
    /// - Returns: URL for gallery search
    func getRequestURL(_ searchText: String?) -> URL? {
        let sort = SortTypeEnum.top
        let window = WindowTypeEnum.week
        let section = SectionTypeEnum.top
        let isSearchTextAvailable = !searchText.isEmptyOrNil
        
        let baseURL = getBaseURL()
        var urlString = "\(baseURL)/\(Constants.galleryEndPoint)/"
        var url: URL?
        
        if isSearchTextAvailable {
            urlString.append(Constants.search)
        } else {
            urlString.append("\(section)")
        }
        
        urlString = urlString + "/\(sort)/\(window)/"
        
        if isSearchTextAvailable {
            let queryItems = [URLQueryItem(name: "q", value: searchText)]
            guard var urlComps = URLComponents(string: urlString) else { return nil }
            urlComps.queryItems = queryItems
            url = urlComps.url
        } else {
            url = URL(string: urlString)
        }
        
        return url
    }
}
