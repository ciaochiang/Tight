//
//  WearableDeviceMainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/15.
//

import SwiftUI

struct WearableDeviceMainView: View {
    @StateObject var viewModel: WearableDeviceMainViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    // Favorite Section
                    Section("Connected") {
                        HStack {
                            Image(systemName: "applewatch")
                            Text("Apple Watch")
                                .onTapGesture {
                                    // Connect or disconnect
                                }
                        }
                    }
                    
                    Section("Registered") {
                        ForEach(viewModel.registeredDevices, id: \.self) { device in
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Apple Watch")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        // Connect device
                                    }
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Devices")
            }
        }
    }
    
    func disconnectDevice(device: WearableDevice) {
        
    }
}

struct WearableDeviceMainView_Previews: PreviewProvider {
    static var previews: some View {
        
        let wearableDeviceManagerDependency = WearableDeviceManagerDependencyImp(logger: Mocks.logger)
        let wearableDeviceManager = WearableDeviceManager(dependency: wearableDeviceManagerDependency)
        let dependency = WearableDeviceMainViewModelDependencyImp(logger: Mocks.logger, wearableDeviceManager: wearableDeviceManager)
        let viewModel = WearableDeviceMainViewModel(dependency: dependency)
        WearableDeviceMainView(viewModel: viewModel, isPresented: .constant(false))
    }
}
