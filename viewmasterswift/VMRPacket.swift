//
//  VMRPacket.swift
//  ViewMasterSwift
//
//  Created by Robert England on 6/1/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Description: MODEL: Encapsulate data for one View-Master packet

import Foundation
import UIKit

// NOTE: Changing this to a class to see if it links up w/ Obj-C any easier...
//    ... it does! struct is NOT an object!
//struct VMRPacket: Printable {

// Google: "swift printable protocol"
//https://developer.apple.com/documentation/swift/customstringconvertible
class VMRPacket: CustomStringConvertible {
    var title: String
    var date: String
    var imageFileNameBase: String
    var frontImage: UIImage?
    var backImage: UIImage?
    var location: String
    var subcategory: String?
    
// Various initializers
    
    init(title: String, date: String, imageFileNameBase: String,
        location: String, subcategory: String) {
            self.title = title
            self.date = date
            self.imageFileNameBase = imageFileNameBase
            self.location = location
            self.subcategory = subcategory
            
            self.backImage = nil
            self.frontImage = nil
    }
    
    init() {
            self.title = ""
            self.date = ""
            self.imageFileNameBase = ""
            self.location = ""
            self.subcategory = ""
            
            self.backImage = nil
            self.frontImage = nil
    }
    
    init(aDictionary: NSDictionary) {
        self.title = aDictionary.value(forKey: "title") as! String
        self.date = aDictionary.value(forKey: "date") as! String
        self.imageFileNameBase = aDictionary.value(forKey: "imageFileNameBase") as! String
        self.location = aDictionary.value(forKey: "location") as! String
        if let aSubcategory = aDictionary.value(forKey: "subcategory") as? String {
            self.subcategory = aSubcategory
        }
        else {
            self.subcategory = nil
        }
        self.backImage = nil
        self.frontImage = nil
    }
    
    // [Printable] Return a description string of this object
    var description: String {
        return "Date \(date), \(title): Loc: \(location), Subcat: \(String(describing: subcategory)) ImBase: \(imageFileNameBase)"
    }

    // main front image
    func imageForPacketFrontView() -> UIImage? {
        let packetFrontImageName = self.imageFileNameBase + "Front525.png"
        let packetFrontImage = UIImage(named: packetFrontImageName)
        return packetFrontImage
    }

    // main back image
    func imageForPacketBackView() -> UIImage? {
        let packetBackImageName = self.imageFileNameBase + "Back525.png"
        let packetBackImage = UIImage(named: packetBackImageName)
        return packetBackImage
    }
    
    // tile front image
    func imageForPacketTileView() -> UIImage? {
        let packetTileImageName = self.imageFileNameBase + "Front37.png"
 //       println("Is there an image named \(packetTileImageName)?")
        let packetTileImage = UIImage(named: packetTileImageName)
        return packetTileImage
    }
}
