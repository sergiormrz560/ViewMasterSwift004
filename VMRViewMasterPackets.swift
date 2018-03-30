//
//  VMRViewMasterPackets.swift
//  ViewMasterSwift
//
//  Created by Robert England on 3/12/18.
//  Copyright (c) 2018 Robert England. All rights reserved.
//
//  Description: MODEL: Encapsulates collection of View-Master packets and return it in
//      various presorted formats.
//

import Foundation

class VMRViewMasterPackets {
    static var packetCategories: [String]?
    static var packetTitleIndexArray: [String]?
    
    // Dictionaries that will contain arrays of packets indexed by...
    // Title:
    static var titlesDictionary: [String : VMRPacket]?
    // Unique first title characters (for Title index table)
    static var titlesIndexDictionary: [String : [VMRPacket]]?
    // Category:
    static var categoriesDictionary: [String : [VMRPacket]]?

    // Regular array of packets sorted by number
    static var packetsSortedByNumber: [VMRPacket]?
    
    // Only one instance of this will be allocaed an filled in
    static var privateSharedViewMasterPackets: VMRViewMasterPackets?
    
    
    static func packetsInCategory (category: String) -> [VMRPacket]? {
        return categoriesDictionary![category]
    }
    
    static func packetsWithInitialLetter (letter: String) -> [VMRPacket]? {
 //       println("packetsWithInitialLetter")
        return titlesIndexDictionary![letter]
    }
    
    init () {
        VMRViewMasterPackets.privateSharedViewMasterPackets = nil
        VMRViewMasterPackets.packetCategories = [String]()
        VMRViewMasterPackets.packetTitleIndexArray = [String]()
        VMRViewMasterPackets.categoriesDictionary = [String : [VMRPacket]]()
        VMRViewMasterPackets.titlesDictionary = [String : VMRPacket]()
        VMRViewMasterPackets.titlesIndexDictionary = [String : [VMRPacket]]()
        VMRViewMasterPackets.packetsSortedByNumber = [VMRPacket]()
    }
    
// Initialize the MODEL
    static func sharedViewMasterPackets() -> VMRViewMasterPackets? {
        // Make and initialize this only one time
        if VMRViewMasterPackets.privateSharedViewMasterPackets != nil {
            return privateSharedViewMasterPackets
        }
        
        // If we're still here, we need to set up everything in the VM data model
        VMRViewMasterPackets.privateSharedViewMasterPackets = VMRViewMasterPackets()
        
        // Read the plist array that contains all of the packet data:
        //    Array elements are individual dictionaries, 1 per packet
        // Ref: http://rebeloper.com/read-write-plist-file-swift/
        if let bundlePath = Bundle.main.path(forResource: "Packets", ofType: "plist") {
            let rawPacketsArray = NSMutableArray(contentsOfFile: bundlePath)!

            // Iterate over all values read from the file, placing them in the proper data structures
            for eachPacketDictionary in rawPacketsArray {
                
                // Create a packet instance for each --- "unpack" the dictionary
                let aPacket = VMRPacket(aDictionary: eachPacketDictionary as! NSDictionary)
                
                // Store the packet in the packets dictionary with title as key
                titlesDictionary![aPacket.title] = aPacket
                
                // Make sure that the category for this packet exists
                registerCategory(category: aPacket.category)
                
                // Add the packet to the appropriate array in the category dictionary
                categoriesDictionary![aPacket.category]!.append(aPacket)
                
                // Get the title's initial letter
                /*
                let fromStart = aPacket.title.startIndex
                let toPosition = 1 // All we want in the first character, for crying out loud
                let endPosition = advance(fromStart, toPosition)
                let titleFirstLetter = aPacket.title.substringToIndex(endPosition)
                */
                
                //// (borrowed from PeriodicElements.swift)
                let titleFirstLetter = aPacket.title.substring(to: aPacket.title.index(after: aPacket.title.startIndex))
                
                // If an array already exists for the title's first letter, add this
                //    packet to it; otherwise, create the array first
                if titlesIndexDictionary![titleFirstLetter] == nil {
                    titlesIndexDictionary![titleFirstLetter] = [VMRPacket]()
                }
                titlesIndexDictionary![titleFirstLetter]!.append(aPacket)
                
            }
            
            // Sort the category names
            packetCategories = packetCategories!.sorted { $0 < $1 }
            
            // Presort packets within each category
            presortPacketsByCategory()
            
            // Presort packets' titles' first letters
            presortPacketTitleInitialLetterIndexes()
            
            // Presort packets by number
            packetsSortedByNumber = presortPacketsByNumber()
            
        }
        else {
 //           println("Yikes! Packets.plist file not found!")
        }
        
        return privateSharedViewMasterPackets
    }
    
// See if this category exists; If not, then create it
    static func registerCategory(category: String) {
        // Does this category already exist?
        // If so, nothing to do: return
        for eachCategory in packetCategories! {
            if eachCategory == category {
                return
            }
        }
        // Still here?
        // Then didn't find it: Make a new one, and an array of packets to go with it
        packetCategories!.append(category)
        categoriesDictionary![category] = [VMRPacket]()
    }

//// By title...
    
    static func presortPacketTitleInitialLetterIndexes() {
        // Create a new, sorted array of all of the title first letters
        // (Will be used similarly to categories to group packets into sublists)
        // Ref: http://stackoverflow.com/questions/26386093/array-from-dictionary-keys-in-swift
        // packetTitleIndexArray = sorted(titlesIndexDictionary!.keys.array) { $0 < $1 }
        
        // array from disctionary:
        // https://stackoverflow.com/questions/26386093/array-from-dictionary-keys-in-swift
        var unsortedPacketTitleIndexArray = Array(titlesIndexDictionary!.keys)
        
        
        packetTitleIndexArray = unsortedPacketTitleIndexArray.sorted()
        
        // Sort groups of packets whose titles start with the same letter
        for eachTitleIndex in packetTitleIndexArray! {
            presortPacketTitlesForInitialLetter(aLetter: eachTitleIndex)
        }
    }

    static func presortPacketTitlesForInitialLetter(aLetter : String) {
        // Grab the array for this letter and sort it
        let sortedByFirstLetter = titlesIndexDictionary![aLetter]?.sorted { $0.title < $1.title }
        titlesIndexDictionary![aLetter]! = sortedByFirstLetter!
    }
    
//// Packets by category...
    
    // Presort each of the category arrays [for separate sections in a table]
    static func presortPacketsByCategory() {
        for eachCategory in packetCategories! {
            presortPacketsWithCategory(category: eachCategory)
        }
    }
    
    // Sort all of the packets in one category
    static func presortPacketsWithCategory(category : String) {
        let sortedByCategory = categoriesDictionary![category]?.sorted { $0.title < $1.title }
        categoriesDictionary![category]! = sortedByCategory!
    }
    
//// Packets by number...
    
    // Presort the packetsSortedByNumber array

/* Ref: https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/CollectionTypes.html
    let airportNames = [String](airports.values)
    // airportNames is ["Toronto Pearson", "London Heathrow"]
    Swift’s Dictionary type does not have a defined ordering. To iterate over the keys or values of a dictionary in a specific order, use the global sorted function on its keys or values property.
*/
    static func presortPacketsByNumber() -> [VMRPacket] {
        let sortedByNumber = [VMRPacket](titlesDictionary!.values).sorted { $0.number < $1.number }
        return sortedByNumber
    }
}












