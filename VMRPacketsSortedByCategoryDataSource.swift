//
//  VMRPacketsSortedByCategoryDataSource.swift
//  ViewMasterSwift
//
//  Created by Robert England on 3/11/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Description: Provides the table view data for the packets sorted by category
//

import UIKit

// Note: Thie *automatically* picks up UITableDataSource protocol through
//    VMRPacketsTableDataSourceProtocol

class VMRPacketsSortedByCategoryDataSource: NSObject, VMRPacketsTableDataSourceProtocol {
    
    //// Protocol methods to comply with "VMRPacketsDataSource" protocol
    
    // Getters for properties for navagation and tab bars
    var name: String {
        get {
            return "Category"
        }
    }
    var navigationBarName: String {
        get {
            return "Packets Sorted by Category"
        }
    }
    var tabBarImage: UIImage {
        get {
            return UIImage(named: "TabCategory.png")!
        }
    }
    
    // Sorted by titles is a plain table style
    var tableViewStyle: UITableViewStyle {
        get {
            return UITableViewStyle.plain
        }
    }
    
    // Return the packet for the given index path (--> Take a closer look at this!)
    func packetForindexPath(indexPath: NSIndexPath) -> VMRPacket {
        // This table has multiple sections --- One for each Category
        // The section number is the index into the Category array,
        //    the row number is the index into that Category's array of packets.
        
        // Get the Category
        let packetCategory = VMRViewMasterPackets.packetCategories![indexPath.section]
        
        // Get the packet from that category's array
        let packetsInThisCategory = VMRViewMasterPackets.packetsInCategory(category: packetCategory)
        return packetsInThisCategory![indexPath.row]
    }
    
    // (Don't really use this)
    func titleForHeaderInSection(tableView: UITableView, section: Int) -> String {
        return ""
    }
    
//    #pragma mark - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //       println("Making a cell...")
        let cell = tableView.dequeueReusableCell(withIdentifier: "VMRPacketTableViewCell", for: indexPath) as! VMRPacketTableViewCell
        
        // Set the packet for this cell as indicated by the datasource
        cell.packet = packetForindexPath(indexPath: indexPath as NSIndexPath)
        cell.setNeedsDisplay()
        return cell
    }
    
/* obsolete swift func name and params...
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  //      println("numberOfSectionsInTableView is \(VMRViewMasterPackets.packetTitleIndexArray!.count)")
        // The number of different sections in thei table depends on the number of different first letters
        return VMRViewMasterPackets.packetCategories!.count
    }
*/
    func numberOfSections(in tableView: UITableView) -> Int {
        // The number of different sections in thei table depends on the number of different first letters
        return VMRViewMasterPackets.packetCategories!.count
    }
  
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        // Supposedly, you send me a section title (letter) and its index number, and I send you back
        //    the index number (what??!)
        return index
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 //       print("numberOfRowsInSection \(section)")
        // This table has one section per category.
        // Return the number of packets in the current category.

        // Get the category name...
        let categoryKey = VMRViewMasterPackets.packetCategories![section]

        // ... and then get the number of packets in that category
        let packetsInThisCategory = VMRViewMasterPackets.packetsInCategory(category: categoryKey)
        
        // Return how many there are in this category
        if packetsInThisCategory != nil {
            return packetsInThisCategory!.count
        }
        else {
 //           println("whoops!")
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Return the category name that corresponds to the given section, but only if there
        //    are packets in this category
        // [Technically, this is a delegate method for the table, but we get it from the data source]
//        if tableView.numberOfRowsInSection(section) != 0 {
//            return VMRViewMasterPackets.packetCategories![section]
//        }
//        return nil
        return VMRViewMasterPackets.packetCategories![section]
    }
  
    
}
