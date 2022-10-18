//
//  Constants.swift
//  FreshShots
//
//  Created by Jeba Moses on 17/10/22.
//

import Foundation

struct Constants {
    static let baseURL = "https://api.imgur.com"
    static let version = "3"
    static let clientId = "2e19bb8e5b8700b"
    static let clientSecret = "0dae573e0976f59c9e1d2f69adf5ede08d5eb2a9"
    static let galleryEndPoint = "gallery"
    static let search = "search"
}

enum SortTypeEnum {
    case time, viral, top
}

enum WindowTypeEnum {
    case day, week, month, year, all
}

enum SectionTypeEnum {
    case hot, top, user
}
