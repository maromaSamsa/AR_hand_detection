# Log May 9, 2022
---

## Progress
 - Now we can set ARSCNView as the main view
 - Fixed problem: mirror hand size isn't fit the main view
 - Find: coordinates of bounds will transform if you set non-identity transform

## future progress

### topic on performance
 - to hand mask, use CAlayer to render instead of UIImage view
 
### Auto layout
To develop headset view (cardboard) in the future, the following layout problem should be clarified: 
 - Relationship between frame and bounds coordinates
 - Relationship between bounds and content mode

### Transformation formula
For developing cardboard mode in the future:
 - Barrel Distortion implementation

### New Feature
 - Hand motion detection
 - Hand skeleton rendering
 - Virtual object placing using ARTag
 
## Document
---
The following scripts are recommended to read

1. [CALayer](https://developer.apple.com/documentation/quartzcore/calayer):
    this class is used for rendering a view, and also is the main subclass under UIView class for illustration
> CALayer 提供較底層的 APIs ，讓開發者能更彈性的做出自己想要的功能
> CALayer 的存在，使得iOS可以快速且輕易在應用程式的 View 層次結構中抓取 bitmap 資訊
> 丟給 Core Graphics 進行下一步作業，最終由 OpenGL 處理後呈現至裝置螢幕上
    
2. [Auto layout](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/index.html)
    also the concept of frame, bounds, and content mode in UIView

