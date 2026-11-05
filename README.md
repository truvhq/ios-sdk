# TruvSDK

## Requirements

iOS 15.0 or later.

### Installation

The TruvSDK is available via [Swift Package Manager](https://swift.org/package-manager/). Add `https://github.com/truvhq/ios-sdk` as a package dependency.

### TruvBridgeView

The TruvBridgeView is a `UIView` that you can integrate into your app's flow like so:

```swift
import TruvSDK

let truvBridgeView = TruvBridgeView(token: token, delegate: self)
view.addSubview(truvBridgeView)
// add constraints if needed
```

With the `TruvBridgeView`, end-users can select their employer, authenticate with their payroll platform login credentials, and authorize the direct deposit change. Throughout the process, different events will be emitted to the delegate `func onEvent(_ event: TruvEvent)` method.

## TruvDelegate

The `TruvDelegate` protocol is set up such that every event goes through the required `func onEvent(_ event: TruvEvent)` handler.   
See the [events page](https://docs.truv.com/developers/sdks/bridge-events) of the documentation for more details.
