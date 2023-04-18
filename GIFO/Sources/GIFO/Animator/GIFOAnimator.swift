//
//  GIFOAnimator.swift
//  GIFO
//
//  Created by BMO on 2023/02/11.
//

import UIKit
import ImageIO

/// This protocol is called when the image of a GIF animation is updated in the `GIFOAnimator` class.
/// `GIFOAnimator` 클래스에서 GIF 애니메이션의 이미지가 업데이트될 때 이 프로토콜이 호출됩니다.
internal protocol GIFOAnimatorImageUpdateDelegate {
    func animationImageUpdate(image: UIImage)
}

/// The `GIFOAnimator` class is responsible for managing and handling GIF animations.
/// `GIFOAnimator` 클래스는 GIF 애니메이션을 관리하고 처리하는 역할을 담당합니다.
internal class GIFOAnimator {
    
    /// The index of the current frame being displayed in the animation.
    /// 현재 애니메이션에서 보여지는 프레임의 인덱스입니다.
    private var currentFrameIndex = 0
    
    /// The time at which the last frame was displayed, in seconds.
    /// 마지막 프레임이 표시된 시간 (초)입니다.
    private var lastFrameTime: TimeInterval = 0.0
    
    /// The number of times the animation should loop. A value of 0 means to loop indefinitely.
    /// 애니메이션을 반복해야 하는 횟수입니다. 0의 값을 가지면 무한 반복합니다.
    private var loopCount: Int = 0
    
    /// The number of loops that have been completed so far.
    /// 지금까지 완료된 루프(loop)의 수를 나타냅니다.
    private var currentLoop: Int = 0
    
    /// An instance of CADisplayLink that manages the timing of the animation.
    /// 해당 애니메이션의 타이밍을 관리하는 CADisplayLink의 인스턴스입니다.
    private var displayLink: CADisplayLink?
    
    /// An instance of GIFOFrameFactory that creates frames for the animation.
    /// GIFOFrameFactory 클래스의 인스턴스로, 애니메이션 프레임을 생성하는 역할을 합니다.
    private var frameFactory: GIFOFrameFactory?
    
    /// Maximum duration to increment the frame timer with.
    /// 프레임 타이머를 증분할 최대 지속 시간입니다.
    private let maxFrameDuration = 1.0
    
    /// A Boolean value that indicates whether the animation is currently paused.
    /// 현재 애니메이션이 일시 중지되어 있는지를 나타내는 부울 값입니다. 추가 업데이트 방지
    internal var isPaused = false
    
    /// An object that conforms to the GIFOAnimatorImageUpdateDelegate protocol, which is notified whenever a new frame is ready to be displayed.
    /// GIFOAnimatorImageUpdateDelegate 프로토콜을 준수하는 객체로, 새로운 프레임을 표시할 준비가 되면 알림을 받는 역할을 합니다.
    internal var delegate: GIFOAnimatorImageUpdateDelegate?
    
    /// This function creates a frameFactory with the provided parameters and requests the frameFactory to set up GIFOFrames.
    /// 이 함수는 주어진 파라미터들로 frameFactory를 생성하고 frameFactory에 GIFOFrame을 setup 요청합니다.
    ///
    /// - Parameters:
    ///    - data: The data of the GIF image. GIF 이미지 데이터입니다.
    ///    - size: The size of the GIF image. GIF 이미지 크기입니다.
    ///    - loopCount: The number of times to repeat the GIF animation. If 0, the animation will repeat indefinitely. GIF 애니메이션을 반복할 횟수입니다. 0이면 애니메이션은 무한 반복됩니다.
    ///    - level: The level of frame reduction for the GIF animation. GIF 애니메이션의 프레임 축소 수준입니다.
    ///    - cacheKey: The key to cache the GIF image data. GIF 이미지 데이터를 캐시하기 위한 키입니다.
    ///    - isCache: A Boolean value indicating whether to cache the GIF image data. GIF 이미지 데이터를 캐시할지 여부를 나타내는 부울 값입니다.
    ///    - animationOnReady: A block to be called when the animation is ready to be played. 애니메이션이 재생 준비가 된 시점에 호출될 블록입니다.
    internal func setupForAnimation(data: Data,
                                    size: CGSize?,
                                    loopCount: Int,
                                    level: GIFOFrameReduceLevel,
                                    cacheKey: String,
                                    isCache: Bool,
                                    animationOnReady: @escaping () -> Void) {
        frameFactory = nil
        frameFactory = GIFOFrameFactory(data: data,
                                        size: size,
                                        isCache: isCache)
        setupDisplayLink()
        self.loopCount = loopCount
        frameFactory?.setupGIFImageFramesWithGIFOFrame(cacheKey: cacheKey,
                                                       level: level,
                                                       animationOnReady: animationOnReady)
    }
    
