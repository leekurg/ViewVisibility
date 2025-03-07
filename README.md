# ViewVisibility

Extends `SwiftUI/View` with the `onVisibilityChange(in:scale:perform:)` modifier, allowing you to track 
the "visibility" of a view on the screen and execute an action when its visibility state changes.

## Motivation
When it comes to determining whether a view is "visible" on the screen, the system's `onAppear` 
doesn't always provide reliable results (hello, `TabView`). Additionally, in some cases, it's 
important to know whether a view is fully visible, partially visible (e.g., at least half of its height), 
or completely off-screen. That's why I created `onVisibilityChange(in:scale:perform:)`, which has been 
tested on iOS 16.

## Usage
You provide a rectangle via the `in` parameter to define the area in which visibility should be checked, 
such as `UIScreen.main.bounds`. By default, the system compares the view’s frame against this rectangle, 
but you can modify the frame size using the `scale` parameter. Whenever the view's visibility state 
changes, the `perform(Bool)` closure is triggered.

> [!NOTE]  
> Avoid using this modifier in environments with frequent updates for a large number of views (e.g., `ScrollView`), 
> as it relies on `onGeometryChange()`, which is computed on *every* geometry change.

```swift
ScrollView {
    RoundedRectangle(cornerRadius: 20)
        .frame(width: 200, height: 400)
        .padding(10) // ⚠️ padding will be included in `visibility` rect
        .onVisibilityChange(
            in: UIScreen.main.bounds,
            scale: 0.9
        ) { visible in
            print(visible ? "✅ visible" : "❌ hidden")
        }
}
```
