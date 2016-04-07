/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Kitura
import KituraNet
import KituraSys

import HeliumLogger
import LoggerAPI

import Foundation
//import CFEnvironment

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
