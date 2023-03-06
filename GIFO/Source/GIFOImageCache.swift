//
//  GIFImageCache.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit

internal class GIFOImageCache {
    internal static let shared = GIFOImageCache()

    private let cache = NSCache<NSString, GIFOImageCacheItem>()

    internal func addGIFImages(_ images: [GIFOFrame], forKey key: String) {
        let item = GIFImageCacheItem(images: images)
        cache.setObject(item, forKey: key as NSString)
    }
    
    internal func getGIFImages(forKey key: String) -> [GIFOFrame]? {
        guard let item = cache.object(forKey: key as NSString) else { return nil }
        return item.images
    }
    
    internal func removeGIFImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
