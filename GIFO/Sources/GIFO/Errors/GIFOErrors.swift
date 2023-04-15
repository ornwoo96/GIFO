//
//  GIFOErrors.swift
//  GIFO
//
//  Created by BMO on 2023/04/11.
//

import Foundation

/// Enum that represents possible errors that can occur while fetching GIF images.
internal enum GIFODownLoaderError: Error {
    case invalidResponse
    case noData
    case invalidURL
    case failedRequest
}

/// Enum that represents an error that can occur when working with a GIF image view.
internal enum GIFOImageViewError: Error {
    case ImageFileNotFoundError
}

/// Enum that represents an error that can occur when working with a GIF image cache.
internal enum GIFOImageCacheError: Error {
    case missingCacheObject(key: String)
}
