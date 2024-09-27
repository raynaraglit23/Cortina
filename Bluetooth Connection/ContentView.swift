import SwiftUI

struct ContentView: View {
    
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        TabView {
            CurtainView(bluetoothManager: bluetoothManager)
                .tabItem {
                    Label("curtains", systemImage: "curtains.closed")
                        .foregroundColor(.square)
                }
                .environmentObject(bluetoothManager)
            Connection(bluetoothManager: bluetoothManager)
                .tabItem {
                    Label("connection", systemImage: "bonjour")
                        .foregroundColor(.square)
                    
                }
                .environmentObject(bluetoothManager)
        }
        .padding(.top, -100)
    }
    
}

#Preview {
    ContentView()
}
