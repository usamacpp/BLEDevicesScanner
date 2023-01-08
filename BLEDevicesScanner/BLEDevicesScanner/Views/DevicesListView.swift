//
//  DevicesListView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import SwiftUI
import Combine
import CoreBluetooth

struct DevicesListView: View {
    @EnvironmentObject var devicesManager: DevicesManager
    @State private var devList: [CBPeripheral]?
    
    var body: some View {
        Spacer(minLength: 0)
        VStack {
            List {
                ForEach(devList ?? [], id: \.self) { dev in
                    DeviceCell(dev: dev).environmentObject(devicesManager)
                }
            }
            
        }.navigationTitle(Text("devices"))
            .onAppear {
                continueScan()
            }
    }
    
    private func continueScan() {
        devicesManager.continueScan().sink { devs in
            print("sink#2 devs - ", devs.count)
            devList = devs
        }.store(in: &devicesManager.cancellables)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesListView()
    }
}
