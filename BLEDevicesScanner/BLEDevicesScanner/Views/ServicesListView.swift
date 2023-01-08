//
//  ServicesListView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/8/23.
//

import SwiftUI
import CoreBluetooth
import Combine

struct ServicesListView: View {
    @EnvironmentObject var devicesManager: DevicesManager
    public let dev: CBPeripheral
    @State private var services: [CBService]?
    
    var body: some View {
        List {
            ForEach(services ?? [], id: \.self) { service in
                NavigationLink(destination: CharsListView(dev: dev, service: service).environmentObject(devicesManager)) {
                    Text(service.description)
                }
            }
        }.onAppear {
            discoverServices()
        }
    }
    
    private func discoverServices() {
        devicesManager.getServices(forDevice: dev).sink { peripheral in
            services = peripheral.services
        }.store(in: &devicesManager.cancellables)
    }
}

//struct ServicesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServicesListView()
//    }
//}
