//
//  GIFFrame.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit

internal struct GIFOFrame {
    static let empty: Self = .init(image: UIImage().cgImage,
                                   duration: 0.0)
    
    var image: CGImage?
    var duration: Double
}
