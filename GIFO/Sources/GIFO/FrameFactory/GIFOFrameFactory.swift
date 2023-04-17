//
//  GIFFrameFactory.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit

/// The number of GIF frames can be adjusted in three levels.
/// GIF 프레임 수를 세 가지 수준으로 조정할 수 있습니다.
///
///  - highLevel: the original size.  오리지널 프레임 수.
///  - middleLevel: 2x reduction. 2배 축소.
///  - lowLevel: 3x reduction. 3배 축소.
public enum GIFOFrameReduceLevel {
    case highLevel
    case middleLevel
    case lowLevel
}

/// `GIFOFrameFactory` is a class that manages GIF frames by caching, storing, creating, and resizing them.
/// `GIFOFrameFactory` 는 GIF 프레임을 캐싱, 저장, 생성 및 크기 조정하는 클래스입니다.
internal class GIFOFrameFactory {
    
    /// It's an object that represents the source data of an image.
    /// 이미지의 소스 데이터를 나타내는 객체입니다
    private var imageSource: CGImageSource?
    
    /// The size of the image.
    /// GIF image 사이즈입니다.
    private var imageSize: CGSize?
    
    /// The cache key for the animation frames.
    /// animationFrames들을 캐싱 작업할때 필요한 key입니다.
    private var cacheKey: String?
    
    /// The duration of each frame in the animation.
    /// Gif 이미지들의 각각의 프레임 duration을 모은 Array입니다. (UIImage.animatedImage 사용시 필요)
    private var frameDurations: [Double] = []
    
    /// The animation frames should be cached or not.
    /// Cache 작업을 할건지 Bool 값으로 나타낸 객체입니다.
    private var isCache = true
    
    /// An array of GIFOFrame objects that hold the frames of the animation in GIFO format.
    /// GIFOFrames 형태에 배열입니다. (CADisplayLink사용시 필요)
    internal var animationGIFOFrames: [GIFOFrame] = []
    
    /// The total number of frames in the animation.
    /// 프레임의 총 개수입니다.
    internal var totalFrameCount: Int?
    
    /// The total duration of the animation.
    /// UIImage배열의 각 duration 값들을 전부 합친 시간입니다. (UIImage.animatedImage 사용시 필요)
    internal var animationTotalDuration = 0.0
    
    /// This is an initializer for a class that initializes the imageSource, imageSize, and isCache properties.
    /// imageSource, imageSize, isCache 속성을 초기화하는 클래스의 초기화 메소드입니다.
    ///
    /// - Parameters:
    ///    - data: The data of the GIF image. GIF 이미지 데이터입니다.
    ///    - size: The size of the GIF image. GIF 이미지의 크기입니다.
    ///    - isCache: A Boolean value indicating whether to cache the GIF image data. GIF 이미지 데이터를 캐시할지 여부를 나타내는 부울 값입니다.
    init(data: Data,
         size: CGSize?,
         isCache: Bool = true) {
        let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
        self.imageSource = CGImageSourceCreateWithData(data as CFData, options) ?? CGImageSourceCreateIncremental(options)
        self.imageSize = size
        self.isCache = isCache
    }
    
    /// Release properties related to GIFOFrame.
    /// GIFOFrame와 관련된 속성을 해제합니다.
    internal func clearFactoryWithGIFOFrame(completion: @escaping ()->Void) {
        self.animationGIFOFrames = []
        self.imageSource = nil
        self.totalFrameCount = 0
        self.cacheKey = nil
        self.isCache = true
        completion()
    }
    
    /// Release properties related to UIImage.
    /// UIImage와 관련된 속성을 해제합니다.
    internal func clearFactoryWithUIImage(completion: @escaping ()->Void) {
        self.imageSource = nil
        self.totalFrameCount = 0
        self.animationTotalDuration = 0
        self.cacheKey = nil
        self.frameDurations = []
        completion()
    }
    
