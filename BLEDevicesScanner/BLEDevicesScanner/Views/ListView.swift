//
//  ListView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import SwiftUI
import Combine
import CoreBluetooth

struct ListView: View {
    @EnvironmentObject var devicesManager: DevicesManager
    @State var list: [CBPeripheral]?
    
    var body: some View {
        Spacer(minLength: 0)
        VStack {
            List {
                ForEach(list ?? [], id: \.self) { dev in
                    Text(dev.name ?? "N/A" + " - " + dev.identifier.uuidString)
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
            list = devs
        }.store(in: &devicesManager.cancellables)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
