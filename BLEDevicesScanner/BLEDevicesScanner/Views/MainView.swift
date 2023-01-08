//
//  MainView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/7/23.
//

import SwiftUI
import Combine

struct MainView: View {
    private let devicesManager = DevicesManager.shared
//    private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            NavigationLink("BLE devices list", destination: ListView().environmentObject(devicesManager))
        }
    }
    
    init() {
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
