struct TodoItem {
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
