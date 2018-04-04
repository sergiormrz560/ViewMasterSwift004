//
//  VMRPacketFlippedView.swift  (copied from VMRPacketFlippedView.m)
//  ViewMaster
//
//  Created by Robert England on 3/11/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Abstract: Displays the back of the packet, along with a link to eBay.
//

import UIKit

@objc(VMRPacketFlippedView)
class VMRPacketFlippedView: VMRPacketView {
    
    // (wikipedia button was here)
    
    // (func setupUserInterface was here)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizesSubviews = true
        // self.setupUserInterface()
        
        // set the background color of the view to clear
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // (jumpToWikipedia was here)
    
    override func draw(_ rect: CGRect) {
        guard let packet = self.packet else {return}
        let packetBackImage = packet.imageForPacketBackView()
    //    let packetRectangle = CGRect(x: 0, y: 0, width: (packetBackImage?.size.width)!, height: (packetBackImage?.size.height)!)
        let packetRectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
        packetBackImage?.draw(in: packetRectangle)
    }
}
