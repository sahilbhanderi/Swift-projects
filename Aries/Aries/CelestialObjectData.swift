//
//  CelestialObjectData.swift
//  Aries
//
//  Created by Sahil Bhanderi on 11/20/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//  Based on SampleCode2019 © John Hannan
//

import Foundation

// Structs for decoding JSON
// CelestialObjectData is the top-level struct we decode the JSON into
struct CelestialObjectData: Decodable {
    let collection: CollectionData
    
    private enum CodingKeys: String, CodingKey {
        case collection
    }
    
    struct CollectionData: Decodable {
        let version : String
        let href : String
        let links : [CollectionLink]
        let items : [Items]
        let metadata : MetaData
        
        private enum CodingKeys: String, CodingKey {
            case version
            case href
            case links
            case items
            case metadata
        }
    }
}

// Struct representing links for collection of CelestialObjects from the JSON
struct CollectionLink : Decodable {
    let href : String
    let rel : String
    let prompt : String
    
    private enum CodingKeys: String, CodingKey {
        case href
        case rel
        case prompt
    }
}

// Struct representing one CelestialObject from the JSON
struct Items : Decodable {
    let data : [ItemData]
    let links : [Link]
    let href : String
    
    struct Link : Decodable {
        let href : String
        let rel : String
        let render : String?
    }
    
    struct ItemData : Decodable {
        let center : String
        let media_type : String
        let description : String
        let title : String
        let date_created : String
        let nasa_id : String
        let keywords : [String]
    }
    
}

// Struct representing the number of results from the JSON query
struct MetaData : Decodable {
    let total_hits : Int
}

// This is the class we use to model an individual CelestialObject
class CelestialObjectInfo {
    let title:String
    let description:String
    let imageURL:String
    var imageData:Data?
    
    init(item:Items) {
        self.title = item.data[0].title
        self.description = item.data[0].description
        imageURL = item.links[0].href
        imageData = nil
        
    }
}
