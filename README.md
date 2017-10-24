# ARKit-Demo
ARKit-Demo project is an example for how to create your space using ARKit.

<img src="./Asset/art.png?raw=true">

## Preview
<img src="./Asset/preview.png?raw=true">

<img src="./Asset/preview2.gif?raw=true">

## Installation

### Compatibility

-  iOS 11.0+
- iPhone 6s or Later
- ARKit Requires iPhone or iPad with an A9 processor or later is compatible to run apps.

- Xcode 9.0+, Swift 4+



## Usage
1) To place object Virtual Object mangaer will helps to handle to place object
```swift
 virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
```
2) Helps you to capture your AR-World that you created
```swift
 self.arSceneDelegate?.screenShotMethod(target: self)
 ```
 
More usage info can found on the example project.

## Reference
Apple Developer ARKit examples

## Author
iLeaf Solutions
 [http://www.ileafsolutions.com](http://www.ileafsolutions.com)
