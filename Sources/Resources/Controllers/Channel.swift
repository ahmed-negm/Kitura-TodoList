import Kitura
import KituraNet
import LoggerAPI
import SwiftyJSON

/**
 Sets up all the routes for the Channel Resource
*/
func setupChannelRoutes(router: Router) {
    
    let routeUrl = "/api/channels"
    
    // Setup the database
    let channels: ChannelCollection = ChannelCollectionArray()
    
    // Get all channels
    router.get(routeUrl) {
        request, response, next in

        channels.getAll() {
            channels in
            let json = JSON(ChannelCollectionArray.serialize(channels))
            do {
                try response.status(HttpStatusCode.OK).sendJson(json).end()
            } catch {
                
            }
        }
    }
    
    // Get information about a channel by ID
    router.get(routeUrl + "/:id") {
        request, response, next in
        
        let id: String? = request.params["id"]
        
        guard id != nil else {
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        
        channels.get(id!) {
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
    
    // Add a channel
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
        
        let channel = ChannelItem(json: json)
        
        channels.add(channel) {
            newItem in
            let result = JSON(newItem.serialize())
            do  {
                try response.status(HttpStatusCode.OK).sendJson(result).end()
            } catch {
                Log.error("Something went wrong")
            }
        }
    }
    
    // Update an existing Channel
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
            let channel = ChannelItem(json: json)
            
            channels.update(id!, channel: channel) {
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
    
    // Delete an individual channel
    router.delete(routeUrl + "/:id") {
        request, response, next in
        Log.info("Requesting a delete")
        let id: String? = request.params["id"]
        guard id != nil else {
            Log.warning("Could not parse ID")
            response.status(HttpStatusCode.BAD_REQUEST)
            return
        }
        channels.delete(id!) {
            do {
                try response.status(HttpStatusCode.OK).end()
            } catch {
                Log.error("Could not produce response")
            }
        }
    }
    
    // Delete all the channels
    router.delete(routeUrl) {
        request, response, next in
        
        Log.info("Requested clearing the entire list")
        
        channels.clear() {
            do {
                try response.status(HttpStatusCode.OK).end()
            } catch {
                Log.error("Could not produce response")
            }
        }
    }
}
