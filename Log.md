# Log 28/03/2022

## Progress
 - Now have ability to access 112\*112 mask each ARGB pixel generated from MobileNet V2
 - And sucessfully create an hand mask, but have some problem
 - Realization on CIImage, CGImage and CVPixelBuffer

:::info
#### CIImage: 
- Can applying certain filter to produce an UIImage
- Does not contain any info about Image raw data
- Cooperation with other Core Image class (e.g. CIFilter, CIContext, CIVector, CIColor)
> *" Although a CIImage object has image data associated with it, it is not an image. You can think of a CIImage object as an image “recipe.” A CIImage object has all the information necessary to produce an image "*
:::


[CVPixelBuffer的創建數據填充以及數據讀取](https://www.zendei.com/article/36867.html)

[Swift-技巧（八）CVPixelBuffer To CGImage](https://www.gushiciku.cn/pl/a2fk/zh-tw)

[Video Toolbox：读写解码回调函数CVImageBufferRef的YUV图像](https://www.cxyzjd.com/article/weixin_34148508/86083668)


[Resize a CVPixelBuffer](https://stackoverflow.com/questions/44509385/resize-a-cvpixelbuffer)



## Encounter Problems
 1. **ARViewController :: startDetection()**
     Dispatch Queue configuration let **self.handMaskBuffer** remain **nil** before entering **startRendering()**, this cause unable to show preview
     
 2. **ARViewController :: startRendering()**
     Unable access camera CVPixelBuffer, the reason is this image is on [**YUV 8-bit 4:2:0**](https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers/kcvpixelformattype_420ypcbcr8biplanarfullrange) format rather than ARGB, in this type color model, 1 pixel ~= 1.502 byte in average, method base on byte-wise access to rendering is invalid
     
 3. **Mask cannot fit camera preview hand contour**
     Suspection on mask size isn't fit cmaera preview size
     > For CoreMl, the input frame, camera CVPixelBuffer, has a unexpectable size w \* h = 1920 \* 1440, which isn't fit iPhone11 screan size 1792 \* 828, so we can assume the output mask 112 \* 112 has to seen 1920 \* 1440 as reference

## Future Plan
 - Not to deep dive into YUV rendering, try anothar way
 - One alternative plan is directely capture the frame which has adding an hand contour mask, do mirror transformation and add on top of **self.view** by calling **addSubview()** method
 - Make sure the black region of this hand contour mask image is ***alpha = 0***, means those pixels are transparent, would not cover **self.view** preview
 - Prepare add hand joint rendering we have done in last semester (**see git branch: Reconstruct_3D**)

1. Solve **Encounter Problems [1], [3]**, specially [3]
2. Check hand contour mask image can be used to be a subview and would not bolck origin **self.view** preview

:::info
**self.view** in **ARViewController :: loadView()**
This property represents the root view of the view controller's view hierarchy. The default value of this property is nil.
:::


