//
//  VMRPacketViewController.swift   (copied from .m version)
//  ViewMaster
//
//  Created by Robert England on 3/11/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Abstract: Controller that manages the full size tile view of the packet,
//     including creating the reflection and flipping the tile.
//


import UIKit

@objc(VMRPacketViewController)
class VMRPacketViewController: UIViewController {
    
    var myPacket: VMRPacket?
    
    private let kFlipTranslationDuration = 0.75
    private let reflectionFraction: CGFloat = 0.35
    private let reflectionOpacity: CGFloat = 0.5
    
    private var frontViewIsVisible: Bool = true
    private var packetView: VMRPacketView!
    private var reflectionView: UIImageView!
    private var packetFlippedView: VMRPacketFlippedView!
    private var flipIndicatorButton: UIButton!
    
    private var ebayButton: UIButton!
    
    // MARK:  -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black   // RE:: ?
        self.frontViewIsVisible = true
        
        let preferredPacketViewSize = VMRPacketView.preferredViewSize()
        
        let viewRect = CGRect(x: (self.view.bounds.width - preferredPacketViewSize.width)/2,
                              y: (self.view.bounds.height - preferredPacketViewSize.height)/2 - 5,
                              width: preferredPacketViewSize.width,
                              height: preferredPacketViewSize.height)
        
        //// RE:: take a shot at setting up the eBay button
        self.setupUserInterface()
        
        // create the packet view
        let tempPacketView = VMRPacketView(frame: viewRect)
        self.packetView = tempPacketView
        
        // add the packet View to the view controller's interface
        // tell the packet view who its controller is
        self.packetView.packet = self.myPacket
        self.view.addSubview(self.packetView)
        
        self.packetView.viewController = self
        
        // create the packet flipped view
        let tempPacketFlippedView = VMRPacketFlippedView(frame: viewRect)
        self.packetFlippedView = tempPacketFlippedView
        
        self.packetFlippedView.packet = self.myPacket
        self.packetFlippedView.viewController = self
        //// (Note: flipped view won't be added as a subview until user flips)
        
        // create the reflection view
        var reflectionRect = viewRect
        
        // the reflection view is a fraction of the size of the original view being reflected,
        //    and is offset to be at the bottom of the view being reflected
        reflectionRect.size.height = reflectionRect.height * reflectionFraction
        reflectionRect = reflectionRect.offsetBy(dx: 0, dy: viewRect.height)
        
        let tempReflectionImageView = UIImageView(frame: reflectionRect)
        self.reflectionView = tempReflectionImageView
        
        // determine the size of the reflection to create
        let reflectionHeight = Int(self.packetView.bounds.height * reflectionFraction)
        
        // create the reflection image, assign it to the UIImageView and add the image view to the view controller's view
        self.reflectionView.image = self.packetView.reflectedImageRepresentationWithHeight(reflectionHeight)
        self.reflectionView.alpha = reflectionOpacity
        
        self.view.addSubview(self.reflectionView)
        
        // set up the flip indicator button, placed as a nav bar item to the right
        let tempFlipIndicator = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        self.flipIndicatorButton = tempFlipIndicator
        
        // front view is always visible first
        self.flipIndicatorButton.setBackgroundImage(UIImage(named: "FlipBackButton.png"), for: UIControlState())
        
