//
//  GIFODownLoader.swift
//  GIFO
//
//  Created by BMO on 2023/03/07.
//

import UIKit

/// `GIFODownloader` provides functionality to download GIF images.
internal class GIFODownloader {
    
    /// This function fetches image data through the given URL.
    ///
    /// - Parameters:
    ///    - url: The URL string for the image data.
    ///    - completion:The closure to be called once the image data is fetched.
    static func fetchImageData(_ url: String,
                               completion: @escaping (Result<Data, GIFODownLoaderError>) -> Void) {
        guard let stringToURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: stringToURL) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.failedRequest))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let imageData = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(imageData))
        }.resume()
    }
    
    /// This function fetches image data from an asset file with the given file name.
    ///
    /// - Parameters:
    ///    - fileName:The name of the asset file to fetch the data from.
    /// - returns : The data object containing the image data from the asset file.
    static func getDataFromAsset(named fileName: String) throws -> Data? {
        guard let asset = NSDataAsset(name: fileName) else {
            throw GIFODownLoaderError.noData
        }
        
        return asset.data
    }
}