    /// This function sets up GIF image frames with GIFOFrame.
    /// 이 함수는 GIFOFrame을 사용하여 GIF 이미지 프레임을 설정합니다.
    ///
    /// - Parameters:
    ///    - cacheKey: The key of the cache for the GIF image. GIF 이미지의 캐시 키입니다.
    ///    - level: The level of GIF frame reduction, with a default value of .highLevel. GIF 프레임 축소 레벨입니다, 기본값은 .highLevel입니다.
    ///    - animationOnReady: animationOnReady is a closure that is called after the GIF frames are created. animationOnReady는 GIF 프레임을 생성한 후 호출되는 클로저입니다.
    internal func setupGIFImageFramesWithGIFOFrame(cacheKey: String,
                                                   level: GIFOFrameReduceLevel = .highLevel,
                                                   animationOnReady: @escaping () -> Void) {
        self.cacheKey = cacheKey
        
        guard let imageSource = self.imageSource else {
            return
        }
        
        let frames = convertCGImageSourceToGIFOFrameArray(source: imageSource)
        let levelFrames = getLevelFrameWithGIFOFrame(level: level, frames: frames)
        
        self.animationGIFOFrames = levelFrames
        
        if isCache {
            GIFOImageCacheManager.shared.addGIFImages(images: levelFrames,
                                                      forKey: cacheKey)
        }
        
        animationOnReady()
    }
    
    /// This function creates a UIImage.AnimatedImage and returns it as an argument in the escaping closure.
    /// 이 함수는 UIImage.AnimatedImage만든 UIImage를 생성하고 탈출 클로저 인자값으로 UIImage를 반환합니다.
    ///
    /// - Parameters:
    ///    - cacheKey: The key of the cache for the GIF image. GIF 이미지의 캐시 키입니다.
    ///    - level: The level of GIF frame reduction, with a default value of .highLevel. GIF 프레임 축소 레벨입니다. 기본값은 .highLevel입니다.
    ///    - animationOnReady: A closure that takes in a UIImage and returns nothing, which will be called when the animation is ready. UIImage를 받아들이고 반환하지 않는 클로저입니다. 애니메이션이 준비되면 호출됩니다.
    internal func getGIFImageWithUIImage(cacheKey: String,
                                         level: GIFOFrameReduceLevel = .highLevel,
                                         animationOnReady: @escaping (UIImage) -> Void) {
        self.cacheKey = cacheKey
        guard let imageSource = self.imageSource else {
            return
        }
        
        let frames = convertCGImageSourceToUIImageArray(imageSource)
        let levelFrames = getLevelFrameWithUIImage(level: level, frames: frames)
        
        guard let animatedImage = UIImage.animatedImage(with: levelFrames,
                                                        duration: self.animationTotalDuration) else { return }
        
        GIFOImageCacheManager.shared.addGIFUIImage(image: animatedImage,
                                                   forKey: cacheKey)
        
        animationOnReady(animatedImage)
    }
    
    /// This function sets up cached image frames with GIFOFrame.
    /// 이 함수는 GIFOFrame를 사용하여 캐시된 이미지 프레임을 설정합니다.
    ///
    /// - Parameters:
    ///    - cacheKey: The key of the cache for the GIF image. GIF 이미지의 캐시 키입니다.
    ///    - level: The level of GIF frame reduction, with a default value of .highLevel. GIF 프레임 축소 레벨입니다. 기본값은 .highLevel입니다.
    ///    - animationOnReady: A closure that is called after setting up the frames. 프레임 설정 후 호출되는 클로저입니다.
    internal func setupCachedImageFramesWithGIFOFrame(cacheKey: String,
                                                      level: GIFOFrameReduceLevel = .highLevel,
                                                      animationOnReady: @escaping () -> Void) {
        do {
            guard let cgImages = try GIFOImageCacheManager.shared.getGIFImages(forKey: cacheKey) else {
                print("Error: Image Not Found")
                return
            }
            animationGIFOFrames = cgImages
            totalFrameCount = cgImages.count
            animationOnReady()
        } catch {
            print("Error: Image Not Found")
        }
    }
    
    /// This function adjusts the GIFOFrame according to the GIFOFrameReduceLevel and returns a new array of GIFOFrame.
    /// 이 함수는 GIFFrameReduceLevel에 따라 GIFOFrame을 조정하여 새로운 GIFOFrame 배열을 반환합니다.
    ///
    /// - Parameters:
    ///    - level: The level of GIF Frame reduction.  GIF 프레임 감소 수준을 나타내는 값입니다.
    ///    - frames: This is an array of GIF Images to reduce the number of images. 이미지 수를 줄이기 위한 GIF 이미지 배열입니다.
    /// - returns : This is an array of images that were calculated according to the level of the number of frames. 프레임 수 줄이기 레벨에 따라 계산된 이미지 배열입니다.
    private func getLevelFrameWithGIFOFrame(level: GIFOFrameReduceLevel,
                                            frames: [GIFOFrame]) -> [GIFOFrame] {
        switch level {
        case .highLevel:
            return frames
        case .middleLevel:
            return reduceFramesWithGIFOFrame(GIFFrames: frames, level: 2)
        case .lowLevel:
            return reduceFramesWithGIFOFrame(GIFFrames: frames, level: 3)
        }
    }
    
