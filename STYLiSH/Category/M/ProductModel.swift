import UIKit
import Foundation

// MARK: Product Model
struct ProductResponse: Codable {
    let data: [Product]
    let nextPaging: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextPaging = "next_paging"
    }
}

struct Product: Codable {
    
    let id: Int
    let category: String
    let title: String
    let description: String
    let price: Int
    let texture: String
    let wash: String
    let place: String
    let note: String
    let story: String
    let mainImage: String
    let images: [String]
    let variants: [Variant]
    let colors: [Color]
    let sizes: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case category
        case title
        case description
        case price
        case texture
        case wash
        case place
        case note
        case story
        case mainImage = "main_image"
        case images
        case variants
        case colors
        case sizes
    }
}

struct Variant: Codable {
    let colorCode: String
    let size: String
    let stock: Int
    
    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case size
        case stock
    }
}

struct Color: Codable {
    let code: String
    let name: String
}
