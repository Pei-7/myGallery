//
//  AirtableColumn.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/14.
//

import Foundation

struct AirtableColumn: Codable {
    let name: String
    let fields: [Field]
    let id: String?
}

struct Field: Codable {
    let name: String
    let type: String
    let options: Options?
}

struct Options: Codable {
    let dateFormat: DateFormat?
}

struct DateFormat: Codable {
    let name: String
    let format: String
}
