import Kitura
import KituraNet

import LoggerAPI
import SwiftyJSON

/**
 Sets up all the routes for the Channel Resource
*/
func setupChannelRoutes(router: Router, todos: TodoCollection) {
    
    let routeUrl = "/api/channels"
    /**
        Get all the todos
    */
    router.get(routeUrl) {
        request, response, next in

        todos.getAll() {
            todos in
            let json = JSON(TodoCollectionArray.serialize(todos))
            do {
                try response.status(HttpStatusCode.OK).sendJson(json).end()
            } catch {
                
            }
        }
    }
    
    /**
     Get information about a todo item by ID
     */
    router.get(routeUrl + "/:id") {
        request, response, next in
        
        let id: String? = request.params["id"]
        
        guard id != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        todos.get(id!) {
            item in
            if let item = item {
                let result = JSON(item.serialize())
                do {
                    try response.status(HttpStatusCode.OK).sendJson(result).end()
                } catch {
                    
                }
            }
        }
    }
    
    /**
     Add a todo list item
     */
    router.post(routeUrl) {
        request, response, next in
        
        guard request.body != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        let body = request.body!
        
        guard body.asJson() != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        let json = body.asJson()!
        
        let title = json["title"].stringValue
        let order = json["order"].intValue
        let completed = json["completed"].boolValue
        
        Log.info("Received \(title)")
        
        todos.add(title, order: order, completed: completed) {
            newItem in
            let result = JSON(newItem.serialize())
            do  {
                try response.status(HttpStatusCode.OK).sendJson(result).end()
            } catch {
                Log.error("Something went wrong")
            }
        }
    }
    
    router.post(routeUrl + "/:id") {
        request, response, next in
        
        let id: String? = request.params["id"]
        
        guard request.body != nil else {
            Log.warning("No body")
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        guard request.body!.asJson() != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        let json = request.body!.asJson()!
        
        let title = json["title"].stringValue
        let order = json["order"].intValue
        let completed = json["completed"].boolValue
        
        todos.update(id!, title: title, order: order, completed: completed) {
            newItem in
            let result = JSON(newItem!.serialize())
            response.status(HttpStatusCode.OK).sendJson(result)
        }
    }
    
    /**
     Update an existing Todo item
     */
    router.put(routeUrl + "/:id") {
        request, response, next in
        
        let id: String? = request.params["id"]
        
        guard id != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        guard request.body != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        let body = request.body!
        if let json = body.asJson() {
            let title = json["title"].stringValue
            let order = json["order"].intValue
            let completed = json["completed"].boolValue
            
            todos.update(id!, title: title, order: order, completed: completed) {
                newItem in
                if let newItem = newItem {
                    let result = JSON(newItem.serialize())
                    do {
                        try response.status(HttpStatusCode.OK).sendJson(result).end()
                    } catch {}
                }
            }
        }
    }
    
    ///
    /// Delete an individual todo item
    ///
    router.delete(routeUrl + "/:id") {
        request, response, next in
        Log.info("Requesting a delete")
        let id: String? = request.params["id"]
        guard id != nil else {
            Log.warning("Could not parse ID")
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        todos.delete(id!) {
            do {
                try response.status(HttpStatusCode.OK).end()
            } catch {
                Log.error("Could not produce response")
            }
        }
    }
    
    /**
     Delete all the todo items
     */
    router.delete(routeUrl) {
        request, response, next in
        
        Log.info("Requested clearing the entire list")
        
        todos.clear() {
            do {
                try response.status(HttpStatusCode.OK).end()
            } catch {
                Log.error("Could not produce response")
            }
        }
    }
}