        let flipButtonBarItem = UIBarButtonItem(customView: self.flipIndicatorButton)
        self.flipIndicatorButton.addTarget(self, action: #selector(VMRPacketViewController.flipCurrentView),
                                           for: UIControlEvents.touchDown)
        self.navigationItem.setRightBarButton(flipButtonBarItem, animated: true)
    }
    
    @objc func flipCurrentView() {
        
        // disable user interaction during the flip animation
        self.view.isUserInteractionEnabled = false
        self.flipIndicatorButton.isUserInteractionEnabled = false
        
        // set up the animation group
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kFlipTranslationDuration)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(VMRPacketViewController.myTransitionDidStop(_:finished:context:)))
        
        // swap the views and transition
        if self.frontViewIsVisible {
            UIView.setAnimationTransition(.flipFromRight, for: self.view, cache: true)
            self.packetView.removeFromSuperview()
            self.view.addSubview(self.packetFlippedView)
            
            // update the reflection image for the new view
            let reflectionHeight = Int(self.packetFlippedView.bounds.height * reflectionFraction)
            let reflectedImage = self.packetFlippedView.reflectedImageRepresentationWithHeight(reflectionHeight)
            reflectionView.image = reflectedImage
        }
        else {  //// (flip back to front)
            UIView.setAnimationTransition(.flipFromLeft, for: self.view, cache: true)
            self.packetFlippedView.removeFromSuperview()
            self.view.addSubview(self.packetView)
            
            // update the reflection image for the new view
            let reflectionHeight = Int(self.packetView.bounds.height * reflectionFraction)
            let reflectedImage = self.packetView.reflectedImageRepresentationWithHeight(reflectionHeight)
            reflectionView.image = reflectedImage
        }
        UIView.commitAnimations()   //// end the animations
        
        // swap the nav bar button views
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kFlipTranslationDuration)
        UIView.setAnimationDelegate(self)
        
        UIView.setAnimationDidStop(#selector(VMRPacketViewController.myTransitionDidStop(_:finished:context:)))
        
        if self.frontViewIsVisible {
            UIView.setAnimationTransition(.flipFromRight, for: self.flipIndicatorButton, cache: true)
            
            self.flipIndicatorButton.setBackgroundImage(UIImage(named:"FlipFrontButton.png"), for: UIControlState())
        }
        else {
            UIView.setAnimationTransition(.flipFromLeft, for: self.flipIndicatorButton, cache: true)
            self.flipIndicatorButton.setBackgroundImage(UIImage(named:"FlipBackButton.png"), for: UIControlState())
        }
        UIView.commitAnimations()   //// End the other animation block
        
        // toggle the front view state
        self.frontViewIsVisible = !self.frontViewIsVisible
    }
    
    // reenable user interaction when the flip animation has completed
    @objc func myTransitionDidStop(_ animationID: String, finished: NSNumber, context: UnsafeMutableRawPointer) {
        self.view.isUserInteractionEnabled = true
        self.flipIndicatorButton.isUserInteractionEnabled = true
    }
    
    // try to find this packet for sale on eBay
    @objc func jumpToEbay(_ sender: AnyObject) {
        // print("Jumping to eBay?...")
        
        // Google: "swift split string"
        // https://stackoverflow.com/questions/25678373/swift-split-a-string-into-an-array

        let titleWords = self.myPacket?.title.components(separatedBy: " ")
        
        // (stold this example from eBay search page URL)
        // https://www.ebay.com/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw=viewmaster+babes+in+toyland&_sacat=0
        //var eBayURLString = "https://www.ebay.com/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw=viewmaster+babes+in+toyland"
        var eBayURLString = "https://www.ebay.com/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw=viewmaster"
        for nextWord in titleWords! {
            eBayURLString = eBayURLString + "+" + nextWord
        }
        if !UIApplication.shared.openURL(URL(string: eBayURLString)!) {
            print("Yikes! Couldn't get to eBay!")
        }
    }
    
    private func setupUserInterface() {
        
        let buttonFrame = CGRect(x: 40.0, y: 60.0, width: 120.0, height: 120.0)
        
        // create the button
        self.ebayButton = UIButton(type: UIButtonType.system)
        self.ebayButton.frame = buttonFrame
        
        // print("setting eBay button text color...")
        self.ebayButton.titleLabel?.textColor = UIColor.white
        self.ebayButton.setTitle("Find on eBay", for: UIControlState())

        // center the text on the button, considering the button's shadow
        self.ebayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        self.ebayButton.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        self.ebayButton.addTarget(self, action:#selector(VMRPacketViewController.jumpToEbay(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.ebayButton)
    }
}
