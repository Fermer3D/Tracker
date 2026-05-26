import UIKit
import CoreData

final class DataProvider {
    static let shared = DataProvider()
    private init() {}
    
    // Берем контекст напрямую из AppDelegate
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
