//
//  GIFOImageView+CADisplayLink.swift
//  GIFO
//
//  Created by BMO on 2023/02/03.
//

import UIKit

/// It displays high-quality GIF images using `CADisplayLink`.
/// `CADisplayLink`를 사용하여 고품질 GIF 이미지를 표시합니다.
public class GIFOImageView: UIImageView {
    
    /// An object that holds a CADisplayLink.
    /// `CADisplayLink`를 가지고 있는 animator 프로퍼티입니다.
    private var animator: GIFOAnimator?
    
    /// An object that creates the required GIF frames.
    /// GIF Frame을 관리해주는 프로퍼티입니다. UIImage.animatedImage 사용 시 필요
    internal var frameFactory: GIFOFrameFactory?
    
    /**
     Set up GIF image with  `CADisplayLink` from the image URL.  **Tip: It is suitable for displaying high-quality images.**
     이미지 URL,  `CADisplayLink` 와 함께 GIF 이미지를 설정합니다.  **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**
     
     - Parameters:
        - url: The URL of the GIF image. GIF 이미지의 URL입니다.
        - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true. 이미지 데이터를 캐시할지 여부를 나타내는 불리언 값입니다. 기본값은 true입니다.
        - resize: A CGSize object to resize the image. The default value is CGSize(). 이미지를 조정할 CGSize 객체입니다. 기본값은 CGSize()입니다.
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0. 애니메이션을 반복하는 횟수입니다. 0은 무한을 의미합니다. 기본값은 0입니다.
        - level: The level to reduce the number of frames.  프레임 수를 줄이는 데 사용할 레벨입니다.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil. 애니메이션이 준비되면 호출될 블록입니다. 기본값은 nil입니다.
    */
    public func setupGIFImageWithDisplayLink(url: String,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFOFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()

        if checkCachedImages(.GIFFrame,
                             cacheKey) {
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
        } else {
            animationOnReady?()
        }
    }
    
    /**
     Set up GIF image with `CADisplayLink` from the image Data. **Tip: It is suitable for displaying high-quality images.**
     이미지 Data, `CADisplayLink` 와 함께 GIF 이미지를 설정합니다. **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**
     
     - Parameters:
        - data: The Data of the GIF image.  GIF 이미지의 Data입니다.
        - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true. 이미지 데이터를 캐시할지 여부를 나타내는 불리언 값입니다. 기본값은 true입니다.
        - resize: A CGSize object to resize the image. The default value is CGSize(). 이미지를 조정할 CGSize 객체입니다. 기본값은 CGSize()입니다.
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0. 애니메이션을 반복하는 횟수입니다. 0은 무한을 의미합니다. 기본값은 0입니다.
        - level: The level to reduce the number of frames. 프레임 수를 줄이는 데 사용할 레벨입니다.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil. 애니메이션이 준비되면 호출될 블록입니다. 기본값은 nil입니다.
    */
    public func setupGIFImageWithDisplayLink(imageData: Data,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFOFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()
        
        if checkCachedImages(.GIFFrame,
                             cacheKey) {
            setupForAnimationWithDisplayLink(imageData: imageData,
                                             cacheKey: cacheKey,
                                             isCache: isCache,
                                             resize: resize,
                                             loopCount: loopCount,
                                             level: level,
                                             animationOnReady: animationOnReady)
        } else {
            animationOnReady?()
        }
    }
    
