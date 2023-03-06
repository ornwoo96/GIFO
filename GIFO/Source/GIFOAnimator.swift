//
//  GIFAnimator.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit
import ImageIO

internal protocol GIFOAnimatorImageUpdateDelegate {
    func animationImageUpdate(_ image: CGImage)
}

internal class GIFOAnimator {
    private var currentFrameIndex = 0
    private var lastFrameTime: Double = 0.0
    private var loopCount: Int = 0
    private var currentLoop: Int = 0
    private var displayLink: CADisplayLink?
    internal var delegate: GIFOAnimatorImageUpdateDelegate?
    private var frameFactory: GIFOFrameFactory?
    
    internal func setupForAnimation(data: Data,
                                    size: CGSize,
                                    loopCount: Int,
                                    contentMode: UIView.ContentMode,
                                    level: GIFFrameReduceLevel,
                                    isResizing: Bool,
                                    cacheKey: String,
                                    animationOnReady: (() -> Void)? = nil) {
        let gifDisplay = CADisplayLink(target: self, selector: #selector(updateFrame))
        gifDisplay.add(to: .current, forMode: .common)
        displayLink = gifDisplay
        frameFactory = nil
        frameFactory = GIFOFrameFactory(data: data,
                                       size: size,
                                       contentMode: contentMode,
                                       isResizing: isResizing,
                                       cacheKey: cacheKey)
        self.loopCount = loopCount
        frameFactory?.setupGIFImageFrames(level: level, animationOnReady: animationOnReady)
    }
    
    internal func setupCachedImages(animationOnReady: (() -> Void)? = nil) {
        frameFactory?.setupGIFImageFrames(animationOnReady: animationOnReady)
    }
    
    @objc private func updateFrame() {
        
        guard let frames = frameFactory?.animationFrames else {
            return
        }
        
        guard let elapsedTime = displayLink?.timestamp else {
            return
        }
        
        let elapsed = elapsedTime - lastFrameTime
        
        guard elapsed >= frames[currentFrameIndex].duration else {
            return
        }
        
        currentFrameIndex += 1
        
        if currentFrameIndex >= frames.count {
            currentFrameIndex = 0
            currentLoop += 1
        }
        
        if loopCount != 0 && currentLoop >= loopCount {
            currentFrameIndex = 0
            stopAnimation()
            return
        }
        
        guard let currentImage = frames[currentFrameIndex].image else {
            return
        }
        
        delegate?.animationImageUpdate(currentImage)
        
        guard let displayLinkLastFrameTime = displayLink?.timestamp else {
            return
        }
        
        lastFrameTime = displayLinkLastFrameTime
    }
    
    internal func startAnimation() {
        guard let displayLink = displayLink else {
            return
        }
        
        DispatchQueue.main.async {
            displayLink.isPaused = false
        }
        
    }
    
    internal func clear() {
        guard let displayLink = displayLink else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            displayLink.invalidate()
            self?.frameFactory?.clearFactory()
        }
    }
    
    internal func stopAnimation() {
        guard let displayLink = displayLink else {
            return
        }
        
        DispatchQueue.main.async {
            displayLink.isPaused = true
        }
    }
    
    internal func checkCachingStatus() -> Bool {
        guard let bool = frameFactory?.isCached else { return false }
        return bool
    }
}
