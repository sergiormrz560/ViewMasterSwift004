//
//  VMRPacketTileView.swift
//  ViewMasterSwift
//
//  Created by Robert England on 3/11/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Description: VIEW: Draws the small tile view of a packet displayed in a tableview row.
//

import UIKit

class VMRPacketTileView: UIView {
    var packet : VMRPacket
    
    override init(frame aRect: CGRect) {
        packet = VMRPacket()
        super.init(frame: aRect)
    }

    required init (coder aDecoder: NSCoder) {
        packet = VMRPacket()
        super.init(coder: aDecoder)!
    }

    // Google: "swift cgrectmake"
//https://stackoverflow.com/questions/38335046/update-cgrectmake-to-cgrect-in-swift-3-automatically
// AND.. shows how to update to current Swift syntax!
    override func draw(_ rect: CGRect) {
        let tileImage = packet.imageForPacketTileView()
        let tileImageRectangle = CGRect(x:0, y:0, width:tileImage!.size.width, height:tileImage!.size.height)
        
        tileImage?.draw(in: tileImageRectangle)
    }
}
