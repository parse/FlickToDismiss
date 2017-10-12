# FlickToDismiss

![FlickToDismiss hero image](FlickToDismiss.gif)

## Why this fork?

- Support for Swift 3+
- Support for zooming in on images

## Requirements

- iOS 9.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate FlickToDismiss into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'FlickToDismiss', '~> 0.9'
```

Then, run the following command:

```bash
$ pod install
```

### Manual

Add [FlickToDismissViewController.swift](Source/FlickToDismissViewController.swift) to your project in Xcode.

## Usage

### Interface Builder

1. Drag a new `UIViewController` object onto your storyboard.
2. Set the class to `FlickToDismissViewController`.
3. Drag a `UIView` object onto the View Controller.
4. Add any necessary constraints.
5. Connect the `flickableView` outlet to the `UIView` in the Connections inspector.
6. Job done.

### Programatically

```swift
let viewToFlick = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 300))
viewToFlick.backgroundColor = .whiteColor()
// Optional - See FlickToDismissOption for available options.
let options: [FlickToDismissOption] = [
.Animation(.Scale),
.BackgroundColor(UIColor(white: 0.0, alpha: 0.8))
]
let vc = FlickToDismissViewController(flickableView: viewToFlick, options: options)
vc.modalTransitionStyle = .CrossDissolve
vc.modalPresentationStyle = .OverFullScreen
presentViewController(vc, animated: true, completion: nil)
```

#### Hint - Subclassing UIView

Since Auto Layout sizes views according to their frames, it incorrectly assumes it has a larger space to lay things out when a view is rotated. To correct this we need to supply the method `alignmentRectForFrame()` in the view subclass:
```swift
override func alignmentRectForFrame(frame: CGRect) -> CGRect {
    return bounds
}
```

## License

FlickToDismiss is licensed under the MIT License. See [LICENSE](LICENSE) for details.

Let me know if you use FlickToDismiss in your projects, I would love to know!
