import UIKit

enum ObStep: Int {
    
    case first = 0
    case second
    case third
    
    case paywall
    
    var title: String {
        switch self {
        case .first:
            "Welcome to our app\nDevice finder"
        case .second:
            "Stay Safe with the app\nFind lost devices"
        case .third:
            "Save and check your\nfounded devices"
        case .paywall:
            ""
        }
    }
    
    var subtitle: String {
        switch self {
        case .first:
            "Check your surroundings for devices with Device Finder mobile application"
        case .second:
            "Use Bluetooth and Wi-Fi for searching\nDetect wireless devices anywhere"
        case .third:
            "Check what devices ware found\nusing powerful app features"
        case .paywall:
            ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .first:
            UIImage(named: "ob1")
        case .second:
            UIImage(named: "ob2")
        case .third:
            UIImage(named: "ob3")
        case .paywall:
            UIImage(named: "paywall")
        }
    }
    
    mutating func next() {
        switch self {
        case .first:
            self = .second
        case .second:
            self = .third
        case .third:
            self = .paywall
        case .paywall:
            self = .paywall
        }
    }
}
