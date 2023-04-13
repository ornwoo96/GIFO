//
//  GIfImageCacheItem.swift
//  GIFO
//
//  Created by BMO on 2023/02/28.
//

import UIKit

/// This class represents a cache item for GIF frames.
internal class GIFOImageCacheItem {
    
    /// An array of GIF frames for the cached image
    let frames: [GIFOFrame]
    
    /// Initialize the cache item with an array of GIF frames
    init(frames: [GIFOFrame]) {
        self.frames = frames
    }
}
