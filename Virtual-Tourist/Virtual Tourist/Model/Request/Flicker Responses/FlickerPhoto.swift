//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation


struct FlickerPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

