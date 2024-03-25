//
//  PhotoSizes.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation

struct PhotoSizes:Codable {
    let label: String
    let width: Int
    let height: Int
    let source: String
    let url: String
    let media: String
}
