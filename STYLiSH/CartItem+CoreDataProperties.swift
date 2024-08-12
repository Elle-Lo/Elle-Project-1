//
//  CartItem+CoreDataProperties.swift
//  
//
//  Created by Tzu ning Lo on 2024/8/12.
//
//

import Foundation
import CoreData


extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var color: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var price: String?
    @NSManaged public var quantity: String?
    @NSManaged public var size: String?
    @NSManaged public var stock: String?

}
