//
//  GIFFrameFactory.swift
//  GIFO
//
//  Created by BMO on 2023/03/06.
//

import UIKit

/// The number of GIF frames can be adjusted in three levels.
///
///  - highLevel: the original size.
///  - middleLevel: 2x reduction.
///  - lowLevel: 3x reduction.
public enum GIFFrameReduceLevel {
    case highLevel
    case middleLevel
    case lowLevel
}

/// `GIFOFrameFactory` is a class that manages GIF frames by caching, storing, creating, and resizing them.
internal class GIFOFrameFactory {
    
    /// The CGImage that is being used in the animation.
    private var imageSource: CGImageSource?
    
    /// The size of the image.
    private var imageSize: CGSize?
    
    /// The cache key for the animation frames.
    private var cacheKey: String?
    
    /// The duration of each frame in the animation.
    private var frameDurations: [Double] = []
    
    /// The animation frames should be cached or not.
    private var isCache = true
    
    /// An array of GIFOFrame objects that hold the frames of the animation in GIFO format.
    internal var animationGIFOFrames: [GIFOFrame] = []
    
    /// An array of UIImage objects that hold the frames of the animation in UIImage format.
    internal var animationUIImageFrames: [UIImage] = []
    
    /// The total number of frames in the animation.
    internal var totalFrameCount: Int?
    
    /// The total duration of the animation.
    internal var animationTotalDuration = 0.0
    
    /// This is an initializer for a class that initializes the imageSource, imageSize, isResizing, and isCache properties.
    ///
    /// - Parameters:
    ///    - data: The data of the GIF image.
    ///    - size: The size of the GIF image.
    ///    - isResizing: A Boolean value indicating whether to resize the GIF image.
    ///    - isCache: A Boolean value indicating whether to cache the GIF image data.
    init(data: Data,
         size: CGSize?,
         isCache: Bool = true) {
        let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
        self.imageSource = CGImageSourceCreateWithData(data as CFData, options) ?? CGImageSourceCreateIncremental(options)
        self.imageSize = size
        self.isCache = isCache
    }
    
    /// Release properties related to GIFOFrame.
    internal func clearFactoryWithGIFOFrame(completion: @escaping ()->Void) {
        self.animationGIFOFrames = []
        self.imageSource = nil
        self.totalFrameCount = 0
        self.cacheKey = nil
        self.isCache = true
        completion()
    }
    
    /// Release properties related to UIImage.
    internal func clearFactoryWithUIImage(completion: @escaping ()->Void) {
        self.animationUIImageFrames = []
        self.imageSource = nil
        self.totalFrameCount = 0
        self.animationTotalDuration = 0
        self.cacheKey = nil
        self.frameDurations = []
        completion()
    }
    
    /// This function sets up GIF image frames with GIFOFrame.
    internal func setupGIFImageFramesWithGIFOFrame(cacheKey: String,
                                                   level: GIFFrameReduceLevel = .highLevel,
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
    
    /// This function retrieves the GIF AnimatedImage.
    ///
    /// - Parameters:
    ///    - cacheKey: The key of the cache for the GIF image.
    ///    - level: The level of GIF frame reduction, with a default value of .highLevel.
    ///    - animationOnReady: A closure that takes in a UIImage and returns nothing, which will be called when the animation is ready.
    internal func getGIFImageWithUIImage(cacheKey: String,
                                         level: GIFFrameReduceLevel = .highLevel,
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
    ///
    /// - Parameters:
    ///    - cacheKey: The key of the cache for the GIF image.
    ///    - level: The level of GIF frame reduction, with a default value of .highLevel.
    ///    - animationOnReady: A closure that is called after setting up the frames.
    internal func setupCachedImageFramesWithGIFOFrame(cacheKey: String,
                                                      level: GIFFrameReduceLevel = .highLevel,
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
    
    /// This function retrieves the GIF Frame.
    ///
    /// - Parameters:
    ///    - level: The level of GIF Frame reduction.
    ///    - frames: This is an array of GIF Images to reduce the number of images.
    /// - returns : This is an array of images that were calculated according to the level of the number of frames.
    private func getLevelFrameWithGIFOFrame(level: GIFFrameReduceLevel,
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
    
    /// This function retrieves the GIF UIImages.
    ///
    /// - Parameters:
    ///    - level: The level of GIF UIImages reduction.
    ///    - frames: This is an array of GIF Images to reduce the number of images.
    /// - returns : This is an array of images that were calculated according to the level of the number of frames.
    private func getLevelFrameWithUIImage(level: GIFFrameReduceLevel,
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
    ///
    /// - Parameters:
    ///    - source: source is a CGImageSource object that represents the image containing each frame in the GIF file.
    /// - returns : The return value is an array of GIFOFrame objects that are created by extracting GIF frames from the CGImageSource.
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
                guard let resizeImage = resize(source,i,image) else { return [] }
                
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
    ///
    /// - Parameters:
    ///    - source: source is a CGImageSource object that represents the image containing each frame in the GIF file.
    /// - returns : The return value is an array of UIImage objects that are created by extracting GIF frames from the CGImageSource.
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
                guard let resizeImage = resize(source,i,image) else { return [] }
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
    ///
    /// - Parameters:
    ///    - properties: This is a dictionary-formatted data for a single frame extracted from CGImageSource.
    /// - returns : This is the minimum value for a frame extracted from CGImageSource.
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
    ///
    /// - Parameters:
    ///    - GIFFrames: GIFFrames is an array of GIFOFrame objects that represents the frames of a GIF image.
    ///    - level: The number of frames is reduced by a certain amount.
    /// - returns : The return value is an array of GIFOFrame objects that are created by extracting GIF frames from the CGImageSource.
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
    ///
    /// - Parameters:
    ///    - GIFFrames: GIFFrames is an array of GIFOFrame objects that represents the frames of a GIF image.
    ///    - level: The number of frames is reduced by a certain amount.
    /// - returns : The return value is an array of UIImage objects that are created by extracting GIF frames from the CGImageSource.
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
    ///
    /// - Parameters:
    ///    - source: The source is used to specify the source of the image.
    ///    - index: The index is used to specify the index of the image in the image source
    ///    - cgImage: The cgImage is used to specify the original CGImage object that needs to be resized.
    /// - returns : This is a CGImage object that has been resized.
    private func resize(_ source: CGImageSource,
                        _ index: Int,
                        _ cgImage: CGImage) -> CGImage? {
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
