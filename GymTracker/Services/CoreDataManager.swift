import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "GymTracker")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            print("Failed to save Core Data: \(error.localizedDescription)")
        }
    }
} 