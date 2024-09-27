//
//  Bluetooth_ConnectionApp.swift
//  Bluetooth Connection
//
//  Created by Raynara Coelho on 19/08/24.
//

import SwiftUI

@main

struct Bluetooth_ConnectionApp: App {
    
    @StateObject var bluetoothManager = BluetoothManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