    /// This function sets up the cached image frames with the provided cache key and calls the given block when the animation is ready to be displayed.
    /// 이 함수는 제공된 캐시 키로 캐시된 이미지 프레임을 설정하고 애니메이션이 재생 준비가 된 시점에서 주어진 블록을 호출합니다.
    ///
    /// - Parameters:
    ///    - cacheKey: The key to cache the image data. 이미지 데이터를 캐시할 키입니다.
    ///    - animationOnReady: A block to be called when the animation is ready. 애니메이션이 준비될 때 호출할 블록입니다.
    internal func setupCachedImages(cacheKey: String,
                                    animationOnReady: @escaping () -> Void) {
        frameFactory?.setupCachedImageFramesWithGIFOFrame(cacheKey: cacheKey) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.setupDisplayLink()
            animationOnReady()
        }
    }
    
    /// This function starts the animation by setting the isPaused property to false and unpausing the displayLink.
    /// 이 함수는 isPaused 속성을 false로 설정하고 displayLink를 다시 시작하여 애니메이션을 시작합니다.
    internal func startAnimation() {
        guard let displayLink = self.displayLink else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = false
            displayLink.isPaused = false
        }
    }
    
    /// This function stops the animation and clears the relevant data in the frame factory.
    /// 이 함수는 애니메이션을 중지하고 프레임 팩토리 내 관련 데이터를 지우는 역할을 합니다.
    internal func clear(completion: @escaping ()->Void) {
        guard let displayLink = self.displayLink else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = true
            displayLink.isPaused = true
            displayLink.invalidate()
            self?.frameFactory?.clearFactoryWithGIFOFrame(completion: completion)
        }
    }
    
    /// This function stops the animation
    /// 이 함수는 애니메이션을 멈춥니다.
    internal func stopAnimation() {
        guard let displayLink = self.displayLink else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = true
            displayLink.isPaused = true
        }
    }
    
    /// This function creates a `CADisplayLink` object.
    /// 이 함수는 CADisplayLink 객체를 생성합니다.
    private func setupDisplayLink() {
        let gifDisplay = CADisplayLink(target: self, selector: #selector(updateFrame))
        gifDisplay.isPaused = true
        gifDisplay.add(to: .main, forMode: .common)
        displayLink = gifDisplay
    }
    
    /// This is a method that updates each frame of an animation using a display link object.
    /// 이 메소드는 displayLink를 사용하여 애니메이션의 각 프레임을 업데이트하는 메소드입니다.
    @objc private func updateFrame() {
        checkIsPaused()
    }
    
    /// This is a function that checks whether the animation is paused or not.
    /// 이 함수는 애니메이션이 일시정지되어 있는지 아닌지를 확인하는 함수입니다.
    private func checkIsPaused() {
        if !isPaused {
            updateLoopCount()
            updateImageWithElapsedTime()
            checkLoopCount()
        }
    }
    
    /// This is a function that updates the current loop count.
    /// 이 함수는 currentFrameIndex값이 frame 전체의 숫자보다 높거나 같으면 현재 루프 횟수를 업데이트하는 기능을 합니다.
    private func updateLoopCount() {
        if currentFrameIndex >= frameTotalCount() {
            currentFrameIndex = 0
            currentLoop += 1
        }
    }
    
    /// This function compares the time of the current frame with the time when the last update was performed, and checks whether to update the current image
    /// 이 함수는 현재 프레임의 시간과 마지막 업데이트가 수행된 시간을 비교하여 현재 이미지를 업데이트할지 여부를 확인합니다.
    /// currentFrameDuration이 lastFrameTime 작거나 같으면 현재 이미지를 업데이트, lastFrameTime을 reset, currentFrameIndex의 값을 +1 해줍니다.
    private func updateImageWithElapsedTime() {
        incrementTimeSinceLastFrameChange()

        if currentFrameDuration() <= lastFrameTime {
            updateCurrentImageToDelegate()
            resetLastFrameTime()
            updateCurrentFrameIndex()
        }
    }
    
    /// This function is responsible for stopping the animation when the current loop count reaches the specified loop count.
    /// 이 함수는 현재 루프 수가 지정된 루프 수에 도달하면 현재 프레임 index를 0로 reset하고 애니메이션을 중지합니다.
    private func checkLoopCount() {
        if loopCount != 0 && currentLoop >= loopCount {
            currentFrameIndex = 0
            stopAnimation()
        }
    }
    
    /// This function updates the current image to the delegate by getting the image from the frame at the current frame index.
    /// 이 함수는 현재 클래스 내 업데이트된 currentImage를 가져와 델리게이트에 업데이트하는 역할을 합니다.
    private func updateCurrentImageToDelegate() {
        delegate?.animationImageUpdate(image: currentImage())
    }
    
    /// This function increments the currentFrameIndex by 1.
    /// 이함수는 currentFrameIndex 를 1 더하기 해줍니다.
    private func updateCurrentFrameIndex() {
        currentFrameIndex += 1
    }
    
    /// Adds the minimum value between maxFrameDuration and displayLinkDuration to lastFrameTime
    /// lastFrameTime에 maxFrameDuration과 displayLinkDuration 중 최소값을 더해줍니다.
    private func incrementTimeSinceLastFrameChange() {
        lastFrameTime += min(maxFrameDuration, displayLinkDuration())
    }
    
    /// Subtracts currentFrameDuration from lastFrameTime
    /// lastFrameTime을 currentFrameDuration으로 뺴줍니다. 리셋됩니다.
    private func resetLastFrameTime() {
        lastFrameTime -= currentFrameDuration()
    }
    
    /// Returns the duration of the current frame, or 0 if the duration cannot be retrieved
    /// 현재 프레임의 지속시간을 반환하며, 지속시간을 가져올 수 없는 경우 0을 반환합니다.
    private func currentFrameDuration() -> TimeInterval {
        if let duration = frameFactory?.animationGIFOFrames[currentFrameIndex].duration {
            return duration
        }
        return 0.0
    }
    
    /// Returns the duration of the display link, or 0 if the duration cannot be retrieved
    /// 디스플레이 링크의 지속 시간을 반환합니다.
    private func displayLinkDuration() -> TimeInterval {
        if let duration = self.displayLink?.duration as? Double {
            return duration
        }
        return 0.0
    }
    
    /// Returns the total number of frames in the animationGIFOFrames array, or 0 if the array is empty
    /// animationGIFOFrames 배열에 있는 총 프레임 수를 반환합니다.
    private func frameTotalCount() -> Int {
        if let frameCount = frameFactory?.animationGIFOFrames.count {
            return frameCount
        }
        return 0
    }
    
    /// Returns the image of the current frame, or an empty UIImage if the image cannot be retrieved
    /// 현재 프레임의 이미지를 반환합니다.
    private func currentImage() -> UIImage {
        if let currentImage = frameFactory?.animationGIFOFrames[currentFrameIndex].image  {
            return currentImage
        }
        return UIImage()
    }
}
