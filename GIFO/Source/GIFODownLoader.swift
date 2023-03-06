//
//  GIFDownLoader.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit

enum GIFODownLoaderError: Error {
    case invalidResponse
    case noData
    case invalidURL
    case failedRequest
}

internal class GIFODownloader {
    static func fetchImageData(_ url: String) async throws -> Data {
        guard let stringToURL = URL(string: url) else {
            throw GIFODownLoaderError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: stringToURL)
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                throw GIFODownLoaderError.invalidResponse
            }
            
            return data
        } catch {
            throw GIFODownLoaderError.failedRequest
        }
    }
    
    static func getDataFromAsset(named fileName: String) throws -> Data? {
        guard let asset = NSDataAsset(name: fileName) else {
            throw GIFODownLoaderError.noData
        }
        
        return asset.data
    }
    
}
