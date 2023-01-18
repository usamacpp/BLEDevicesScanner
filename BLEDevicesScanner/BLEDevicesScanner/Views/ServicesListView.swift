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
    @State private var error: BLEScanError?
    
    var body: some View {
        if error != nil {
            Text("connect failed")
        } else {
            VStack {
                Text(dev.description).background(Color.cyan).padding(5)
                List {
                    ForEach(services ?? [], id: \.self) { service in
                        NavigationLink(destination: CharsListView(dev: dev, service: service).environmentObject(devicesManager)) {
                            Text(service.description)
                        }
                    }
                }
            }.onAppear {
                discoverServices()
            }.navigationTitle(Text("Services"))
        }
    }
    
    private func discoverServices() {
        devicesManager.getServices(forDevice: dev).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                self.error = error
            case .finished:
                print("fnished")
            }
        }, receiveValue: { peripheral in
            services = peripheral.services
        }).store(in: &devicesManager.cancellables)
    }
}

//struct ServicesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServicesListView()
//    }
//}
