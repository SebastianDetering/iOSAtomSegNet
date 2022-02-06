import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "DataModel")
        
        container.loadPersistentStores {
            (storeDescription, error) in
            if let myerror = error { fatalError("error: \(myerror)")}
        }
    }
}