    /**
     Set up GIF image with `CADisplayLink` from the image Name. **Tip: It is suitable for displaying high-quality images.**
     이미지 name, `CADisplayLink` 와 함께 GIF 이미지를 설정합니다. **Tip: 고품질의 GIF 이미지를 표시할 때 적합합니다.**

     - Parameters:
        - imageName: The Name of the GIF image. GIF 이미지의 이름입니다.
        - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
        - isCache: A Boolean value that indicates whether to cache the image data. The default value is true. 이미지 데이터를 캐시할지 여부를 나타내는 불리언 값입니다. 기본값은 true입니다.
        - resize: A CGSize object to resize the image. The default value is CGSize(). 이미지를 조정할 CGSize 객체입니다. 기본값은 CGSize()입니다.
        - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0. 애니메이션을 반복하는 횟수입니다. 0은 무한을 의미합니다. 기본값은 0입니다.
        - level: The level to reduce the number of frames. 프레임 수를 줄이는 데 사용할 레벨입니다.
        - animationOnReady: A block to be called when the animation is ready. The default value is nil. 애니메이션이 준비되면 호출될 블록입니다. 기본값은 nil입니다.
    */
    public func setupGIFImageWithDisplayLink(imageName: String,
                                             cacheKey: String,
                                             isCache: Bool = true,
                                             resize: CGSize? = nil,
                                             loopCount: Int = 0,
                                             level: GIFOFrameReduceLevel = .highLevel,
                                             animationOnReady: (() -> Void)? = nil) {
        createAnimator()

        if checkCachedImages(.GIFFrame,
                             cacheKey) {
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
        } else {
            animationOnReady?()
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
    
    /// This function creates an animator and sets its delegate.
    /// 이 함수는 animator를 생성하고, animator의 delegate를 설정합니다.
    private func createAnimator() {
        clearWithDisplayLink()
        animator = GIFOAnimator()
        animator?.delegate = self
    }
    
    
    /// This function puts imageData and option values into the animator, and automatically starts the animation when the GIF frames of the animator and factory are all created.
    /// 이 함수는 imageData와 option 값을 animator에 넣고, animator 및 factory의 GIF 프레임이 모두 생성되면 자동으로 애니메이션을 시작합니다.
    ///
    /// - Parameters:
    ///    - imageData: The Data of the GIF image. GIF 이미지의 데이터입니다.
    ///    - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
    ///    - isCache: A Boolean value that indicates whether to cache the image data. The default value is true. 이미지 데이터를 캐시할지 여부를 나타내는 불리언 값입니다. 기본값은 true입니다.
    ///    - resize: The size to resize the image. 이미지의 크기를 조정하기 위한 값입니다.
    ///    - loopCount: The number of times the animation should be repeated. 0 means infinite. The default value is 0. 애니메이션을 반복하는 횟수입니다. 0은 무한을 의미합니다. 기본값은 0입니다.
    ///    - level: The level to reduce the number of frames. 프레임 수를 줄이기 위한 레벨입니다.
    ///    - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출할 블록입니다.
    private func setupForAnimationWithDisplayLink(imageData: Data,
                                                  cacheKey: String,
                                                  isCache: Bool,
                                                  resize: CGSize?,
                                                  loopCount: Int,
                                                  level: GIFOFrameReduceLevel,
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
    /// 이 함수는 애니메이션 레이어의 디스플레이를 업데이트하고 contents 내용을 지웁니다.
    private func clearAnimationLayer() {
        DispatchQueue.main.async { [weak self] in
            self?.layer.setNeedsDisplay()
            self?.layer.contents = nil
        }
    }
    
    /// This function checks if the specified image is cached, and if so, it sets up the animator with the cached images and starts the animation when the frames are ready.
    /// 이 함수는 지정된 이미지가 캐시되어 있는지 확인하고, 이미지가 캐시되어 있다면 캐시된 이미지로 애니메이터를 설정하고 프레임이 준비되면 애니메이션을 시작합니다.
    ///
    /// - Parameters:
    ///    - type: The type of the cached image. 캐시된 이미지의 유형
    ///    - key: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키
    ///    - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출할 블록
    private func checkCachedImages(_ type: GIFOImageCacheManager.CacheType,
                                   _ key: String) -> Bool {
        if GIFOImageCacheManager.shared.checkCachedImage(type,forKey: key) {
            self.animator?.setupCachedImages(cacheKey: key) {
                self.startAnimationWithDisplayLink()
            }
            return false
        } else {
            return true
        }
    }
}

extension GIFOImageView: GIFOAnimatorImageUpdateDelegate {
    /// This function creates a FrameFactory object and injects an AnimatedImage into the image property of a UIImageView.
    /// 이 함수는 FrameFactory 객체를 생성하고, UIImageView의 image 속성에 AnimatedImage를 주입합니다.
    ///
    /// - Parameter image: The delegated Image.  파라미터인 image는 업데이트할 UIImage 객체입니다.
    func animationImageUpdate(image: UIImage) {
        self.layer.setNeedsDisplay()
        self.layer.contents = image.cgImage
    }
}
