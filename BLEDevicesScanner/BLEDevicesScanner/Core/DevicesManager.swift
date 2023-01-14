//
//  DevicesManager.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import Foundation
import CoreBluetooth
import Combine

enum BLEScanError: Error {
    case failedConnect, failedDiscoverServices, failedDiscoverChars
}

///DevicesManager: a service class used by UI
class DevicesManager: NSObject, ObservableObject {
    
    private var centralManager: CBCentralManager?
    
    private(set) var devicesDictionary = [CBUUID: CBPeripheral]()
    private let subjectDiscoveredDevices = PassthroughSubject<[CBPeripheral], Never>()
    private let subjectDiscoveredServices = PassthroughSubject<CBPeripheral, BLEScanError>()
    private let subjectDiscoveredChars = PassthroughSubject<CBService, Never>()
    public var cancellables = Set<AnyCancellable>()
    
    public private(set) var connectedDevice: CBPeripheral?
    
    deinit {
        cancellables.forEach { cncl in
            cncl.cancel()
        }
    }
    
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
    
    public func getServices(forDevice dev: CBPeripheral) -> AnyPublisher<CBPeripheral, BLEScanError> {
        centralManager?.connect(dev)
        return subjectDiscoveredServices.eraseToAnyPublisher()
    }
    
    public func getChars(forDevice dev: CBPeripheral, andService service: CBService) -> AnyPublisher<CBService, Never> {
        dev.discoverCharacteristics(nil, for: service)
        return subjectDiscoveredChars.eraseToAnyPublisher()
    }
}

extension DevicesManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("did discover peripheral - ", peripheral.identifier, peripheral.name as Any, peripheral.services as Any)
        print("advertisementData - ", advertisementData)
        
        if let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? Int, isConnectable == 1 {
            devicesDictionary[CBUUID(nsuuid: peripheral.identifier)] = peripheral
            subjectDiscoveredDevices.send(devicesDictionary.values.map({$0}))
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect - ", peripheral)
        
        connectedDevice = peripheral
        connectedDevice?.delegate = self
        connectedDevice?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect")
        connectedDevice = nil
        subjectDiscoveredServices.send(completion: .failure(.failedConnect))
    }
}

extension DevicesManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("did discover services - ", peripheral.services as Any)
        
        guard error == nil else {
            subjectDiscoveredServices.send(completion: .failure(.failedDiscoverServices))
            return
        }
        
        devicesDictionary[CBUUID(nsuuid: peripheral.identifier)] = peripheral
        subjectDiscoveredServices.send(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("did discover chars - ", service.characteristics as Any)
        
        subjectDiscoveredChars.send(service)
    }
}
