//
//  V1.swift
//  testSwift4PackageDescription
//
//  Created by certainly on 2017/9/16.
//

import Foundation
import Vapor

class V1: RouteCollection {
    let drop: Droplet!
    func build(_ builder: RouteBuilder) throws {
        let v1 = builder.grouped("api", "v1")
        let posts = v1.grouped("posts")
        let postController = PostController()
        postController.setDroplet(drop: drop)
        postController.addRoutes(to: posts)
        
        
    }
    
    init(drop: Droplet) {
        
        self.drop = drop
    }
    
    
}
