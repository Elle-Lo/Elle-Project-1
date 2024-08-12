import CoreData
import UIKit

// MARK: StorageManager
class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "STYLiSH")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveCartItem(name: String?, color: String?, size: String?, quantity: String?, image: String?, price: String?, stock: String?) {
        guard let name = name, let color = color, let size = size else {
            print("Invalid parameters for saving cart item")
            return
        }
        
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "name", "color == %@", "color", "size == %@", "size")
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            if let existingItem = existingItems.first {
                
                let currentQuantity = Int(existingItem.quantity ?? "0") ?? 0
                let newQuantity = currentQuantity + (Int(quantity ?? "0") ?? 0)
                existingItem.quantity = "\(newQuantity)"
            } else {
                
                let cartItem = CartItem(context: context)
                cartItem.name = name
                cartItem.price = price
                cartItem.image = image
                cartItem.color = color
                cartItem.size = size
                cartItem.quantity = quantity
                cartItem.stock = stock
            }
            
            saveContext()
            NotificationCenter.default.post(name: .cartItemsUpdated, object: nil)
            
        } catch {
            print("Failed to fetch cart items: \(error)")
        }
    }
    
    func updateCartItemQuantity(cartItem: CartItem, quantity: String) {
        cartItem.quantity = quantity
        saveContext()
        NotificationCenter.default.post(name: .cartItemsUpdated, object: nil)
    }
    
    func deleteCartItem(cartItem: CartItem) {
        context.delete(cartItem)
        
        do {
            try context.save()
            NotificationCenter.default.post(name: .cartItemsUpdated, object: nil)
        } catch {
            print("Failed to delete cart item: \(error.localizedDescription)")
        }
    }
    
    func clearCart() {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        
        do {
            let cartItems = try context.fetch(fetchRequest)
            for item in cartItems {
                context.delete(item)
            }
            
            saveContext()
            NotificationCenter.default.post(name: .cartItemsUpdated, object: nil)
            
        } catch {
            print("Failed to fetch cart items: \(error.localizedDescription)")
        }
    }

    
    func fetchCartItems() -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch orders: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func totalQuantityFromCartItems() -> Int {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        
        do {
            let cartItems = try context.fetch(fetchRequest)
            let totalQuantity = cartItems.reduce(0) { (total, item) -> Int in
                let quantity = Int(item.quantity ?? "0") ?? 0
                return total + quantity
            }
            return totalQuantity
        } catch {
            print("Error fetching CartItems: \(error)")
            return 0
        }
    }
    
    func updateTabBarBadge(for tabBarController: UITabBarController) {
        let totalQuantity = totalQuantityFromCartItems()
        tabBarController.tabBar.items?[2].badgeValue = totalQuantity > 0 ? "\(totalQuantity)" : nil
    }
    
}
