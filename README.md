# GIFO
<img src = "https://user-images.githubusercontent.com/73861795/231753782-a3fa9ef3-40b8-4d46-becb-8c678461f41d.gif" width="320" height="153"/>

GIFO is a GIF library made with UIKit.

<img src="https://img.shields.io/badge/Swift-5.4-orange?style=gor-the-badge&logo=Swift&logoColor=F05138"/> <img src="https://img.shields.io/badge/Platforms-iOS-blue?style=gor-the-badge&logo=&logoColor="/>


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

## How it Works
GIFO uses an `Animator` with CADisplayLink and a `frameFactory` to implement GIF animation. The GIF data is passed to the `frameFactory`, which creates multiple frames. The `Animator` updates the image at a set timing for each frame according to the device's environment, allowing the GIF animation to be displayed.

## Usage

#### UIImage.animatedImage
~~~Swift
@available(iOS 5.0, *)
open class func animatedImage(with images: [UIImage], duration: TimeInterval) -> UIImage?
~~~


#### CADisplayLink
~~~Swift
@available(iOS 3.1, *)
open class CADisplayLink : NSObject { ... }
~~~

## Example Code

#### UIImage.animatedImage - Animation Setup
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

#### UIImage.animatedImage - clear
~~~Swift
imageView.clearWithUIImage()
~~~

#### CADisplayLink - setup
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

#### CADisplayLink - Animation Start / Stop
~~~Swift
imageView.stopAnimationWithDisplayLink() // start GIF Animation
~~~

~~~Swift
imageView.startAnimationWithDisplayLink() // stop GIF Animation
~~~

## Documentation
See the Full API Documentation

## Compatibility
- iOS 9.0+
- Swift 5.4
- Xcode
