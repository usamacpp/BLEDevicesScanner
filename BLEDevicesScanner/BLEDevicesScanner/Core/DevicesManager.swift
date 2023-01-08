//
//  DevicesManager.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import Foundation
import CoreBluetooth
import Combine

struct BLEDevice: Identifiable {
    let id = UUID()
    
    let cbuuid: CBUUID
    let localName: String
    let peripheral: CBPeripheral
}

///DevicesManager: a service class used by UI
class DevicesManager: NSObject, ObservableObject {
    
    private var centralManager: CBCentralManager?
    
    private(set) var devicesDictionary = [CBUUID: CBPeripheral]()
    private let subjectDiscoveredDevices = PassthroughSubject<[CBPeripheral], Never>()
    public var cancellables = Set<AnyCancellable>()
    
    public func startScan() -> AnyPublisher<[CBPeripheral], Never> {
        if centralManager != nil {
            stop()
        }
        
        centralManager = CBCentralManager(delegate: self, queue: .main)
        
        return subjectDiscoveredDevices.eraseToAnyPublisher()
    }
    
    public func continueScan() -> AnyPublisher<[CBPeripheral], Never> {
        defer {
            subjectDiscoveredDevices.send(devicesDictionary.values.map({$0}))
        }
        
        return subjectDiscoveredDevices.eraseToAnyPublisher()
    }
    
    public func stop() {
        centralManager?.stopScan()
        centralManager = nil
        devicesDictionary.removeAll()
    }
    
    public func getServices(forDevice: CBUUID) {
        if let dev = devicesDictionary[forDevice] {
            centralManager?.connect(dev)
        }
    }
}

extension DevicesManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        } else if central.isScanning {
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("did discover peripheral - ", peripheral.identifier, peripheral.name as Any, peripheral.services as Any)
        print("advertisementData - ", advertisementData)
        
        devicesDictionary[CBUUID(nsuuid: peripheral.identifier)] = peripheral
        subjectDiscoveredDevices.send(devicesDictionary.values.map({$0}))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
}
