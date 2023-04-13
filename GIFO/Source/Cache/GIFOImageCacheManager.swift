//
//  GIFOImageCacheManager.swift
//  GIFO
//
//  Created by BMO on 2023/03/07.
//

import UIKit

/// `GIFOImageCacheManager` is responsible for managing the caching of GIF images and UIImages.
internal class GIFOImageCacheManager {
    
    /// The singleton instance of the cache manager.
    internal static let shared = GIFOImageCacheManager()
    
    /// The cache for storing GIFOImageCacheItem objects that contain arrays of GIF frames.
    private let GIFOFrameCache = NSCache<NSString, GIFOImageCacheItem>()
    
    /// The cache for storing UIImage objects.
    private let UIImageCache = NSCache<NSString, UIImage>()
    
    /// Initializes the cache manager by setting the count limits for the two caches.
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
    ///
    /// - Parameters:
    ///   - images: The array of GIFOFrame objects to be cached.
    ///   - key: The key to identify the cached images.
    internal func addGIFImages(images: [GIFOFrame],
                               forKey key: String) {
        let item = GIFOImageCacheItem(frames: images)
        GIFOFrameCache.setObject(item, forKey: key as NSString)
    }
    
    /// Adds a UIImage object to the UIImageCache for the given key.
    ///
    /// - Parameters:
    ///   - image: The UIImage object to be cached.
    ///   - key: The key to identify the cached image.
    internal func addGIFUIImage(image: UIImage,
                                forKey key: String) {
        UIImageCache.setObject(image, forKey: key as NSString)
    }
    
    /// Returns an array of GIFOFrame objects from the GIFOFrameCache for the given key.
    ///
    /// - Parameters:
    ///    - key: The key to identify the cached image.
    /// - Returns: An array of GIFOFrame objects if the cache exists for the given key, nil otherwise.
    internal func getGIFImages(forKey key: String) throws -> [GIFOFrame]? {
        guard let item = GIFOFrameCache.object(forKey: key as NSString) else {
            throw GIFOImageCacheError.missingCacheObject(key: key)
        }
        return item.frames
    }
    
    /// Returns a UIImage object from the UIImageCache for the given key.
    ///
    /// - Parameters:
    ///    - key: The key to identify the cached image.
    /// - Returns: A UIImage object if the cache exists for the given key, nil otherwise.
    internal func getGIFUIImage(forKey key: String) throws -> UIImage? {
        guard let item = UIImageCache.object(forKey: key as NSString) else {
            throw GIFOImageCacheError.missingCacheObject(key: key)
        }
        return item
    }
    
    /// Checks if a cached image of the given type exists for the given key.
    ///
    /// - Parameters:
    ///   - type: The type of the cached image.
    ///   - key: The key to identify the cached image.
    /// - Returns: true if the cache exists for the given key and type, false otherwise.
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
    ///
    /// - Parameters:
    ///   - type: The type of the cached image.
    ///   - key: The key to identify the cached image
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
    ///
    /// - Parameters:
    ///   - type: The cache type (either .GIFFrame or .UIImage) of the objects to remove.
    internal func removeAllImageCache(_ type: CacheType) {
        switch type {
        case .GIFFrame:
            GIFOFrameCache.removeAllObjects()
        case .UIImage:
            UIImageCache.removeAllObjects()
        }
    }
}
