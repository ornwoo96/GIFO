//
//  GIFOFrame.swift
//  GIFO
//
//  Created by BMO on 2023/02/03.
//

import UIKit

/// Represents a single frame in a GIF.
internal struct GIFOFrame {
    
    /// Empty GIFOFrame instance for convenience
    static let empty: Self = .init(image: UIImage(),
                                   duration: 0.0)
    
    /// The image of the frame
    var image: UIImage?
    
    /// The duration of the frame in seconds
    var duration: TimeInterval
    
    /// Initializes a GIFOFrame instance with a CGImage
    init(image: CGImage,
         duration: TimeInterval) {
        self.image = UIImage(cgImage: image)
        self.duration = duration
    }
    
    /// Initializes a GIFOFrame instance with a UIImage
    init(image: UIImage,
         duration: TimeInterval) {
        self.image = image
        self.duration = duration
    }
}
