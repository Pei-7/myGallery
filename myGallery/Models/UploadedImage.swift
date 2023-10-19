//
//  UploadedImage.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/14.
//

import Foundation

struct UploadedImage: Decodable {
    let data: Data
}

struct Data: Decodable {
    let link: URL
}
