//
//  CharsListView.swift
//  BLEDevicesScanner
//
//  Created by ossama mikhail on 1/8/23.
//

import SwiftUI
import CoreBluetooth

struct CharsListView: View {
    @EnvironmentObject var devicesManager: DevicesManager
    public let dev: CBPeripheral
    public let service: CBService
    @State private var chars: [CBCharacteristic]?
    
    var body: some View {
        VStack {
            Text(dev.description).background(Color.cyan).padding(5)
            Text(service.description).background(Color.cyan).padding(5)
            
            if let chars {
                List {
                    ForEach(chars ?? [], id: \.self) { char in
                        Text(char.description)
                    }
                }
            } else {
                Text("No chars found!")
            }
        }.onAppear {
            discoverChars()
        }.navigationTitle(Text("Chars"))
    }
    
    private func discoverChars() {
        devicesManager.getChars(forDevice: dev, andService: service).sink { srvc in
            chars = srvc.characteristics
        }.store(in: &devicesManager.cancellables)
    }
}

//struct CharsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharsListView()
//    }
//}
