import UIKit

final class WiFiDevice: Hashable, Codable, Comparable {
    let id: UUID
    let hostName: String
    let ip: String
    var services: [String]
    var type: DeviceType
    let searchDate: Date
    
    var isSecure: Bool {
        type != .camera || type != .undefined
    }
    
    init(services: [String], ip: String, hostName: String) {
        self.id = UUID()
        self.services = services
        self.ip = ip
        self.hostName = hostName
        self.type = .undefined
        self.searchDate = Date()
    }
    
    init(services: [String], ip: String, hostName: String, type: DeviceType) {
        self.id = UUID()
        self.services = services
        self.ip = ip
        self.hostName = hostName
        self.type = type
        self.searchDate = Date()
    }
    
    static func == (lhs: WiFiDevice, rhs: WiFiDevice) -> Bool {
        lhs.ip == rhs.ip && lhs.hostName == rhs.hostName
    }
    
    static func < (lhs: WiFiDevice, rhs: WiFiDevice) -> Bool {
        lhs.hostName < rhs.hostName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ip)
    }
    
}

enum DeviceType: Int, CaseIterable, Hashable, Codable {
    case phone = 1
    case camera
    case headphones
    case speaker
    case tv
    case printer
    case home
    case mouse
    case pc
    case networkDevice
    case undefined
    case other
    
    var name: String {
        switch self {
        case .phone:
            NSLocalizedString("Phone", comment: "")
        case .camera:
            NSLocalizedString("Camera", comment: "")
        case .headphones:
            NSLocalizedString("Headphones", comment: "")
        case .speaker:
            NSLocalizedString("Speaker", comment: "")
        case .tv:
            NSLocalizedString("TV", comment: "")
        case .printer:
            NSLocalizedString("Printer", comment: "")
        case .home:
            NSLocalizedString("Home Accessory", comment: "")
        case .mouse:
            NSLocalizedString("Mouse", comment: "")
        case .pc:
            NSLocalizedString("Personal Computer", comment: "")
        case .networkDevice:
            NSLocalizedString("Network Device", comment: "")
        case .undefined:
            NSLocalizedString("Undefined", comment: "")
        case .other:
            NSLocalizedString("Other", comment: "")
        }
    }
}

enum WiFiAvailable {
    case available
    case notAvailable
}

struct WiFiData {
    var name: String?
    var ip: String?
}


struct DeviceAttributeModel: Hashable {
    let title: String
    let subtitle: String
    let hasSeparator: Bool
    
    init(title: String, subtitle: String, hasSeparator: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.hasSeparator = hasSeparator
    }
}

enum ConnectionDenideType {
    case local
    case wifi
}
