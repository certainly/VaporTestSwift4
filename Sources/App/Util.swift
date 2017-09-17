//
//  Util.swift
//  testSwift4PackageDescription
//
//  Created by certainly on 2017/9/17.
//

import Foundation

class Util {
    static func intArrayToString(_ arr: [Int]) -> String {
     
        if arr.count == 0 {
            return ""
        }
        return (arr.map{String(Int($0))}).joined(separator: ",")
    }
}
