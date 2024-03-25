//
//  FlickerPhotoSearchResponse.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation

struct FlickerPhotoSearchResponse: Codable {
    let stat: String
    let photos: PhotoReturnObject
}

struct PhotoReturnObject: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickerPhoto]
}
