import Foundation

class Timelog  {
    private static var  startTime: TimeInterval?
    private static var  dict: [String: TimeInterval] = [:]
    static func start(_ flag: String = "") {
        let now = Date()
        if flag == "" {
            startTime = now.timeIntervalSince1970
        } else {
            dict[flag] = now.timeIntervalSince1970
        }
        
        
        
        print("start timer \(flag)  ...  ")
    }
    
    static func stop(_ flag: String = "") {
        let now = Date()
        let endTime = now.timeIntervalSince1970
        let startPoint: TimeInterval
        if flag == "" {
            startPoint = startTime!
        } else {
            startPoint = dict[flag]!
        }
        
        let cost =  endTime - startPoint
        print("cost time for \(flag) : \(cost)")
    }
}
