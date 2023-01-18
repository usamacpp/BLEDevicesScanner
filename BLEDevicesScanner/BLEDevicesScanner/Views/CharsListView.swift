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
    @State private var error: BLEScanError?
    
    var body: some View {
        VStack {
            Text(dev.description).background(Color.cyan).padding(5)
            Text(service.description).background(Color.cyan).padding(5)
            
            if let chars {
                List {
                    ForEach(chars, id: \.self) { char in
                        Text(char.description)
                    }
                }
            } else {
                Text("No chars found!")
            }
        }.onAppear {
            discoverChars()
        }.onDisappear {
            devicesManager.cleanLastCancellable()
        }.navigationTitle(Text("Chars"))
    }
    
    private func discoverChars() {
//        devicesManager.getChars(forDevice: dev, andService: service).sink { srvc in
//            chars = srvc.characteristics
//        }.store(in: &devicesManager.cancellables)
        
        devicesManager.getChars(forDevice: dev, andService: service).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                self.error = error
            case .finished:
                print("fnished")
            }
        }, receiveValue: { srvc in
            chars = srvc.characteristics
        }).store(in: &devicesManager.cancellables)
    }
}

//struct CharsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharsListView()
//    }
//}
