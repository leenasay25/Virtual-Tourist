//
//  FlickerResponse.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import Foundation

struct FlickerResponse: Codable {
    let stat: String
    let code: Int?
    let message: String?
}

extension FlickerResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
