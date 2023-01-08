//
//  BLEDevicesScannerApp.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import SwiftUI

@main
struct BLEDevicesScannerApp: App {
    let devmngr = DevicesManager()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(devmngr)
        }
    }
}
