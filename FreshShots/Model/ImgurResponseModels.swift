//
//  ImgurResponseModels.swift
//  FreshShots
//
//  Created by Jeba Moses on 18/10/22.
//

import Foundation

struct ImgurResponse: Decodable {
    let data: [ImageData]
}

struct ImageData: Decodable {
    let title: String
    var datetime: Double
    let images: [Image]?
}

struct Image: Decodable {
    var link: String?
}
