//
//  GIFOErrors.swift
//  GIFO
//
//  Created by BMO on 2023/04/11.
//

import Foundation

/// Enum that represents possible errors that can occur while fetching GIF images.
/// GIF 이미지를 가져오는 동안 발생할 수 있는 가능한 오류들입니다.
internal enum GIFODownLoaderError: Error {
    case invalidResponse
    case noData
    case invalidURL
    case failedRequest
}

/// Enum that represents an error that can occur when working with a GIF image view.
/// GIFOImageView 작업 중 발생할 수 있는 오류들입니다.
internal enum GIFOImageViewError: Error {
    case ImageFileNotFoundError
}

/// Enum that represents an error that can occur when working with a GIF image cache.
/// GIF 이미지 캐시 작업 중 발생할 수 있는 오류들입니다.
internal enum GIFOImageCacheError: Error {
    case missingCacheObject(key: String)
}
