import KituraSys
import LoggerAPI
import SwiftyJSON
import Foundation

/**
 Because bridging is not complete in Linux, we must use Any objects for dictionaries
 instead of AnyObject. The main branch SwiftyJSON takes as input AnyObject, however
 our patched version for Linux accepts Any.
*/
#if os(OSX)
    typealias JSONDictionary = [String: AnyObject]
#else
    typealias JSONDictionary = [String: Any]
#endif

struct ChannelItem {
    var id: String = ""
    var order: Int = 0
    var title: String = ""
    var completed: Bool = false

    ///
    /// Transform the structure to a Dictionary
    ///
    /// Returns: a Dictionary populated with fields.
    ///
    func serialize() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = id
        result["order"] = order
        result["title"] = title
        result["completed"] = completed
        return result
    }
}

/**
 ChannelCollection

 ChannelCollection defines the DAO for channel lists
*/
protocol ChannelCollection {
    var count: Int { get }

    func clear( oncompletion: (Void) -> Void)
 
    func getAll( oncompletion: ([ChannelItem]) -> Void )
    
    func get(id: String, oncompletion: (ChannelItem?) -> Void )
 
    func add(title: String, order: Int, completed: Bool, oncompletion: (ChannelItem) -> Void )

    func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (ChannelItem?) -> Void )

    func delete(id: String, oncompletion: (Void) -> Void)
    
    static func serialize(items: [ChannelItem]) -> [JSONDictionary]
}

class ChannelCollectionArray: ChannelCollection {

    ///
    /// Ensure in order writes to the collection
    ///
    let writingQueue = Queue(type: .SERIAL, label: "Writing Queue")

    ///
    /// Incrementing variable used for new index values
    ///
    var idCounter: Int = 0

    ///
    /// Internal storage of ChannelItems as a Dictionary
    ///
    private var _collection = [String: ChannelItem]()
    
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

    func getAll( oncompletion: ([ChannelItem]) -> Void ) {
        writingQueue.queueSync() {
            oncompletion( [ChannelItem](self._collection.values) )
        }
    }
    
    func get(id: String, oncompletion: (ChannelItem?) -> Void ) {
        writingQueue.queueSync() {
            oncompletion(self._collection[id])
        }
    }

    static func serialize(items: [ChannelItem]) -> [JSONDictionary] {
        return items.map { $0.serialize() }
    }

    func add(title: String, order: Int, completed: Bool, oncompletion: (ChannelItem) -> Void ) {
        var original: String
        original = String(self.idCounter)
        
        let newItem = ChannelItem(id: original,
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
    
    func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (ChannelItem?) -> Void ) {
        // search for element
        let oldValue = _collection[id]
        
        if let oldValue = oldValue {
            // use nil coalescing operator
            let newValue = ChannelItem( id: id,
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