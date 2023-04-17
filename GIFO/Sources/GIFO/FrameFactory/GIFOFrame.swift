//
//  GIFOFrame.swift
//  GIFO
//
//  Created by BMO on 2023/02/03.
//

import UIKit

/// Represents a single frame in a GIF.
/// GIF의 단일 프레임을 나타냅니다.
internal struct GIFOFrame {
    
    /// Empty GIFOFrame instance for convenience.
    /// 빈 GIFOFrame 인스턴스입니다.
    static let empty: Self = .init(image: UIImage(),
                                   duration: 0.0)
    
    /// The image of the frame
    /// 업데이트할 때 쓰일 UIImage입니다.
    var image: UIImage?
    
    /// This duration is the time per frame.
    /// 이 duration은 프레임 하나의 시간입니다.
    var duration: TimeInterval
    
    /// Initializes a GIFOFrame instance with a CGImage
    /// CGImage로 GIFOFrame 인스턴스를 초기화합니다.
    init(image: CGImage,
         duration: TimeInterval) {
        self.image = UIImage(cgImage: image)
        self.duration = duration
    }
    
    /// Initializes a GIFOFrame instance with a UIImage
    /// GIFOFrame 인스턴스를 UIImage로 초기화합니다.
    init(image: UIImage,
         duration: TimeInterval) {
        self.image = image
        self.duration = duration
    }
}
