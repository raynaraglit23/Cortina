import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isBluetoothEnabled : Bool = true
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var textToSend = ""
    @Published var isConnected = false
    @Published var batteryLevel: Int = 0 // Valor inicial de bateria (ajustável)
    
    private var centralManager: CBCentralManager!
    private var writeCharacteristic: CBCharacteristic?
    private var batteryCharacteristic: CBCharacteristic? // Característica de bateria
    private var characteristic: CBCharacteristic?
    
    let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    let batteryServiceUUID = CBUUID(string: "180F")
    let batteryLevelCharacteristicUUID = CBUUID(string: "2A19")
        
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Método que é chamado quando o estado do Bluetooth muda
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .poweredOn:
                isBluetoothEnabled = true
                startScanning() // Inicia o escaneamento automaticamente
            case .poweredOff, .unauthorized, .unsupported, .unknown, .resetting:
                isBluetoothEnabled = false
                if let connectedPeripheral = connectedPeripheral {
                    disconnectFromDevice(connectedPeripheral)
                }
                stopScanning() // Para o escaneamento se o Bluetooth estiver desligado
            @unknown default:
                isBluetoothEnabled = false
            }
        }

    // Inicia o escaneamento de dispositivos BLE
        func startScanning() {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }

        // Para o escaneamento de dispositivos BLE
        func stopScanning() {
            centralManager.stopScan()
            discoveredPeripherals.removeAll()
        }
    
    func disconnectFromDevice(_ peripheral: CBPeripheral) {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil // Atualiza o estado da conexão
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Adicionar periféricos descobertos à lista
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Conectado ao dispositivo: \(peripheral.name ?? "Desconhecido")")
        isConnected = true // Atualiza o status de conexão
        peripheral.discoverServices([serviceUUID, batteryServiceUUID]) // Descobre os serviços, incluindo o de bateria
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Falha ao conectar ao dispositivo: \(error?.localizedDescription ?? "Erro desconhecido")")
        isConnected = false // Atualiza o status de conexão em caso de falha
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Erro ao descobrir serviços: \(error.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service) // Descobre a característica específica
            } else if service.uuid == batteryServiceUUID {
                peripheral.discoverCharacteristics([batteryLevelCharacteristicUUID], for: service) // Descobre a característica de nível de bateria
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Erro ao descobrir características: \(error.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == characteristicUUID {
                writeCharacteristic = characteristic
                print("Característica de escrita encontrada")
            } else if characteristic.uuid == batteryLevelCharacteristicUUID {
                batteryCharacteristic = characteristic
                peripheral.readValue(for: characteristic) // Lê o valor da bateria ao descobrir a característica
            }
        }
    }
  
    func sendSliderValues(sliderValue1: Double, sliderValue2: Double) {
        guard let connectedPeripheral = connectedPeripheral,
              let characteristic = characteristic else {
            print("Não há dispositivo conectado ou característica disponível.")
            return
        }

        // Crie um pacote de dados para enviar como string formatada
        let message = "\(sliderValue1),\(sliderValue2)"
        
        // Converta a string em Data
        if let data = message.data(using: .utf8) {
            // Envie os dados para o ESP32
            connectedPeripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Mensagem enviada: \(message)")
        } else {
            print("Erro ao converter a mensagem para Data.")
        }
    }

    
    // Atualiza o valor da bateria quando a característica muda
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Erro ao ler valor da característica: \(error.localizedDescription)")
            return
        }
        
        if characteristic.uuid == batteryLevelCharacteristicUUID, let batteryData = characteristic.value {
            let batteryLevel = batteryData.first ?? 0
            DispatchQueue.main.async {
                self.batteryLevel = Int(batteryLevel) // Atualiza o nível de bateria
            }
            print("Nível de bateria: \(batteryLevel)%")
        }
    }

    func sendMessageToESP(_ message: String) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            print("Periférico ou característica de escrita não encontrados")
            return
        }

        if let data = message.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Mensagem enviada: \(message)")
        }
    }
    
    // Funções específicas para cada comando
    func ligarLed() {
        sendMessageToESP("ledligar")
    }
    
    func desligarLed() {
        sendMessageToESP("desligarled")
    }
    
    func moverMotorEsquerda() {
        sendMessageToESP("motorledt")
    }
    
    func moverMotorDireita() {
        sendMessageToESP("motorright")
    }
    
    func desligarMotor() {
        sendMessageToESP("motoroff")
    }

    func attemptConnection() async {
        if let peripheral = connectedPeripheral {
            print("Já conectado ao periférico: \(peripheral.name ?? "Desconhecido")")
            return
        }

        if let peripheral = discoveredPeripherals.first {
            print("Tentando conectar ao periférico: \(peripheral.name ?? "Desconhecido")")
            connectToDevice(peripheral)
        } else {
            print("Nenhum periférico disponível para conexão")
        }
    }

//    func toggleBluetooth() {
//        if isBluetoothEnabled {
//            // Bluetooth está ligado, então vamos desligá-lo
//            centralManager?.stopScan()
//            isBluetoothEnabled = false
//            
//            // Desconectar o dispositivo se houver um conectado
//            if let peripheral = connectedPeripheral {
//                centralManager?.cancelPeripheralConnection(peripheral)
//                connectedPeripheral = nil
//                isConnected = false
//                print("Dispositivo desconectado")
//            }
//        } else {
//            // Bluetooth está desligado, então vamos ligá-lo
//            centralManager?.scanForPeripherals(withServices: nil, options: nil)
//            isBluetoothEnabled = true
//        }
//    }

    // Função para atualizar o nível de bateria sob demanda
    func updateBatteryLevel() {
        if let peripheral = connectedPeripheral, let characteristic = batteryCharacteristic {
            peripheral.readValue(for: characteristic)
        }
    }
}
