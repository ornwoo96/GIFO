//
//  GIfImageCacheItem.swift
//  GIFO
//
//  Created by BMO on 2023/02/28.
//

import UIKit

/// This class represents a cache item for GIF frames.
/// 이 클래스는 GIF 프레임의 캐시 항목을 나타냅니다.
internal class GIFOImageCacheItem {
    
    /// An array of GIF frames for the cached image
    /// 캐시된 GIF 프레임들을 담은 배열입니다.
    let frames: [GIFOFrame]
    
    /// Initialize the cache item with an array of GIF frames
    /// GIF 프레임 배열로 캐시 아이템을 초기화합니다.
    init(frames: [GIFOFrame]) {
        self.frames = frames
    }
}
