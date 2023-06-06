//
//  MediaResponse.swift
//  GenericApiSwift
//
//  Created by Apple on 04/06/23.
//

import Foundation

// MARK: - MediaResponse
struct MediaResponse: Codable {
    let categories: [CategoryDetails]
}

// MARK: - Category
struct CategoryDetails: Codable {
    let name: String
    let videos: [Video]
}

// MARK: - Video
struct Video: Codable {
    let id: Int
    let description: String
    let sources: [String]
    let subtitle: Subtitle
    let thumb, title: String
    
    var fileSize: Int64?
}

enum Subtitle: String, Codable {
    case byBlenderFoundation = "By Blender Foundation"
    case byGarage419 = "By Garage419"
    case byGoogle = "By Google"
}

