import CoreBluetooth

/**
 https://habr.com/ru/company/raiffeisenbank/blog/452278/
 
 https://www.bluetooth.com/specifications/gatt/services/
 */
final class BluetoothManager: NSObject {
    
    private let serviceUUID = CBUUID(string: "A3E424F7-A3F2-4147-9EE2-3FD44656F29A")
    private let userInfoCharacteristicUUID = CBUUID(string: "7CB2A626-808B-498C-BA9C-89869CDF520E")
    private let sendInfoCharacteristicUUID = CBUUID(string: "A5148E54-CE2F-40E3-B1A9-F131F3B099C5")
    
    private lazy var peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    private lazy var centralManager = CBCentralManager(delegate: self, queue: nil)
    
    private var availablePeripheral = [CBPeripheral]()
    
    func start() {
        _ = peripheralManager
        _ = centralManager
    }
    
    func send(text: String, peripheral: CBPeripheral) {
        
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        guard peripheral.state == .poweredOn else {
            print(peripheral.state.rawValue)
            return
        }
        
        //        let userInfoData = "userInfoData".data(using: .utf8)
        //        let sendInfoData = "sendInfoData".data(using: .utf8)
        
        let userInfoCharacteristic = CBMutableCharacteristic(type: userInfoCharacteristicUUID,
                                                             properties: .read,
                                                             value: nil,
                                                             permissions: .readable)
        let sendInfoCharacteristic = CBMutableCharacteristic(type: sendInfoCharacteristicUUID,
                                                             properties: .write,
                                                             value: nil,
                                                             permissions: .writeable)
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [userInfoCharacteristic, sendInfoCharacteristic]
        
        peripheralManager.add(service)
        //peripheralManager.stopAdvertising()
        
        let advertisingData: [String: Any] = [CBAdvertisementDataLocalNameKey: peripheralName,
                                              CBAdvertisementDataServiceUUIDsKey: [serviceUUID]]
        peripheralManager.startAdvertising(advertisingData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        requests
            .filter { $0.characteristic.uuid == sendInfoCharacteristicUUID }
            .forEach { request in
                peripheralManager.respond(to: request, withResult: .success)
                
                print(request.characteristic.value ?? "nil")
                print(request.value ?? "nil")
                guard let data = request.value, let text = String(data: data, encoding: .utf8) else {
                    assertionFailure()
                    return
                }
                print(text)
        }
    }
    
    /// background mode
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//
//    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        /// https://stackoverflow.com/a/23604387
        guard central.state == .poweredOn else {
            print(central.state.rawValue)
            return
        }
        
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("found name: ", peripheral.name ?? "nil")
        availablePeripheral.append(peripheral)
        //central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    //    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    //
    //    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?
            .filter { $0.uuid == serviceUUID }
            .forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?
            .filter { $0.uuid == userInfoCharacteristicUUID }
            .forEach { peripheral.readValue(for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let text = String(data: data, encoding: .utf8) else {
            return
        }
        print(text)
    }
}
