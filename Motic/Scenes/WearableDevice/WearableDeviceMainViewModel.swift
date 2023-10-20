//
//  WearableDeviceMainViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/15.
//

import SwiftUI
import Combine

protocol WearableDeviceMainViewModelDependency {
    var logger: CustomLogger { get }
    var wearableDeviceManager: WearableDeviceManager { get }
}

class WearableDeviceMainViewModelDependencyImp: WearableDeviceMainViewModelDependency {
    var logger: CustomLogger
    var wearableDeviceManager: WearableDeviceManager
    
    init(logger: CustomLogger, wearableDeviceManager: WearableDeviceManager) {
        self.logger = logger
        self.wearableDeviceManager = wearableDeviceManager
    }
}

class WearableDeviceMainViewModel: ObservableObject {
    var dependency: WearableDeviceMainViewModelDependency
    @ObservedObject var wearableDeviceManager: WearableDeviceManager
    
    @Published var isDeviceConneted: Bool = false
    @Published var connectedDevice: WearableDevice?
    @Published var registeredDevices: [WearableDevice] = []
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    init(dependency: WearableDeviceMainViewModelDependency) {
        self.dependency = dependency
        _wearableDeviceManager = ObservedObject(wrappedValue: dependency.wearableDeviceManager)
        
        wearableDeviceManager.$isDeviceConnected.sink { isConnected in
            self.isDeviceConneted = isConnected
        }.store(in: &cancellables)
        
        wearableDeviceManager.$registeredDevices.sink { devices in
            self.registeredDevices = devices
        }
        .store(in: &cancellables)
        
        wearableDeviceManager.$connectedDevice.sink { device in
            self.connectedDevice = device
        }.store(in: &cancellables)
    }
}
