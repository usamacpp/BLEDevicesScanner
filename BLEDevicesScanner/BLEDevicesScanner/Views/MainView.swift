//
//  MainView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import SwiftUI
import Combine

struct MainView: View {
    @EnvironmentObject var devicesManager: DevicesManager
    
    var body: some View {
        NavigationStack {
            NavigationLink("BLE devices list", destination: DevicesListView().environmentObject(devicesManager))
        }.onAppear {
            startScan()
        }
    }
    
    private func startScan() {
        devicesManager.startScan()
        .sink { devs in
            print("sink#1 dev - ", devs.count)
        }.store(in: &devicesManager.cancellables)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
