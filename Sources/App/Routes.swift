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

        test()
        try resource("posts", PostController.self)
    }

    func test() {
        do {
//            let url = "http://10.0.0.9:8099/ss.json"
//            let url = "https://www.twitter.com"
            let url = "https://hacker-news.firebaseio.com/v0/topstories.json"
            let res = try self.client.get(url)
            let rawBytes = res.body.bytes!

            let json = try JSON(bytes: rawBytes)
            let count = json.array?.count
            print("Got JSON: \(json) \(count)")
        } catch  {
            print(error)
        }
       
        print("dfd")
//        let encoder = JSONEncoder()
//        let data = Foo(dd: "df")
//        do {
//            try encoder.encode(data)
//        } catch {
//            print(error)
//        }
        print("okk")
    }
}
