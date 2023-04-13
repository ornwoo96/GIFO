//
//  GIFOImageView+CADisplayLink.swift
//  GIFO
//
//  Created by BMO on 2023/02/03.
//

import UIKit

/// It displays high-quality GIF images using `CADisplayLink`.
public class GIFOImageView: UIImageView {
    
    /// An object that holds a CADisplayLink.
    private var animator: GIFOAnimator?
    
    /// An object that creates the required GIF frames.
    internal var frameFactory: GIFOFrameFactory?
    
    /**
     Set up GIF image with  `CADisplayLink` from the image URL.  **Tip: It is suitable for displaying high-quality images.**
     이미지 URL,  `CADisplayLink` 와 함께 GIF 이미지를 설정합니다.  **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**
     
     - Parameters:
        - url: The URL of the GIF image.
        - cacheKey: The key to cache the image data.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true.
        - size: A CGSize object to resize the image. The default value is CGSize().
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0.
        - level: The level to reduce the number of frames.
        - isResizing: A Boolean value that indicates whether to resize the image.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil.
    */
    public func setupGIFImageWithDisplayLink(url: String,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()

        checkCachedImages(.GIFFrame,
                          cacheKey,
                          animationOnReady: animationOnReady)
        
        GIFODownloader.fetchImageData(url) { result in
            switch result {
            case .success(let imageData):
                self.setupForAnimationWithDisplayLink(imageData: imageData,
                                                      cacheKey: cacheKey,
                                                      isCache: isCache,
                                                      resize: resize,
                                                      loopCount: loopCount,
                                                      level: level,
                                                      animationOnReady: animationOnReady)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /**
     Set up GIF image with `CADisplayLink` from the image Data. **Tip: It is suitable for displaying high-quality images.**
     이미지 Data, `CADisplayLink` 와 함께 GIF 이미지를 설정합니다. **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**
     
     - Parameters:
        - data: The Data of the GIF image.
        - cacheKey: The key to cache the image data.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true.
        - size: A CGSize object to resize the image. The default value is CGSize().
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0.
        - level: The level to reduce the number of frames.
        - isResizing: A Boolean value that indicates whether to resize the image.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil.
    */
    public func setupGIFImageWithDisplayLink(imageData: Data,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()
        
        checkCachedImages(.GIFFrame,
                          cacheKey,
                          animationOnReady: animationOnReady)
        
        setupForAnimationWithDisplayLink(imageData: imageData,
                                         cacheKey: cacheKey,
                                         isCache: isCache,
                                         resize: resize,
                                         loopCount: loopCount,
                                         level: level,
                                         animationOnReady: animationOnReady)
    }
    
    /**
     Set up GIF image with `CADisplayLink` from the image Name. **Tip: It is suitable for displaying high-quality images.**
     이미지 name, `CADisplayLink` 와 함께 GIF 이미지를 설정합니다. **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**

     - Parameters:
        - imageName: The Name of the GIF image.
        - cacheKey: The key to cache the image data.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true.
        - size: A CGSize object to resize the image. The default value is CGSize().
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0.
        - level: The level to reduce the number of frames.
        - isResizing: A Boolean value that indicates whether to resize the image.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil.
    */
    public func setupGIFImageWithDisplayLink(imageName: String,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()

        checkCachedImages(.GIFFrame,
                          cacheKey,
                          animationOnReady: animationOnReady)
        do {
            guard let imageData = try GIFODownloader.getDataFromAsset(named: imageName) else {
                print(GIFOImageViewError.ImageFileNotFoundError)
                return
            }
            
            setupForAnimationWithDisplayLink(imageData: imageData,
                                             cacheKey: cacheKey,
                                             isCache: isCache,
                                             resize: resize,
                                             loopCount: loopCount,
                                             level: level,
                                             animationOnReady: animationOnReady)
        } catch {
            print(GIFOImageViewError.ImageFileNotFoundError)
        }
    }
    
    /**
     Start GIF animation. `CADisplayLink` begins to update.
     `CADisplayLink`의 업데이트를 시작합니다.
    */
    public func startAnimationWithDisplayLink() {
        animator?.startAnimation()
    }
    
    /**
     Pause GIF animation. Pauses the update of the `CADisplayLink`.
     `CADisplayLink`의 업데이트를 일시정지 합니다.
    */
    public func stopAnimationWithDisplayLink() {
        animator?.stopAnimation()
    }
    
    /**
     This function initializes and deallocates all three objects: `CADisplayLink`, AnimationLayer, and FrameFactory.
     `CADisplayLink`, AnimationLayer, FrameFactory 세가지를 모두 초기화 및 메모리해제 시킵니다.
    */
    public func clearWithDisplayLink() {
        animator?.clear { [weak self] in
            self?.clearAnimationLayer()
        }
    }
    
    /// This function creates a FrameFactory object and injects an AnimatedImage into the image property of a UIImageView.
    private func createAnimator() {
        clearWithDisplayLink()
        animator = GIFOAnimator()
        animator?.delegate = self
    }
    
    
    /// This function puts imageData and option values into the animator, and automatically starts the animation when the GIF frames of the animator and factory are all created.
    ///
    /// - Parameters:
    ///    - imageData: The Data of the GIF image.
    ///    - cacheKey: The key to cache the image data.
    ///    - size: The size to resize the image.
    ///    - level: The level to reduce the number of frames.
    ///    - isResizing: A Boolean value that indicates whether to resize the image.
    ///    - animationOnReady: A block to be called when the animation is ready.
    private func setupForAnimationWithDisplayLink(imageData: Data,
                                                  cacheKey: String,
                                                  isCache: Bool,
                                                  resize: CGSize?,
                                                  loopCount: Int,
                                                  level: GIFFrameReduceLevel,
                                                  animationOnReady: (() -> Void)? = nil) {
        animator?.setupForAnimation(data: imageData,
                                    size: resize,
                                    loopCount: loopCount,
                                    level: level,
                                    cacheKey: cacheKey,
                                    isCache: isCache) {
            self.animator?.startAnimation()
            animationOnReady?()
        }
    }
    
    
    /// This function clears the animation layer by setting its display to be updated and clearing its contents.
    private func clearAnimationLayer() {
        DispatchQueue.main.async { [weak self] in
            self?.layer.setNeedsDisplay()
            self?.layer.contents = nil
        }
    }
    
    /// This function checks if the specified image is cached, and if so, it sets up the animator with the cached images and starts the animation when the frames are ready.
    ///
    /// - Parameters:
    ///    - type: The type of the cached image.
    ///    - key: The key to cache the image data.
    ///    - animationOnReady: A block to be called when the animation is ready.
    private func checkCachedImages(_ type: GIFOImageCacheManager.CacheType,
                                   _ key: String,
                                   animationOnReady: (() -> Void)? = nil) {
        if GIFOImageCacheManager.shared.checkCachedImage(type,forKey: key) {
            self.animator?.setupCachedImages(cacheKey: key) {
                self.startAnimationWithDisplayLink()
                animationOnReady?()
            }
        }
    }
}

extension GIFOImageView: GIFOAnimatorImageUpdateDelegate {
    /// This function creates a FrameFactory object and injects an AnimatedImage into the image property of a UIImageView.
    ///
    /// - Parameter image: The delegated Image
    func animationImageUpdate(image: UIImage) {
        self.layer.setNeedsDisplay()
        self.layer.contents = image.cgImage
    }
}
