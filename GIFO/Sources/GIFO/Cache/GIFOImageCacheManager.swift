//
//  GIFOImageCacheManager.swift
//  GIFO
//
//  Created by BMO on 2023/03/07.
//

import UIKit

/// `GIFOImageCacheManager` is responsible for managing the caching of GIF images and UIImages.
/// `GIFOImageCacheManager` 는 GIF 이미지와 UIImage의 캐싱을 관리하는 역할을 담당합니다.
internal class GIFOImageCacheManager {
    
    /// The singleton instance of the cache manager.
    /// 캐시 매니저의 싱글톤 인스턴스입니다.
    internal static let shared = GIFOImageCacheManager()
    
    /// The cache for storing GIFOImageCacheItem objects that contain arrays of GIF frames.
    /// GIFOImageCacheItem 객체를 저장 및 사용하기 위한 캐시입니다.
    private let GIFOFrameCache = NSCache<NSString, GIFOImageCacheItem>()
    
    /// The cache for storing UIImage objects.
    /// UIImage 객체를 저장하는 캐시입니다. ( UIImage.animatedImage로 만든 UIImage입니다. )
    private let UIImageCache = NSCache<NSString, UIImage>()
    
    /// Initializes the cache manager by setting the count limits for the two caches.
    /// 두 캐시의 카운트 제한을 설정하여 캐시 관리자를 초기화합니다. 오래된 캐시를 먼저 자동 삭제해줍니다.
    init() {
        self.UIImageCache.countLimit = 40
        self.GIFOFrameCache.countLimit = 3
    }
    
    /// The type of image cache.
    internal enum CacheType {
        case GIFFrame
        case UIImage
    }
    
    /// Adds an array of GIFOFrame objects to the GIFOFrameCache for the given key.
    /// 주어진 키로 GIFOFrameCache에 GIFOFrame 객체 배열을 추가합니다.
    ///
    /// - Parameters:
    ///   - images: The array of GIFOFrame objects to be cached. 캐시할 GIFOFrame 객체의 배열입니다.
    ///   - key: The key to identify the cached images. 캐시 이미지를 식별하는 데 사용되는 키입니다.
    internal func addGIFImages(images: [GIFOFrame],
                               forKey key: String) {
        let item = GIFOImageCacheItem(frames: images)
        GIFOFrameCache.setObject(item, forKey: key as NSString)
    }
    
    /// Adds a UIImage object to the UIImageCache for the given key.
    /// UIImage 개체를 지정된 키로 UIImageCache에 추가합니다.
    ///
    /// - Parameters:
    ///   - image: The UIImage object to be cached. 캐시할 UIImage 개체입니다.
    ///   - key: The key to identify the cached image. 캐시 이미지를 식별하는 데 사용되는 키입니다.
    internal func addGIFUIImage(image: UIImage,
                                forKey key: String) {
        UIImageCache.setObject(image, forKey: key as NSString)
    }
    
    /// Returns an array of GIFOFrame objects from the GIFOFrameCache for the given key.
    /// 주어진 키로 GIFOFrameCache에 있는 GIFOFrame 객체 배열을 반환합니다.
    ///
    /// - Parameters:
    ///    - key: The key to identify the cached image. 캐시된 이미지를 식별하기 위한 키입니다.
    /// - Returns: An array of GIFOFrame objects if the cache exists for the given key, nil otherwise. 주어진 키에 대한 캐시가 존재하면 GIFOFrame 객체 배열을 반환합니다.
    internal func getGIFImages(forKey key: String) throws -> [GIFOFrame]? {
        guard let item = GIFOFrameCache.object(forKey: key as NSString) else {
            throw GIFOImageCacheError.missingCacheObject(key: key)
        }
        return item.frames
    }
    
    /// Returns a UIImage object from the UIImageCache for the given key.
    /// 주어진 키로 UIImageCache에서 UIImage 객체를 반환합니다.
    ///
    /// - Parameters:
    ///    - key: The key to identify the cached image. 캐시된 이미지를 식별하는 데 사용되는 키입니다.
    /// - Returns: A UIImage object if the cache exists for the given key, nil otherwise. 주어진 키에 대한 캐시가 있으면 UIImage 객체를 반환합니다.
    internal func getGIFUIImage(forKey key: String) throws -> UIImage? {
        guard let item = UIImageCache.object(forKey: key as NSString) else {
            throw GIFOImageCacheError.missingCacheObject(key: key)
        }
        return item
    }
    
    /// Checks if a cached image of the given type exists for the given key.
    /// 주어진 키로 타입에 대한 캐시 이미지가 존재하는지 확인합니다.
    ///
    /// - Parameters:
    ///   - type: The type of the cached image. 캐시된 이미지의 타입입니다.
    ///   - key: The key to identify the cached image. 캐시된 이미지를 식별하는 키입니다.
    /// - Returns: true if the cache exists for the given key and type, false otherwise. 주어진 키와 타입에 대한 캐시가 존재하면 true, 그렇지 않으면 false를 반환합니다.
    internal func checkCachedImage(_ type: CacheType,
                                   forKey key: String) -> Bool {
        switch type {
        case .GIFFrame:
            if self.GIFOFrameCache.object(forKey: key as NSString) != nil {
                return true
            }
            return false
        case .UIImage:
            if self.UIImageCache.object(forKey: key as NSString) != nil {
                return true
            }
            return false
        }
    }
    
    /// Removes the cached image of the given type for the given key.
    /// 주어진 키로 지정된 타입의 캐시 이미지 데이터를 제거합니다.
    ///
    /// - Parameters:
    ///   - type: The type of the cached image. 캐시된 이미지의 타입입니다.
    ///   - key: The key to identify the cached image. 캐시된 이미지를 식별하는 키입니다.
    internal func removeImageCache(_ type: CacheType,
                                   forKey key: String) {
        switch type {
        case .GIFFrame:
            GIFOFrameCache.removeObject(forKey: key as NSString)
        case .UIImage:
            UIImageCache.removeObject(forKey: key as NSString)
        }
    }
    
    /// Removes all cached objects of the specified type from the cache.
    /// 지정된 타입의 모든 캐시된 객체를 캐시에서 제거합니다.
    ///
    /// - Parameters:
    ///   - type: The cache type (either .GIFFrame or .UIImage) of the objects to remove. 제거 할 객체의 캐시 타입 (.GIFFrame 또는 .UIImage).
    internal func removeAllImageCache(_ type: CacheType) {
        switch type {
        case .GIFFrame:
            GIFOFrameCache.removeAllObjects()
        case .UIImage:
            UIImageCache.removeAllObjects()
        }
    }
}
