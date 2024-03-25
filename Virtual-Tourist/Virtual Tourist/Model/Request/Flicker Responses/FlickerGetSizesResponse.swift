//
//  FlickerGetSizesResponse.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation

struct FlickerGetSizesResponse:Codable {
    let stat: String
    let sizes: Sizes
}

struct Sizes:Codable {
    let canblog: Int
    let canprint: Int
    let candownload: Int
    let size: [PhotoSizes]
}
