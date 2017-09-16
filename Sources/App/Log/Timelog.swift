import Foundation

class Timelog  {
    private static var  startTime: TimeInterval?
    static func start() {
        let now = Date()
        startTime = now.timeIntervalSince1970
        print("start timer... ")
    }
    
    static func stop() {
        let now = Date()
        let endTime = now.timeIntervalSince1970
        let cost =  endTime - startTime!
        print("cost time: \(cost)")
    }
}
