//
//  GIFOImageView+UIImage.swift
//  GIFO
//
//  Created by BMO on 2023/04/08.
//

import UIKit

/// It displays a GIF animation using `UIImageView.image` and `UIImage.animatedImage`.
extension GIFOImageView {
    
    /**
     Set up GIF image with UIImage from the image URL. **Tip: Suitable for large amounts of GIF usage.**
     image URL으로 GIF Image 생성 **Tip.많은 양의 GIF 사용 시 적합**
     
     - Parameters:
        - url: The URL of the GIF image. GIF 이미지의 URL입니다.
        - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
        - resize: The size to resize the image. 이미지의 크기를 조절하기 위한 CGSize 객체입니다.
        - level: The level to reduce the number of frames. 프레임 수를 줄이기 위한 레벨입니다.
        - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출할 블록입니다.
    */
    public func setupGIFImageWithUIImage(url: String,
                                         cacheKey: String,
                                         resize: CGSize? = nil,
                                         level: GIFFrameReduceLevel = .highLevel,
                                         animationOnReady: (() -> Void)? = nil) {
        clearWithUIImage()
        checkCachedImageWithUIImage(forKey: cacheKey, animationOnReady: animationOnReady)
        GIFODownloader.fetchImageData(url) { [weak self] result in
            switch result {
            case .success(let imageData):
                self?.setupForAnimationWithUIImage(imageData: imageData,
                                                   cacheKey: cacheKey,
                                                   resize: resize,
                                                   level: level,
                                                   animationOnReady: animationOnReady)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    /**
     Set up GIF image with UIImage from the image data. **Tip: Suitable for large amounts of GIF usage.**
     image Data로 GIF Image 생성 **Tip.많은 양의 GIF 사용 시 적합**
     
     - Parameters:
        - imageData: The data of the GIF image. GIF 이미지의 데이터입니다.
        - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
        - resize: The size to resize the image. 이미지 크기 조절을 위한 사이즈입니다.
        - level: The level to reduce the number of frames.  프레임 수를 줄이기 위한 레벨입니다.
        - animationOnReady: A block to be called when the animation is ready.  애니메이션이 준비되었을 때 호출할 블록입니다.
    */
    public func setupGIFImageWithUIImage(imageData: Data,
                                         cacheKey: String,
                                         resize: CGSize? = nil,
                                         level: GIFFrameReduceLevel = .highLevel,
                                         animationOnReady: (() -> Void)? = nil) {
        checkCachedImageWithUIImage(forKey: cacheKey, animationOnReady: animationOnReady)
        setupForAnimationWithUIImage(imageData: imageData,
                                     cacheKey: cacheKey,
                                     resize: resize,
                                     level: level,
                                     animationOnReady: animationOnReady)
    }
    
    /**
     Set up GIF image with UIImage from the image name. **Tip: Suitable for large amounts of GIF usage.**
     image name으로 GIF Image 생성 **Tip.많은 양의 GIF 사용 시 적합**
     
     - Parameters:
        - imageName: The name of the GIF image. GIF 이미지의 이름입니다.
        - cacheKey: The key to cache the image data.  이미지 데이터를 캐시하기 위한 키입니다.
        - resize: The size to resize the image. 이미지의 크기를 조정하는 데 사용됩니다.
        - level: The level to reduce the number of frames. 프레임 수를 줄이기 위한 수준입니다.
        - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출될 블록입니다.
    */
    public func setupGIFImageWithUIImage(imageName: String,
                                         cacheKey: String,
                                         resize: CGSize? = nil,
                                         level: GIFFrameReduceLevel = .highLevel,
                                         animationOnReady: (() -> Void)? = nil) {
        checkCachedImageWithUIImage(forKey: cacheKey, animationOnReady: animationOnReady)
        
        do {
            guard let imageData = try GIFODownloader.getDataFromAsset(named: imageName) else {
                print(GIFOImageViewError.ImageFileNotFoundError)
                return
            }
            
            setupForAnimationWithUIImage(imageData: imageData,
                                         cacheKey: cacheKey,
                                         resize: resize,
                                         level: level,
                                         animationOnReady: animationOnReady)
        } catch {
            print(GIFOImageViewError.ImageFileNotFoundError)
        }
    }
    
    /**
     This function initializes and frees the memory of the GIF image frames stored in the frameFactory, as well as initializes and releases the memory of the image in the UIImageView.
     이 함수는 frameFactory가 가지고 있는 GIF Image Frame, UIImageView 내부 image 초기화 및 메모리 해제 해주는 함수 입니다.
    */
    public func clearWithUIImage() {
        frameFactory?.clearFactoryWithUIImage {
            DispatchQueue.main.async { [weak self] in
                self?.image = nil
            }
        }
    }
    
    
    /// This function creates a FrameFactory object and injects an AnimatedImage into the image property of a UIImageView.
    /// 이 함수는 FrameFactory 생성, AnimatedImage 를 UIImageView 내부의 image에 주입시키는 작업을 하는 함수입니다.
    ///
    /// - Parameters:
    ///    - imageData: The Data of the GIF image. GIF 이미지의 데이터입니다.
    ///    - cacheKey: The key to cache the image data.  이미지 데이터를 캐싱하기 위한 키입니다.
    ///    - resize: The size to resize the image. 이미지 크기 조정입니다.
    ///    - level: The level to reduce the number of frames. 프레임 수를 줄이는 레벨입니다.
    ///    - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출될 블록입니다.
    private func setupForAnimationWithUIImage(imageData: Data,
                                              cacheKey: String,
                                              resize: CGSize?,
                                              level: GIFFrameReduceLevel,
                                              animationOnReady: (() -> Void)? = nil) {
        frameFactory = GIFOFrameFactory(data: imageData,
                                        size: resize)
        
        frameFactory?.getGIFImageWithUIImage(cacheKey: cacheKey,
                                             level: level) { image in
            DispatchQueue.main.async { [weak self] in
                self?.image = nil
                self?.image = image
            }
            animationOnReady?()
        }
    }
    
    
    /// This function checks if a cached image exists, and if a cached GIF image exists, injects it into the image property of a UIImageView.
    /// 이 함수는 캐시 GIF 이미지가 있는지 확인하고 캐시 GIF 이미지가 존재하면 UIImageView에 주입시키는 함수 입니다.
    ///
    /// - Parameters:
    ///    - cacheKey: The key to cache the image data. 이미지 데이터를 캐시하기 위한 키입니다.
    ///    - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비되었을 때 호출할 블록입니다.
    private func checkCachedImageWithUIImage(forKey cacheKey: String,
                                             animationOnReady: (() -> Void)? = nil) {
        do {
            if let image = try GIFOImageCacheManager.shared.getGIFUIImage(forKey: cacheKey) {
                DispatchQueue.main.async { [weak self] in
                    self?.image = nil
                    self?.image = image
                }
                animationOnReady?()
            }
        } catch {
            
        }
    }
}
