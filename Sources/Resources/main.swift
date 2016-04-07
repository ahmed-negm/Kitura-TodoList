import Kitura
import KituraNet
import KituraSys

import HeliumLogger
import LoggerAPI

import Foundation

///
/// The Kitura router
///
let router = Router()

///
/// Set up a simple Logger
///
Log.logger = HeliumLogger()

///
/// Setup the database
///
let todos: TodoCollection = TodoCollectionArray(baseURL: "http://localhost:8090/todos")


/**
 Custom middleware that allows Cross Origin HTTP requests
 */
class AllRemoteOriginMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        response.setHeader("Access-Control-Allow-Origin", value: "*")
        next()
    }
}

router.all("/*", middleware: BodyParser())

router.all("/*", middleware: AllRemoteOriginMiddleware())

/**
 Handle options
 */
router.options("/*") {
    request, response, next in
    
    response.setHeader("Access-Control-Allow-Headers", value: "accept, content-type")
    response.setHeader("Access-Control-Allow-Methods", value: "GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH")
    
    response.status(HttpStatusCode.OK)
    
    next()
}

setupChannelRoutes( router, todos: todos )

///
/// Listen to port 8090
///
let port = 8090
let server = HttpServer.listen(port, delegate: router)
Server.run()

print("Server is starting ...")
