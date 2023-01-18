//
//  DeviceCell.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/8/23.
//

import SwiftUI
import CoreBluetooth

struct DeviceCell: View {
    @EnvironmentObject var devicesManager: DevicesManager
    var dev: CBPeripheral?
    
    var body: some View {
        if let dev {
            NavigationLink(destination: ServicesListView(dev: dev).environmentObject(devicesManager)) {
                Text(dev.description)
            }
        }
    }
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        DeviceCell()
    }
}
