//
//  Esp.c
//  Bluetooth Connection
//
//  Created by Raynara Coelho on 01/09/24.
//
//
//#include "Esp.h"
//
//void setup() {
//  BLEDevice::init("ESP32");
//  BLEServer *pServer = BLEDevice::createServer();
//  
//  BLEService *pService = pServer->createService(SERVICE_UUID);
//  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
//                      CHARACTERISTIC_UUID,
//                      BLECharacteristic::PROPERTY_WRITE
//                    );
//  
//  pCharacteristic->setCallbacks(new MyCallbacks());
//  pService->start();
//}
//
//class MyCallbacks: public BLECharacteristicCallbacks {
//    void onWrite(BLECharacteristic *pCharacteristic) {
//        std::string receivedData = pCharacteristic->getValue();
//        Serial.println("Received: " + String(receivedData.c_str()));
//    }
//};
//
//#include <BluetoothSerial.h>
//
//BluetoothSerial SerialBT;
//const int ledPin = 2;  // Pin do LED
//const int motorPin1 = 12; // Pin do motor para movimento à esquerda
//const int motorPin2 = 13; // Pin do motor para movimento à direita
//
//void setup() {
//  pinMode(ledPin, OUTPUT);
//  pinMode(motorPin1, OUTPUT);
//  pinMode(motorPin2, OUTPUT);
//  
//  Serial.begin(115200);
//  SerialBT.begin("ESP32-Curtain"); // Nome do dispositivo Bluetooth
//  Serial.println("O dispositivo Bluetooth foi iniciado, agora você pode emparelhar!");
//}
//
//void loop() {
//  if (SerialBT.available()) {
//    String command = SerialBT.readStringUntil('\n');
//    command.trim(); // Remove espaços extras ou quebras de linha
//
//    if (command == "MOVE_LEFT") {
//      moveLeft();
//    } else if (command == "MOVE_RIGHT") {
//      moveRight();
//    } else if (command.startsWith("LED_ON_")) {
//      String color = command.substring(7); // Pega a cor após "LED_ON_"
//      turnOnLed(color);
//    } else if (command == "LED_OFF") {
//      turnOffLed();
//    }
//  }
//}
//
//void moveLeft() {
//  digitalWrite(motorPin1, HIGH);
//  digitalWrite(motorPin2, LOW);
//  delay(1000); // Movimenta por 1 segundo
//  stopMotor();
//}
//
//void moveRight() {
//  digitalWrite(motorPin1, LOW);
//  digitalWrite(motorPin2, HIGH);
//  delay(1000); // Movimenta por 1 segundo
//  stopMotor();
//}
//
//void stopMotor() {
//  digitalWrite(motorPin1, LOW);
//  digitalWrite(motorPin2, LOW);
//}
//
//void turnOnLed(String color) {
//  // Exemplo de controle de LED RGB ou LED simples com base na cor
//  if (color == "RED") {
//    analogWrite(ledPin, 255);  // Define a intensidade do LED vermelho
//  } else if (color == "GREEN") {
//    analogWrite(ledPin, 255);  // Define a intensidade do LED verde
//  } else if (color == "BLUE") {
//    analogWrite(ledPin, 255);  // Define a intensidade do LED azul
//  }
//}
//
//void turnOffLed() {
//  analogWrite(ledPin, 0);  // Desliga o LED
//}
