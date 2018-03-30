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
        return CGSize(width: 256, height: 256)
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

/*
#import "VMRPacketView.h"
#import "VMRPacketViewController.h"
//#import "VMRPacket.h"
#import "ViewMasterSwift-Swift.h"

@implementation VMRPacketView

// The preferred size of this view is the size of the packet background image.
+ (CGSize)preferredViewSize
{
    return CGSizeMake(256,256);
}

// Inittialize the view, calling super and setting the properties to nil.
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        // Initialization code:
        _packet = nil;
        _viewController = nil;
        
        // Set the background color of the view to clear
        self.backgroundColor = [UIColor clearColor];
        
        // Attach a tap gesture recognizer to this view so that it can flip.
        UITapGestureRecognizer *tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

// Yes, this view can become first responder.
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// When a tap gesture occurs, tell the view controller to flip this view to the back,
//    displaying the back of the packet.
- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    [self.viewController flipCurrentView];
}


//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
    // Drawing code
//}


// Get the image for the packet and draw it.
- (void)drawRect:(CGRect)rect
{
    UIImage *packetImage = [self.packet imageForPacketFrontView];
    CGRect packetImageRectangle = CGRectMake(0, 0, [packetImage size].width, [packetImage size].height);
    [packetImage drawInRect:packetImageRectangle];
}

// [Very mysterious: Is this a C function?]
// Create a gradient image.
CGImageRef AEViewCreateGradientImage (int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    CGContextRef gradientBitmapContext = NULL;
    CGColorSpaceRef colorSpace;
    CGGradientRef grayScaleGradient;
    CGPoint gradientStartPoint, gradientEndPoint;

    // "Our gradient is always black-white and the mask must be in the gray colorspace."
    colorSpace = CGColorSpaceCreateDeviceGray();
    
    // "Create the bitmap context."
    gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0,
                                                  colorSpace, kCGImageAlphaNone);
    
    if (gradientBitmapContext != NULL) {
        // "Define the start and end grayscale values (with the alpha, even though
        //  our bitmap context doesn't support alpha, the gradient requires it)."
        CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
        
        // "Create the CGGradient and then release the gray color space."
        grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        
        // "Create the start and end points for the gradient vector (straight down)."
        gradientStartPoint = CGPointZero;
        gradientEndPoint = CGPointMake(0, pixelsHigh);
        
        // "Draw the gradient into the gray bitmap context."
        CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
        // "Clean up the gradient."
        CGGradientRelease(grayScaleGradient);
        
        // "Convert the context into a a CGImageRef and release the context."
        theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
        CGContextRelease(gradientBitmapContext);
    }
    
    // "Clean up the colorspace."
    CGColorSpaceRelease(colorSpace);
    
    // "Return the imageref containing the gradient."
    return theCGImage;
}

// Create a reflected image.
// [Copied and pasted, without change, from TheElements.]
- (UIImage *)reflectedImageRepresentationWithHeight:(NSInteger)height {
    
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, self.bounds.size.width,height, 8,0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext == NULL)
        return NULL;
    
    // offset the context. This is necessary because, by default, the layer created by a view for
    // caching its content is flipped. But when you actually access the layer content and have
    // it rendered it is inverted. Since we're only creating a context the size of our
    // reflection view (a fraction of the size of the main view) we have to translate the context the
    // delta in size, render it, and then translate back
    
    CGFloat translateVertical = self.bounds.size.height-height;
    CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
    
    // render the layer into the bitmap context
    [self.layer renderInContext:mainViewContentContext];
    
    // translate the context back
    CGContextTranslateCTM(mainViewContentContext, 0, translateVertical);
    
    // Create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = AEViewCreateGradientImage(1, height);
    
    // Create an image by masking the bitmap of the mainView content with the gradient view
    // then release the pre-masked content bitmap and the gradient bitmap
    CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
    CGImageRelease(mainViewContentBitmapContext);
    CGImageRelease(gradientMaskImage);
    
    // convert the finished reflection image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    CGImageRelease(reflectionImage);
    
    return theImage;
}

@end
*/
