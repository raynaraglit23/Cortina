
import SwiftUI
import CoreBluetooth

struct Connection: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack {
         
            // Lista de dispositivos BLE descobertos
            if bluetoothManager.isBluetoothEnabled {
                Text("Lista de Dispositivos BLE")
                    .foregroundColor(.gray)
                    .padding()
                List(bluetoothManager.discoveredPeripherals.filter { $0.name != nil && $0.name != "Unknown" }, id: \.identifier) { peripheral in
                    Button(action: {
                        bluetoothManager.connectToDevice(peripheral)
                    }) {
                        Text(peripheral.name ?? "Unknown")
                    }
                }
            }
            else {
                Text("Ligue o Bluetooth para ver dispositivos próximos")
                    .foregroundColor(.gray)
                    //.padding()
            }
            
            if let connectedPeripheral = bluetoothManager.connectedPeripheral {
                Text("Conectado com \(connectedPeripheral.name ?? "Desconhecido")")
                    .padding()
                
//                // Campo de texto para enviar mensagem ao ESP32
//                TextField("Digite o texto para enviar", text: $bluetoothManager.textToSend)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button("Enviar para ESP32") {
//                    bluetoothManager.sendMessageToESP(bluetoothManager.textToSend)
//                }
//                .padding()
            }
            else {
                Text("Desconectado") // Exibe "Desconectado" se não houver conexão
                                .padding()
                                .foregroundColor(.red) // Você pode adicionar uma cor diferente se quiser
                        }
            
        }
        .padding(.top, 100)
    }
}

#Preview {
    Connection(bluetoothManager: BluetoothManager())
}
