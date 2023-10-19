//
//  Airtable.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/14.
//

import Foundation

struct AirtableRecords: Codable {
    let records: [Records]?
}

struct Records: Codable {
    var id: String?
    var fields: Fields
}

struct Fields: Codable {
    let date: String
    let imageURL: URL
    let notes: String?
    
    enum CodingKeys: String,CodingKey {
        case date = "Date"
        case imageURL = "ImageURL"
        case notes = "Notes"
    }
}
