//
//  VMRPacketView.swift (formerly VMRPacketView.m)
//  ViewMaster
//
//  Created by Robert England on 3/11/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Abstract: Displays the packet information in a large format tile.
//

import UIKit

@objc(VMRPacketView)
class VMRPacketView: UIView {
    
    var packet: VMRPacket?
    weak var viewController: VMRPacketViewController?
    
    // the preferred size of this view is the size of the packet background image
    class func preferredViewSize() -> CGSize {
        return CGSize(width: 525, height: 525)
    }
    
    // initialize the view, calling super and setting the properties to nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // initialization code:
        packet = nil
        viewController = nil

        // set the background color of the view to clear
        self.backgroundColor = UIColor.clear
        
        // attach a tap gesture recognizer to this view so that it can flip
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VMRPacketView.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // yes, this view can become first responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func tapAction(_ gestureRecognizer: UIGestureRecognizer) {
        
        // when a tap gesture occurs, tell the view controller to flip this view to the
        //  back, and show the VMRPacketFlippedView instead
        self.viewController?.flipCurrentView()
    }
    
    override func draw(_ rect: CGRect) {
        let packetImage = self.packet?.imageForPacketFrontView()
        let packetImageRectangle = CGRect(x: 0, y:0, width: (packetImage?.size.width)!, height: (packetImage?.size.height)!)
        packetImage?.draw(in: packetImageRectangle)
    }
    
    //// RE:: lifted verbatim from Swift translation of The Elements --- I don't understand any of it
    private func AEViewCreateGradientImage(_ pixelsWide: Int, _ pixelsHigh: Int) -> CGImage? {
        
        var theCGImage: CGImage? = nil
        
        // our gradient is always black-white and the mask must be in the gray colorspace
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        // create the bitmap context
        //// (wasn't bitsPerComponent 0 is example?!)
        if let gradientBitmapContext = CGContext(data: nil, width: pixelsWide, height: pixelsHigh,
                                                 bitsPerComponent: 8, bytesPerRow: 0,
                                                 space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) {
            
            // define the start and end grayscale values (with the alpha, even though our bitmap context
            //    doesn't support alpha, the gradient requires it)
            let colors: [CGFloat] = [0.0, 1.0, 1.0, 1.0]
            
            // create the CGGradient and then release the gray color space
            let grayScaleGradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: nil, count: 2)
            
            // create the start and end points for the gradient vector (straight down)
            let gradientStartPoint = CGPoint.zero
            let gradientEndPoint = CGPoint(x: 0, y: CGFloat(pixelsHigh))
            
            // draw the gradient into the gray bitmap context
            gradientBitmapContext.drawLinearGradient (grayScaleGradient!, start: gradientStartPoint, end: gradientEndPoint,
                                                      options: CGGradientDrawingOptions.drawsAfterEndLocation)
            
            // clean up the gradient   (RE:: ??)
            
            // convert the context into a CGImageRef and release the context
            theCGImage = gradientBitmapContext.makeImage()
            
        }
        else {
            print("CCC")
        }
        
        // clean up the colorspace   (RE:: ??)
        
        // return the imageRef containing the gradient
        return theCGImage
    }

    //// RE:: also lifted verbatim from Swift translation of The Elements --- I don't understand any of it
    func reflectedImageRepresentationWithHeight(_ height: Int) -> UIImage? {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // create a bitmap graphics context the size of the image
        guard let mainViewContentContext = CGContext(data: nil, width: Int(self.bounds.size.width), height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            
            // free the rgb colorspace
            
            return nil
        }
        
        // offset the context. This is necessary because, by default, the layer created by a view for
        // caching its content is flipped. But when you actually access the layer content and have
        // it rendered it is inverted. Since we're only creating a context the size of our
        // reflection view (a fraction of the size of the main view) we have to translate the context the
        // delta in size, render it, and then translate back
        
        let translateVertical = self.bounds.size.height - CGFloat(height)
        mainViewContentContext.translateBy(x: 0, y: -translateVertical)
        
        // render the layer into the bitmap context
        self.layer.render(in: mainViewContentContext)
        
        // translate the context back
        mainViewContentContext.translateBy(x: 0, y: translateVertical)
        
        // Create CGImageRef of the main view bitmap content, and then release that bitmap context
        let mainViewContentBitmapContext = mainViewContentContext.makeImage()
        if mainViewContentBitmapContext != nil {
            // print("it ain't mainViewContentBitmapContext")
        }
        
        // create a 2 bit CGImage containing a gradient that will be used for masking the
        // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
        // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
        let gradientMaskImage = AEViewCreateGradientImage(1, height)
        if gradientMaskImage != nil {
            // print("it ain't gradientMaskImage")
        }
        else {
            // print("yikes gradientmaskiMAGE")
            return nil
        }
        
        // Create an image by masking the bitmap of the mainView content with the gradient view
        // then release the pre-masked content bitmap and the gradient bitmap
//        let reflectionImage = mainViewContentBitmapContext?.masking(gradientMaskImage!)!
        let reflectionImage = mainViewContentBitmapContext?.masking((gradientMaskImage)!)
        
        // convert the finished reflection image to a UIImage
        let theImage = UIImage(cgImage: reflectionImage!)
        
        return theImage
    }
    
}

