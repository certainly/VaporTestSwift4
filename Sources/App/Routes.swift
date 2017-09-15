import Vapor
import  Foundation

extension Droplet {
    
    struct Foo: Codable {
        let dd: String

    }
    
    
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

        test()
        try resource("posts", PostController.self)
    }

    func test() {
        print("dfd")
        let encoder = JSONEncoder()
        let data = Foo(dd: "df")
        do {
            try encoder.encode(data)
        } catch {
            print(error)
        }
        print("okk")
    }
}
