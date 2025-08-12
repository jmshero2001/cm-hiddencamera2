import Foundation

enum DeviceSource: String, Codable {
    case wifi
    case bluetooth
}

struct GeneralDevice: Hashable, Codable, Comparable {
    let id: UUID
    let name: String
    let ip: String
    let searchDate: Date
    let source: DeviceSource
    var isSecure: Bool

    init(fromWiFi device: WiFiDevice) {
        self.id = device.id
        self.name = device.hostName
        self.ip = device.ip
        self.searchDate = device.searchDate
        self.source = .wifi
        self.isSecure = !(device.type == .camera)
    }

    init(fromBluetooth device: BluetoothDevice) {
        self.id = device.id
        self.name = device.name
        self.ip = "Unknown IP"
        self.searchDate = device.searchedDate
        self.source = .bluetooth
        self.isSecure = false
    }

    static func == (lhs: GeneralDevice, rhs: GeneralDevice) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func < (lhs: GeneralDevice, rhs: GeneralDevice) -> Bool {
        lhs.name < rhs.name
    }
}
