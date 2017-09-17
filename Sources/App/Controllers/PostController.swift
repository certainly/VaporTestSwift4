import Vapor
import HTTP
import Dispatch
import Foundation

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class PostController {
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    
    var drop: Droplet?
    
    func setDroplet(drop: Droplet){
        self.drop = drop
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Post.all().makeJSON()
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.post()
        try post.save()
        return post
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
//    func show(_ req: Request, post: Post) throws -> ResponseRepresentable {
//        return post
//    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Post.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, post: Post) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try post.update(for: req)

        // Save an return the updated post.
        try post.save()
        return post
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request, post: Post) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.post()

        // Update the post with all of the properties from
        // the new post
        post.content = new.content
        try post.save()

        // Return the updated post
        return post
    }

    func addRoutes(to routeBuilder: RouteBuilder) {
        routeBuilder.get("all", handler: all)
        routeBuilder.get("sort", handler: sort)
        routeBuilder.get("refresh", handler: refresh)
        test()
//        routeBuilder.post("create", handler: create)
//        routeBuilder.get(Post.parameter, handler: show)
    }
    
//    /// When making a controller, it is pretty flexible in that it
//    /// only expects closures, this is useful for advanced scenarios, but
//    /// most of the time, it should look almost identical to this
//    /// implementation
//    func makeResource() -> Resource<Post> {
//        return Resource(
//            index: index,
//            store: store,
//            show: show,
//            update: update,
//            replace: replace,
//            destroy: delete,
//            clear: clear
//        )
//    }
    func all(request: Request) throws -> ResponseRepresentable {
//        test()
        return try Post.all().makeJSON()
    }
    
    func sort(request: Request) throws -> ResponseRepresentable {
       let query = try Post.makeQuery()
        return try query.sort("time", .descending).all().makeJSON()
    }
    
    func refresh(request: Request) throws -> ResponseRepresentable {
       
        try fetch()
        let query = try Post.makeQuery()
        return try query.sort("time", .descending).all().makeJSON()
    }
    
    func reset() throws {
         try Post.makeQuery().delete()
    }

    
    func test() {
      
//        fetch()
    }
    
    func fetch() throws {
        try reset()
        Timelog.start("fetch")
        fetchHNList()
        fetchV2List()
        Timelog.stop("fetch")
    }
    
    
    func fetchV2List()  {
        Timelog.start()
        let url = "https://www.v2ex.com/api/topics/show.json?node_name=apple"
        do {
            let res = try drop?.client.get(url)
            let rawBytes = res?.body.bytes!
            let json = try JSON(bytes: rawBytes!)
            
            guard let array = json.array else { return  }
            for item in array {
                let  tt: String = try item.get("title")
                print(tt)
                let post = try Post(withV2Source: item)
                try post.save()
            }
        } catch  {
            print(error)
        }

        Timelog.stop()
    }
    
    
    func fetchHNList() {
        do {
            Timelog.start()
            print("test beging")
//            let url = "http://0.0.0.0:8083/ss.json"
            #if DEBUG
                let prefix = "http://104.194.77.164:8080/proxy/?pxurl="
                print("Debug flag on")
            #else
                   let prefix = ""
            #endif
            
            let originalurl = "https://hacker-news.firebaseio.com/v0/topstories.json"
            let url = prefix + originalurl
            let res = try drop?.client.get(url)
            let rawBytes = res?.body.bytes!
            let json = try JSON(bytes: rawBytes!)
            let count = json.array?.count
//            print("Got JSON: \(json) \(count)")
            guard let array = json.array else { return  }
            
            for item in array[0..<10] {
                print(item.int)
                var itemURL = "https://hacker-news.firebaseio.com/v0/item/"
                itemURL = prefix + itemURL + "\(item.int!).json"
                let res2 = try drop?.client.get(itemURL)
                let rawBytes = res2?.body.bytes!

               
                    let json = try JSON(bytes: rawBytes!)
                    let post = try Post(withHNSource: json)
                     try post.save()
            }
            Timelog.stop()
        } catch  {
            print(error)
        }
        
        print("testover")
        
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid 
    /// or no JSON
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(json: json)
    }
}

/// Since PostController doesn't require anything to 
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension PostController: EmptyInitializable { }
