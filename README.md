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
GIFO uses an `Animator` with CADisplayLink and a `frameFactory` to implement GIF animation. The GIF data is passed to the `frameFactory`, which creates multiple frames. The `Animator` updates the image at a set timing for each frame according to the device's environment, allowing the GIF animation to be displayed.
<br/>
## Usage
GIFO implements GIF animation in two ways:

#### UIImage.animatedImage
~~~Swift
@available(iOS 5.0, *)
open class func animatedImage(with images: [UIImage], duration: TimeInterval) -> UIImage?
~~~

<img src = "https://user-images.githubusercontent.com/73861795/211813537-14e1f41b-2c61-4832-bd74-0390a24be38b.gif" width="231" height="500"/>

- The first method uses UIImage.animatedImages to create an animation using multiple GIFs, which is useful in environments where multiple GIFs need to be used.

<br/>

#### CADisplayLink
~~~Swift
@available(iOS 3.1, *)
open class CADisplayLink : NSObject { ... }
~~~

<img src = "https://user-images.githubusercontent.com/73861795/211813909-371ff687-5169-4dd1-8383-e3ac1cf44219.gif" width="231" height="500"/>

- The second method uses CADisplayLink to display high-quality GIFs. This method is used when displaying high-quality GIFs is a priority.

<br/>

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

<br/>

#### UIImage.animatedImage - clear
~~~Swift
imageView.clearWithUIImage()
~~~

<br/>

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

<br/>

#### CADisplayLink - Animation Start / Stop
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
- Xcode
