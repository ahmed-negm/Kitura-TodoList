import KituraSys
import LoggerAPI
import SwiftyJSON
import Foundation

class TodoCollectionArray: TodoCollection {

    ///
    /// Ensure in order writes to the collection
    ///
    let writingQueue = Queue(type: .SERIAL, label: "Writing Queue")

    ///
    /// Incrementing variable used for new index values
    ///
    var idCounter: Int = 0

    ///
    /// Internal storage of TodoItems as a Dictionary
    ///
    private var _collection = [String: TodoItem]()
    
    init() {
    }

    var count: Int {
        return _collection.keys.count
    }

    func clear( oncompletion: (Void) -> Void) {
        writingQueue.queueSync() {
            self._collection.removeAll()
            oncompletion()
        }
    }

    func getAll( oncompletion: ([TodoItem]) -> Void ) {
        writingQueue.queueSync() {
            oncompletion( [TodoItem](self._collection.values) )
        }
    }
    
    func get(id: String, oncompletion: (TodoItem?) -> Void ) {
        writingQueue.queueSync() {
            oncompletion(self._collection[id])
        }
    }

    static func serialize(items: [TodoItem]) -> [JSONDictionary] {
        return items.map { $0.serialize() }
    }

    func add(title: String, order: Int, completed: Bool, oncompletion: (TodoItem) -> Void ) {
        var original: String
        original = String(self.idCounter)
        
        let newItem = TodoItem(id: original,
            order: order,
            title: title,
            completed: completed
        )

        writingQueue.queueSync() {
            self.idCounter+=1
            self._collection[original] = newItem
            Log.info("Added \(title)")
            oncompletion(newItem)
        }
    }
    
    func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (TodoItem?) -> Void ) {
        // search for element
        let oldValue = _collection[id]
        
        if let oldValue = oldValue {
            // use nil coalescing operator
            let newValue = TodoItem( id: id,
                order: order ?? oldValue.order,
                title: title ?? oldValue.title,
                completed: completed ?? oldValue.completed
            )
            
            writingQueue.queueSync() {
                self._collection.updateValue(newValue, forKey: id)
                oncompletion( newValue )
            }
        } else {
            Log.warning("Could not find item in database with ID: \(id)")
        }
    }

    func delete(id: String, oncompletion: (Void) -> Void) {
        writingQueue.queueSync() {
            self._collection.removeValue(forKey: id)
            oncompletion()
        }
    }
}