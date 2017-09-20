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
    






    func addRoutes(to routeBuilder: RouteBuilder) {
        routeBuilder.post("all", handler: all)
        routeBuilder.post("sort", handler: sort)
        routeBuilder.post("refresh", handler: refresh)
        routeBuilder.post("detail", handler: detail)
        test()
//        routeBuilder.post("create", handler: create)
//        routeBuilder.get(Post.parameter, handler: show)
    }
    

    func all(request: Request) throws -> ResponseRepresentable {
//        test()
        let rawFilter = "source IN ( 'V2','HN')"
        return try Post.makeQuery().filter(raw: rawFilter).all().makeJSON()
    }
    
    func sort(request: Request) throws -> ResponseRepresentable {
        let rawFilter = "source IN ( 'V2','HN')"
        return try  Post.makeQuery().filter(raw: rawFilter).sort("time", .descending).all().makeJSON()
    }
    
    func refresh(request: Request) throws -> ResponseRepresentable {
       
        try fetch()
        let query = try Post.makeQuery()
        return try query.sort("time", .descending).all().makeJSON()
    }
    
    
    func detail(request: Request) throws -> ResponseRepresentable {
        let cid = request.headers["cid"]
        print("cid = \(cid)")
       
        if let id = cid {
            
            try  fetchDetail(id, type: .V2comment)
           
            return try  Post.makeQuery().filter("other" , cid).all().makeJSON()
        } else if let kids = request.headers["kids"] {
            print("kids = \(kids)")
            let tKids = kids.components(separatedBy: ",")
            try Post.makeQuery().filter("source",SourceType.HNcomment.rawValue).delete()
            for kid in tKids {
               
                
               
                fetchDataImpl(cid: kid, type: .HNcomment)
            }
            
//            fetchDetailKids(kids)
            
        }
        
        return try  Post.makeQuery().filter("source", in: [SourceType.HNcomment.rawValue]).sort("time", .descending).all().makeJSON()
       
        
    }
    
    
    
    func fetchDetail(_ aId: String, type: SourceType) throws {
        //fetch v2ex comments
        try Post.makeQuery().filter("source",type.rawValue).delete()
//        let rawFilter = "source IN [ \(type.rawValue)  ]"
        
//          try Post.makeQuery().filter(raw: rawFilter).delete()
        fetchDataImpl(cid: aId, type:type)
        
        
    }
    
    func reset() throws {
         try Post.makeQuery().delete()
    }

    
    func test()   {
        do {
//

//            let str = "Andrew, Ben, John, Paul, Peter, Laura"
//            let array = str.components(separatedBy: ", ")
//            print("arr = \(array)")
//
//              try  self.fetch()
//            let result0 = try Portal<Int>.open { [weak self] portal in
//                for i in 0...3 {
//                        background {
//                            print("world \(i)")
//                        }
//                    portal.close(with: 1)
//                }
////
//            }
            

  
            print("test over")
            
//            print(result)
            
        } catch {
            print(error)
        }
        
    }
    
    func fetch() throws {
        try reset()
        Timelog.start("fetch")
        fetchHNList()
        fetchV2List()
        Timelog.stop("fetch")
    }
    
    
    func fetchDataImpl(cid: String? = nil,type: SourceType) {
        Timelog.start()
        let url: String?
        switch type {
        case .V2:
            url =  "https://www.v2ex.com/api/topics/show.json?node_name=apple"
        case .V2comment:
            url = "https://www.v2ex.com/api/replies/show.json?topic_id=" + cid!
        case .HNcomment:
            #if DEBUG
                let prefix = "http://104.194.77.164:8080/proxy/?pxurl="
                print("Debug flag on")
            #else
                let prefix = ""
            #endif
            url = prefix + "https://hacker-news.firebaseio.com/v0/item/\(cid!).json"
        default:
            url = ""
            break
        }
        
       
        do {
            print("url == \(url)")
            let res = try drop?.client.get(url!)
           
            let rawBytes = res?.body.bytes!
            let json = try JSON(bytes: rawBytes!)
            var array:[JSON] = []
            if json.array == nil {
                array.append(json)
            } else {
                array = json.array!
            }
            
            print("count: \(array.count)")
            for item in array {
                
                
                var post: Post? = nil
                switch type  {
                case .V2:
                    let  tt: String = try item.get("title")
                    print(tt)
                     post = try Post(withV2Source: item)
                case .V2comment:
                    post = try Post(withV2Comments: item, cid: cid!)
                case .HNcomment:
                    post = try Post(withHNComments: item, cid: cid!)
                default:
                  
                    break
                    
                }
                
                
                try post?.save()
            }
        } catch  {
            print(error)
        }
        
        Timelog.stop()
    }
    

    
    func fetchV2List()  {
       
        let type = SourceType.V2
        fetchDataImpl( type: type)
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
