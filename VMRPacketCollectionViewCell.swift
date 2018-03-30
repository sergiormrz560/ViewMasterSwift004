//
//  VMRPacketCollectionViewCell.swift
//  ViewMasterSwift
//
//  Created by Robert England on 3/12/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//

import UIKit

class VMRPacketCollectionViewCell: UICollectionViewCell {
    
    var packet : VMRPacket {
        didSet {
            // Associate a packet with the image view in this cell
            let imageView = self.contentView.viewWithTag(1) as! UIImageView
            imageView.image = self.packet.imageForPacketFrontView()
            // Tell the system these need refreshing
            imageView.setNeedsDisplay()
        }
    }
    
    required init (coder aDecoder: NSCoder) {
        packet = VMRPacket()
        super.init(coder: aDecoder)!
    }
    
    
}
