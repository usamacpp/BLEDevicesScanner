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
        if let error {
            switch error {
            case .failedConnect:
                Text("connect failed")
            case .failedDiscoverServices:
                Text("No services found!")
            case .failedDiscoverChars:
                Text("Unknown error!")
            }
        } else {
            VStack {
                Text(dev.description).background(Color.cyan).padding(5)
                List {
                    if let services {
                        ForEach(services, id: \.self) { service in
                            NavigationLink(destination: CharsListView(dev: dev, service: service).environmentObject(devicesManager)) {
                                Text(service.description)
                            }
                        }
                    } else {
                        Text("No services found!")
                    }
                }
            }.onAppear {
                connectDevice()
            }.onDisappear {
                if let error {
                    if error == .failedConnect {
                        devicesManager.cleanLastCancellable()
                    } else {
                        devicesManager.cleanLast2Cancellables()
                    }
                } else {
                    devicesManager.cleanLast2Cancellables()
                }
            }.navigationTitle(Text("Services"))
        }
    }
    
    private func connectDevice() {
        devicesManager.connect(withDevice: dev).sink { completion in
            switch completion {
            case .failure(let error):
                self.error = error
            case .finished:
                print("fnished")
            }
        } receiveValue: { peripheral in
            error = nil
            discoverServices()
        }.store(in: &devicesManager.cancellables)

    }
    
    private func discoverServices() {
        devicesManager.getServices(forDevice: dev).sink { completion in
            switch completion {
            case .failure(let error):
                self.error = error
            case .finished:
                print("fnished")
            }
        } receiveValue: { peripheral in
            services = peripheral.services
        }.store(in: &devicesManager.cancellables)
    }
}

//struct ServicesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServicesListView()
//    }
//}
