//
//  GIFODownLoader.swift
//  GIFO
//
//  Created by BMO on 2023/03/07.
//

import UIKit

/// `GIFODownloader` provides functionality to download GIF images.
/// `GIFODownloader`는 GIF 이미지를 다운로드하는 기능을 제공합니다.
internal class GIFODownloader {
    
    /// This function fetches image data through the given URL.
    /// 이 함수는 주어진 URL을 통해 이미지 데이터를 가져옵니다.
    ///
    /// - Parameters:
    ///    - url: The URL string for the image data. 이미지 데이터를 가져올 URL 문자열입니다.
    ///    - completion:The closure to be called once the image data is fetched. 이미지 데이터를 가져온 후 호출될 클로저입니다.
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
    /// 이 함수는 주어진 파일 이름으로부터 애셋 파일에서 이미지 데이터를 가져옵니다.
    ///
    /// - Parameters:
    ///    - fileName: The name of the asset file to fetch the data from. 데이터를 가져올 asset file의 이름입니다.
    /// - returns : The data object containing the image data from the asset file. asset file에서 이미지 데이터를 포함하는 데이터 객체입니다.
    static func getDataFromAsset(named fileName: String) throws -> Data? {
        guard let asset = NSDataAsset(name: fileName) else {
            throw GIFODownLoaderError.noData
        }
        
        return asset.data
    }
}
