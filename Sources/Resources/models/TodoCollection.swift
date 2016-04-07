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

/**
 TodoCollection

 TodoCollection defines the DAO for todo lists
*/
protocol TodoCollection {
    var count: Int { get }

    func clear( oncompletion: (Void) -> Void)
 
    func getAll( oncompletion: ([TodoItem]) -> Void )
    
    func get(id: String, oncompletion: (TodoItem?) -> Void )
 
    func add(title: String, order: Int, completed: Bool, oncompletion: (TodoItem) -> Void )

    func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (TodoItem?) -> Void )

    func delete(id: String, oncompletion: (Void) -> Void)
    
    static func serialize(items: [TodoItem]) -> [JSONDictionary]
}

