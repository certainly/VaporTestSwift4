import Vapor
import FluentProvider
import HTTP

enum SourceType: String {
    case V2 = "V2"
    case HN = "HN"
    case V2comment = "V2comment"
}

final class Post: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var cid: Int
    var content: String
    var time: Double
    var source: String
    var kids: String
    var other: String
    
    
    /// The column names for `id` and `content` in the database
    static let idKey = "id"
    static let cidKey = "cid"
    static let contentKey = "content"
    static let timeKey = "time"
    static let sourceKey = "source"
    static let kidsKey = "kids"
    static let otherKey = "other"
    

    /// Creates a new Post
    init(cid: Int, content: String, time: Double, source: String, kids: String, other: String) {
        self.cid  = cid
        self.content = content
        self.time = time
        self.source = source
        self.kids = kids
        self.other = other
    }
    
    convenience init(withHNSource src: JSON) throws {
       try self.init(cid: src.get("id"), content: src.get("title"), time: src.get("time"), source: "HN",
                     kids: Util.intArrayToString(src.get("kids") ?? []) , other: (src.get("url") ?? ""))
    }

    convenience init(withV2Source src: JSON) throws {
        try self.init(cid: src.get("id"), content: src.get("title"), time: src.get("last_modified"), source: "V2",
                      kids: "", other:  src.get("content") ?? "")
    }
    
    convenience init(withV2Comments src: JSON, cid: String) throws {
        try self.init(cid: src.get("id"), content: src.get("content"), time: src.get("created"),
                      source: SourceType.V2comment.rawValue,
                      kids: "", other:   cid)
    }
    
    // MARK: Fluent Serialization

    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        cid = try row.get(Post.cidKey)
        content = try row.get(Post.contentKey)
        time = try row.get(Post.timeKey)
        source = try row.get(Post.sourceKey)
        kids = try row.get(Post.kidsKey)
        other = try row.get(Post.otherKey)
       
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.cidKey, cid)
         try row.set(Post.contentKey, content)
         try row.set(Post.timeKey, time)
         try row.set(Post.sourceKey, source)
         try row.set(Post.kidsKey, kids)
         try row.set(Post.otherKey, other)
        return row
    }
    
    
}
// MARK: Fluent Preparation

extension Post: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(Post.cidKey)
            builder.string(Post.contentKey)
//            builder.
            builder.string(Post.kidsKey)
            builder.string(Post.sourceKey)
            builder.string(Post.otherKey)
            builder.double(Post.timeKey)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            cid: json.get(Post.cidKey),
            content: json.get(Post.contentKey),
            time: json.get(Post.timeKey),
            source: json.get(Post.sourceKey),
             kids: json.get(Post.kidsKey),
              other: json.get(Post.otherKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.cidKey, cid)
        try json.set(Post.contentKey, content)
        try json.set(Post.timeKey, time)
        try json.set(Post.sourceKey, source)
        try json.set(Post.kidsKey, kids)
        try json.set(Post.otherKey , other)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Post: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Post: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Post.contentKey, String.self) { post, content in
                post.content = content
            }
        ]
    }
}
