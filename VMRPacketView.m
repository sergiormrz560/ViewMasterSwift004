//
//  VMRPacketView.m
//  ViewMaster
//
//  Created by Robert England on 3/12/15.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Abstract: Displays the packet information in a large format tile.
//

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
