import CoreBluetooth
import UIKit

struct BluetoothDevice: Hashable {
    let id: UUID
    let name: String
    let distance: String
    let searchedDate: Date
    var peripheral: CBPeripheral?
}
