import Vapor
import  Foundation

extension Droplet {
    
  
    
    
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hel3lo", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        
        let v1 = V1(drop: self)
        try collection(v1)
        
        
//        try resource("posts", PostController.self)
    }
  
  
}
