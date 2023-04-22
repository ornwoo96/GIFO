# GIFO
<img src = "https://user-images.githubusercontent.com/73861795/231753782-a3fa9ef3-40b8-4d46-becb-8c678461f41d.gif" width="320" height="153"/>

GIFO is a GIF library made with UIKit.

<img src="https://img.shields.io/badge/Swift-5.4-orange?style=gor-the-badge&logo=Swift&logoColor=F05138"/> <img src="https://img.shields.io/badge/Platforms-iOS-blue?style=gor-the-badge&logo=&logoColor="/>

<br/>

## Install
Swift Package Manager

Add the following to your `Package.swift` file:
~~~Swift
let package = Package(
    dependencies: [
    .package(url: "https://github.com/ornwoo96/GIFO.git", from: "1.0.0")
    ],
)
~~~

<br/>

## How it Works
GIFO uses an `Animator` with CADisplayLink and a `FrameFactory` to implement GIF animation. The GIF data is passed to the `FrameFactory`, which creates multiple frames. The `Animator` updates the image at a set timing for each frame according to the device's environment, allowing the GIF animation to be displayed.

GIFO 라이브러리는 CADisplayLink를 가지고 있는 `Animator`와 `FrameFactory`로 GIF Animation을 구현하였습니다. 
GIF 데이터는 `FrameFactory`에 전달되어 여러 프레임을 생성합니다.
`Animator`는 기기 환경에 따라 `FrameFactory`에 있는 이미지들를 설정된 타이밍에 업데이트하여 GIF 애니메이션을 보여줍니다. 


<br/>

GIFO implements GIF animation in two ways:

>### UIImage.animatedImage

~~~Swift
@available(iOS 5.0, *)
open class func animatedImage(with images: [UIImage], duration: TimeInterval) -> UIImage?
~~~

<img src = "https://user-images.githubusercontent.com/73861795/211813537-14e1f41b-2c61-4832-bd74-0390a24be38b.gif" width="231" height="500"/>

- The first method uses UIImage.animatedImages to create an animation using multiple GIFs, which is useful in environments where multiple GIFs need to be used.

- 첫 번째 방법은 UIImage.animatedImages를 사용하여 애니메이션을 보여주는 것입니다. 이는 여러 개의 GIF를 사용해야 하는 환경에서 유용합니다.

<br/>

>### CADisplayLink

~~~Swift
@available(iOS 3.1, *)
open class CADisplayLink : NSObject { ... }
~~~

<img src = "https://user-images.githubusercontent.com/73861795/211813909-371ff687-5169-4dd1-8383-e3ac1cf44219.gif" width="231" height="500"/>

- The second method uses CADisplayLink to display high-quality GIFs. This method is used when displaying high-quality GIFs is a priority.

- 두 번째 방법은 CADisplayLink를 사용하여 고품질 GIF를 표시합니다. 이 방법은 고품질 GIF 표시가 우선 순위인 경우에 사용됩니다.

<br/>

## Example Code

>### UIImage.animatedImage - Animation Setup
~~~Swift
let imageView = GIFOImageView()

imageView.setupGIFImageWithUIImage(url: ImageURL,
                                   cacheKey: CacheKey,
                                   isCache: true,
		                   resize: CGSize(width: 100, height: 100),
		                   level: GIFFrameReduceLevel = .highLevel) {
	// animation autoplay Infinity
}
~~~

- The setupGIFImageWithUIImage function can reduce the number of frames by level and reduce data by resizing. The animation of this function cannot be stopped or started at will. The animation will automatically start as soon as the setup is complete.

- setupGIFImageWithUIImage 함수는 레벨에 따라 프레임 수를 줄이고 크기를 조정하여 데이터를 줄일 수 있습니다. 이 함수의 애니메이션은 원하는 대로 중지하거나 시작할 수 없습니다. 설정이 완료되면 애니메이션은 자동으로 시작됩니다.

<br/>

>### UIImage.animatedImage - clear
~~~Swift
imageView.clearWithUIImage()
~~~

<br/>

>### CADisplayLink - setup
~~~Swift
let imageView = GIFOImageView()

imageView.setupGIFImageWithDisplayLink(url: ImageURL,
                                       cacheKey: CacheKey,
                                       isCache: true,
		                       resize: CGSize(width: 100, height: 100),
		                       loopCount: Int = 0, // 0 == Infinity
		                       level: GIFFrameReduceLevel = .highLevel) {
	// animation autoplay
}
~~~

- The setupGIFImageWithDisplayLink function also uses level and resize to reduce the number of frames, and additionally allows setting the number of animation loops with loopCount. Like the setupGIFImageWithUIImage function, it also automatically starts the animation upon setup.

- setupGIFImageWithDisplayLink 함수는 level과 resize를 사용하여 프레임 수를 줄이는 것 외에도 loopCount를 사용하여 애니메이션 루프 수를 설정할 수 있습니다. UIImage로 구성된 애니메이션과 마찬가지로 설정이 완료되면 애니메이션은 자동으로 시작됩니다.

<br/>

>### CADisplayLink - Animation Start / Stop
~~~Swift
imageView.stopAnimationWithDisplayLink() // start GIF Animation
~~~

~~~Swift
imageView.startAnimationWithDisplayLink() // stop GIF Animation
~~~

<br/>

## Documentation
See the Full API Documentation

<br/>

## Compatibility
- iOS 9.0+
- Swift 5.4
- Xcode 12.5