    /// This function adjusts the UIImage array according to the GIFOFrameReduceLevel and returns a new array of UIImage.
    /// 이 함수는 GIFFrameReduceLevel에 따라 UIImage 배열을 조정하여 새로운 UIImage 배열을 반환합니다.
    ///
    /// - Parameters:
    ///    - level: The level of GIF UIImages reduction.  GIF UIImage 감소 수준을 나타내는 값입니다.
    ///    - frames: This is an array of GIF Images to reduce the number of images. 이미지 수를 줄이기 위한 GIF 이미지 배열입니다.
    /// - returns : This is an array of images that were calculated according to the level of the number of frames. 프레임 수 줄이기 레벨에 따라 계산된 이미지 배열입니다.
    private func getLevelFrameWithUIImage(level: GIFOFrameReduceLevel,
                                          frames: [UIImage]) -> [UIImage] {
        switch level {
        case .highLevel:
            return frames
        case .middleLevel:
            return reduceFramesWithUIImage(GIFFrames: frames, level: 2)
        case .lowLevel:
            return reduceFramesWithUIImage(GIFFrames: frames, level: 3)
        }
    }
    
    /// This function takes in a CGImageSource and returns an array of GIFOFrame objects.
    /// 이 함수는 CGImageSource를 가져와 GIFOFrame 객체 배열을 반환합니다.
    ///
    /// - Parameters:
    ///    - source: source is a CGImageSource object that represents the image containing each frame in the GIF file. GIF 파일에서 각 프레임을 포함하는 이미지를 나타내는 CGImageSource 객체입니다.
    /// - returns : The return value is an array of GIFOFrame objects that are created by extracting GIF frames from the CGImageSource. CGImageSource에서 GIF 프레임을 추출하여 생성된 GIFOFrame 객체의 배열입니다.
    private func convertCGImageSourceToGIFOFrameArray(source: CGImageSource) -> [GIFOFrame] {
        let frameCount = CGImageSourceGetCount(source)
        var frameProperties: [GIFOFrame] = []
        
        for i in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                return []
            }
            
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any] else {
                return []
            }
            
            if self.imageSize != nil {
                guard let resizeImage = resize(source,i) else { return [] }
                
                frameProperties.append(
                    GIFOFrame(image: resizeImage,
                              duration: applyMinimumDelayTime(properties))
                )
            } else {
                frameProperties.append(
                    GIFOFrame(image: image,
                              duration: applyMinimumDelayTime(properties))
                )
            }
        }
        
        return frameProperties
    }
    
    /// This function takes in a CGImageSource and returns an array of UIImage objects.
    /// 이 함수는 CGImageSource를 가져와 UIImage 객체 배열을 반환합니다.
    ///
    /// - Parameters:
    ///    - source: source is a CGImageSource object that represents the image containing each frame in the GIF file. GIF 파일에서 각 프레임을 포함하는 이미지를 나타내는 CGImageSource 객체입니다.
    /// - returns : The return value is an array of UIImage objects that are created by extracting GIF frames from the CGImageSource. CGImageSource에서 GIF 프레임을 추출하여 생성된 UIImage 객체의 배열입니다.
    private func convertCGImageSourceToUIImageArray(_ source: CGImageSource) -> [UIImage] {
        let frameCount = CGImageSourceGetCount(source)
        var frameProperties: [UIImage] = []
        
        for i in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                return []
            }
            
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any] else {
                return []
            }
            
            if self.imageSize != nil {
                guard let resizeImage = resize(source,i) else { return [] }
                frameProperties.append(UIImage(cgImage: resizeImage))
            } else {
                frameProperties.append(UIImage(cgImage: image))
            }
            
            frameDurations.append(applyMinimumDelayTime(properties))
            animationTotalDuration += applyMinimumDelayTime(properties)
        }
        
        return frameProperties
    }
    
    /// This function determines the minimum delay time for each GIF frame.
    /// 이 함수는 각 GIF 프레임의 최소 딜레이 시간을 결정합니다.
    ///
    /// - Parameters:
    ///    - properties: This is a dictionary-formatted data for a single frame extracted from CGImageSource. CGImageSource에서 추출 된 단일 프레임에 대한 딕셔너리 형식의 데이터입니다.
    /// - returns : This is the minimum Duration value for a frame extracted from CGImageSource. CGImageSource에서 추출 된 프레임의 Duration 최소 값입니다.
    private func applyMinimumDelayTime(_ properties: [String: Any]) -> Double {
        var duration = 0.0
        
        if let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
            duration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0.1
        }
        
        if duration <= 0 {
            return 0.1
        }
        
        return duration
    }
    
    /// This function reduces the number of frames with GIFOFrame
    /// 이 함수는 GIFOFrame 배열의 수를 줄입니다.
    ///
    /// - Parameters:
    ///    - GIFFrames: GIFFrames is an array of GIFOFrame objects that represents the frames of a GIF image. GIF 이미지의 프레임을 나타내는 GIFOFrame 객체의 배열입니다.
    ///    - level: The level of GIF Frame reduction.  GIF 프레임 감소 수준을 나타내는 값입니다.
    /// - returns : This is an array of GIFOFrame objects that has reduced the number of frames according to the level. 레벨에 맞춰 수를 줄인 GIFOFrame 배열입니다.
    private func reduceFramesWithGIFOFrame(GIFFrames: [GIFOFrame],
                                           level: Int) -> [GIFOFrame] {
        let frameCount = GIFFrames.count
        let reducedFrameCount = max(frameCount/level, 1)
        
        var reducedFrameProperties: [GIFOFrame] = []
        
        for i in 0..<reducedFrameCount {
            var gifFrame = GIFOFrame.empty
            
            let originalFrameIndex = i * level

            gifFrame.image = GIFFrames[originalFrameIndex].image
            gifFrame.duration = GIFFrames[originalFrameIndex].duration * Double(level)
            
            reducedFrameProperties.append(gifFrame)
        }
        
        totalFrameCount = reducedFrameProperties.count
        
        return reducedFrameProperties
    }
    
    /// This function reduces the number of frames with UIImage.
    /// 이 함수는 UIImage 배열의 수를 줄입니다.
    ///
    /// - Parameters:
    ///    - GIFFrames: GIF Frames is an array of UIImage objects that represents the frames of a GIF image. GIF 이미지의 프레임을 나타내는 UIImage 객체의 배열입니다.
    ///    - level: The level of GIF Frame reduction.  GIF 프레임 감소 수준을 나타내는 값입니다.
    /// - returns : This is an array of UIImage objects that has reduced the number of frames according to the level. 레벨에 맞춰 수를 줄인 UIImage 배열입니다.
    private func reduceFramesWithUIImage(GIFFrames: [UIImage],
                                         level: Int) -> [UIImage] {
        let frameCount = GIFFrames.count
        let reducedFrameCount = max(frameCount/level, 1)
        
        var reducedFrames: [UIImage] = []
        var reducedFrameDurations: [Double] = []
        
        for i in 0..<reducedFrameCount {
            let originalFrameIndex = i * level
            let frameDuration = self.frameDurations[originalFrameIndex]

            reducedFrameDurations.append(frameDuration * Double(level))
            reducedFrames.append(GIFFrames[originalFrameIndex])
        }
        
        totalFrameCount = reducedFrameCount
        frameDurations = reducedFrameDurations
        
        return reducedFrames
    }
    
    /// This function reduces the size of the image to decrease memory usage.
    /// 이 함수는 메모리 사용량을 줄이기 위해 이미지 크기를 줄이는 데 사용됩니다.
    ///
    /// - Parameters:
    ///    - source: The source is used to specify the source of the image. 이미지의 소스를 지정하는 데 사용됩니다.
    ///    - index: The index is used to specify the index of the image in the image source. 이미지 소스에서 이미지의 인덱스를 지정하는 데 사용됩니다.
    ///    - cgImage: The cgImage is used to specify the original CGImage object that needs to be resized. 크기를 조정해야 하는 원래 CGImage 객체를 지정하는 데 사용됩니다.
    /// - returns : This is a CGImage object that has been resized. 크기가 조정된 CGImage 객체입니다.
    private func resize(_ source: CGImageSource,
                        _ index: Int) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(Int((self.imageSize?.width)!),
                                                     Int((self.imageSize?.height)!))
        ]
        
        guard let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary) else {
            return nil
        }
        
        return thumbnailImage
    }
}
