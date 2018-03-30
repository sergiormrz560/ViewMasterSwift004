//
//  VMRPacketViewController.m
//  ViewMaster
//
//  Created by Robert England on 3/12/15.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Abstract: Controller that manages the full size tile view of the packet,
//     including creating the reflection and flipping the tile.
//
/*
#define WHERE_AM_I   NSLog(@"%s", __PRETTY_FUNCTION__);

// [Need this include to access custom Swift classes]
#import "ViewMasterSwift-Swift.h"
#import "VMRPacketViewController.h"
#import "VMRPacketView.h"
#import "VMRPacketFlippedView.h"
//#import "VMRPacket.h"

#define kFlipTransitionDuration 0.75
#define reflectionFraction 0.35
#define reflectionOpacity 0.5

@interface VMRPacketViewController ()

@property (assign) BOOL frontViewIsVisible;
@property (nonatomic, strong) VMRPacketView *packetView;
@property (nonatomic, strong) UIImageView *reflectionView;
@property (nonatomic, strong) VMRPacketFlippedView *packetFlippedView;
@property (nonatomic, strong) UIButton *flipIndicatorButton;

@property (nonatomic, strong) UIButton *ebayButton;

@end

#pragma mark -

@implementation VMRPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.frontViewIsVisible = YES;
    CGSize preferredPacketViewSize = [VMRPacketView preferredViewSize];
    CGRect viewRect = CGRectMake((CGRectGetWidth(self.view.bounds) - preferredPacketViewSize.width)/2,
                                 (CGRectGetHeight(self.view.bounds) - preferredPacketViewSize.height)/2 - 5,
                                 preferredPacketViewSize.width,
                                 preferredPacketViewSize.height);

    // Take a shot at setting up the eBay button.
    [self setupUserInterface];

    // Create the packet view.
    VMRPacketView *tempPacketView = [[VMRPacketView alloc] initWithFrame:viewRect];
    self.packetView = tempPacketView;
    
    // Add the packet view to the view controller's view.
    // Tell the packet view who its controller is.
    self.packetView.packet = self.myPacket;
    self.packetView.viewController = self;
    [self.view addSubview:self.packetView];
    
    // Create the packet flipped view.
    VMRPacketFlippedView *tempPacketFlippedView = [[VMRPacketFlippedView alloc] initWithFrame:viewRect];
    self.packetFlippedView = tempPacketFlippedView;
    
    self.packetFlippedView.packet = self.myPacket;
    self.packetFlippedView.viewController = self;
    //// (Note: flipped view won't be added as a subview until user flips)
    
    // Create the reflection view.
    CGRect reflectionRect = viewRect;
    
    // The reflection view is a fraction of the size of the original view begin reflected,
    // and it is offset to be at the bottom of the view being reflected.
    reflectionRect.size.height = CGRectGetHeight(reflectionRect) * reflectionFraction;
    reflectionRect = CGRectOffset(reflectionRect, 0, CGRectGetHeight(viewRect));
    UIImageView *tempReflectionImageView = [[UIImageView alloc] initWithFrame:reflectionRect];
    self.reflectionView = tempReflectionImageView;
    
    // Determine the size of the reflection to create.
    NSUInteger reflectionHeight = CGRectGetHeight(self.packetView.bounds) * reflectionFraction;
    
    // Create the reflection image, assign it to the UIImageView, and add the image view to the view controller's view.
    self.reflectionView.image = [self.packetView reflectedImageRepresentationWithHeight:reflectionHeight];
    self.reflectionView.alpha = reflectionOpacity;
    [self.view addSubview:self.reflectionView];
    
    // Set up the flip indicator button, placed as a nav bar item to the right.
    UIButton *tempFlipIndicator = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    self.flipIndicatorButton = tempFlipIndicator;
    
    // Front view is always visible first.
    [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"FlipBackButton.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *flipButtonBarItem;
    flipButtonBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.flipIndicatorButton];
    [self.flipIndicatorButton addTarget:self
                                 action:@selector(flipCurrentView)
                       forControlEvents:(UIControlEventTouchDown)];
    [self.navigationItem setRightBarButtonItem:flipButtonBarItem animated:YES];
}

// Try to find this packet for sale on eBay.
- (void)jumpToEbay:(id)sender
{
 //   WHERE_AM_I
 //    Separate the words of the packet title.
    NSArray *titleWords = [self.myPacket.title componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,.-'"]];
    
    // (Stold this from eBay search page URL)
    NSMutableString *ebayURLString = [[NSMutableString alloc]
                                      initWithString:@"http://www.ebay.com/sch/Viewmaster-/180125/i.html?_from=R40&ghostText=&_nkw="];
    
    // Incrementally construct the proper eBay search URL.
    BOOL additionalWord = NO;
    for (NSString *s in titleWords) {
        if (s.length != 0) {
            if (additionalWord == YES) {
                [ebayURLString appendString:@"+"];
            }
            [ebayURLString appendString:s];
            additionalWord = YES;
        }
    }
    [ebayURLString appendString:@"&_sac=1#seeAllAnchorLink"];

    // Go there.
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:ebayURLString]])
    {
        // couldn't go there --- do sthg?
    }

 }

- (void)setupUserInterface
{
    //    CGRect buttonFrame = CGRectMake((self.view.bounds.size.width - 120.0) / 2, 410.0, 120.0, 36.0);
        CGRect buttonFrame = CGRectMake(40.0, 60.0, 120.0, 120.0);
//        NSLog(@"self.view's width: %f and height:%f", self.view.bounds.size.width, self.view.bounds.size.height);
    
    // Create the button
    self.ebayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.ebayButton.titleLabel.font = [UIFont systemFontOfSize:20];
    self.ebayButton.frame = buttonFrame;
    
    [self.ebayButton setTitle:@"Find on eBay" forState:UIControlStateNormal];
// Doesn't work:
    //    [self.ebayButton.titleLabel setTextColor:[UIColor yellowColor]];
    

    //// [Copied from doc:]
    UIButton *button                  = [UIButton buttonWithType: UIButtonTypeSystem];
    button.titleLabel.font            = [UIFont systemFontOfSize: 12];
    button.titleLabel.lineBreakMode   = NSLineBreakByTruncatingTail;
    Do not use the label object to set the text color or the shadow color. Instead, use the setTitleColor:forState: and setTitleShadowColor:forState: methods of this class to make those changes.
    /////
    
    // Center the text on the button, considering the button's shadow.
    self.ebayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.ebayButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [self.ebayButton addTarget:self action:@selector(jumpToEbay:) forControlEvents:UIControlEventTouchUpInside];
//    NSLog(@"Set up user interface?");
    [self.view addSubview:self.ebayButton];
}


- (void)flipCurrentView
{
    NSUInteger reflectionHeight;
    UIImage *reflectedImage;
    
    // Disable user interaction during the flip animation.
    self.view.userInteractionEnabled = NO;
    self.flipIndicatorButton.userInteractionEnabled = NO;
    
    // Setup the animation group.
    [UIView beginAnimations:nil context:nil];   //// Start the animation block.
    [UIView setAnimationDuration:kFlipTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    // Here we go: Swap the views and transition.
    if (self.frontViewIsVisible == YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        [self.packetView removeFromSuperview];
        [self.view addSubview:self.packetFlippedView];
        
        // Update the reflection image for the new view.
        reflectionHeight = CGRectGetHeight(self.packetFlippedView.bounds) * reflectionFraction;
        reflectedImage = [self.packetFlippedView reflectedImageRepresentationWithHeight:reflectionHeight];
        _reflectionView.image = reflectedImage;

    } else { //// (flip back to front)
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        [self.packetFlippedView removeFromSuperview];
        [self.view addSubview:self.packetView];
        
        // Update the reflection image for the new view.
        reflectionHeight = CGRectGetHeight(self.packetView.bounds) * reflectionFraction;
        reflectedImage = [self.packetView reflectedImageRepresentationWithHeight:reflectionHeight];
        self.reflectionView.image = reflectedImage;
    }
    [UIView commitAnimations];      //// End the animation block.
    
    // Swap the nav bar button views.
    [UIView beginAnimations:nil context:nil];   //// Start another animation block.
    [UIView setAnimationDuration:kFlipTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    if (self.frontViewIsVisible == YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.flipIndicatorButton cache:YES];
        [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"FlipFrontButton.png"] forState:UIControlStateNormal];
        
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.flipIndicatorButton cache:YES];
        [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"FlipBackButton.png"] forState:UIControlStateNormal];
    }
    [UIView commitAnimations];  //// End the other animation block.
    
    // Toggle the front view state.
    self.frontViewIsVisible = !(self.frontViewIsVisible);
}

// Reenable user interaction when the flip animation has completed.
- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.view.userInteractionEnabled = YES;
    self.flipIndicatorButton.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
*/
