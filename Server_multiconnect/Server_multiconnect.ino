#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint8_t value = 0;

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
const int redPin = 21;    // Pino para LED vermelho
const int greenPin = 22;  // Pino para LED verde
const int bluePin = 23;   // Pino para LED azul
const int dcmotor =  4;
const int dcmotor2 =  5;
// Função para definir a cor do LED RGB
void setColor(int red, int green, int blue) {
    // Garante que os valores estejam dentro do intervalo permitido (0-255)
    red = constrain(red, 0, 255);
    green = constrain(green, 0, 255);
    blue = constrain(blue, 0, 255);

    // Define a intensidade das cores usando PWM
    analogWrite(redPin, red);
    analogWrite(greenPin, green);
    analogWrite(bluePin, blue);
}
// Callback para quando o cliente se conecta ou desconecta
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    BLEDevice::startAdvertising();
    Serial.println(F("Cliente conectado"));
  };

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println(F("Cliente desconectado"));
  }
};

// Callback para quando o cliente envia dados (write)
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {  
    String ledligar = String("ledligar");
    
    String desligarled = "desligarled";
    String motorleft = "motorledt";
    String motorRight = "motorright";
    String motoroff = "motoroff";
    String value = pCharacteristic->getValue();
    value.trim();
    Serial.println("Conteúdo recebido:");
    for (int i = 0; i < value.length(); i++) {
      char c = value[i];
      Serial.print("Caractere");
      Serial.print(i);
      Serial.print(": '");
      Serial.print(c);
      Serial.print("' (Código ASCII: ");
      Serial.print((int)c);
      Serial.println(")");
    }
    //setColor(255, 0, 255);
    if(value.compareTo(ledligar) == 0){
      Serial.print("led ligar");
      setColor(255, 0, 255); //magenta
      pCharacteristic->setValue("Mensagem recebida!");
      pCharacteristic->notify();
    }
    
    else if(value.compareTo(desligarled) == 0){
      Serial.print(F("led desligar"));
      setColor(0, 0, 0); //nada
      pCharacteristic->setValue("Mensagem recebida!");
      pCharacteristic->notify();
    }
    else if(value.compareTo(motorleft) == 0){
      digitalWrite(dcmotor2, 0);
      delay(1000);
      digitalWrite(dcmotor, 1); // turns on the motor
      pCharacteristic->setValue("Mensagem recebida!");
      pCharacteristic->notify();
    }
    else if(value.compareTo(motorRight) == 0){
      digitalWrite(dcmotor, 0);
      delay(100);
      digitalWrite(dcmotor2, 1); // turns on the motor
      pCharacteristic->setValue("Mensagem recebida!");
      pCharacteristic->notify();
    }
    else if(value.compareTo(motoroff) == 0){
      digitalWrite(dcmotor, 0); // turns off the motor
      delay(100);
      digitalWrite(dcmotor2, 0); // turns off the motor
      pCharacteristic->setValue("Mensagem recebida!");
      pCharacteristic->notify();
    }
  }
};

void setup() {
  pinMode(dcmotor, OUTPUT);
  pinMode(dcmotor2, OUTPUT);
  Serial.begin(115200);

  // Cria o dispositivo BLE
  BLEDevice::init("ESP32_ble_test");

  // Cria o servidor BLE
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Cria o serviço BLE
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Cria uma característica BLE
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY |
    BLECharacteristic::PROPERTY_INDICATE
  );

  // Associa o callback para tratar os dados recebidos do cliente
  pCharacteristic->setCallbacks(new MyCallbacks());

  // Cria um descritor BLE
  pCharacteristic->addDescriptor(new BLE2902());

  // Inicia o serviço
  pService->start();

  // Inicia a publicidade
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x0);  // Defina como 0x00 para não anunciar este parâmetro
  BLEDevice::startAdvertising();
  Serial.println(F("Aguardando conexão do cliente..."));
 
}

void loop() {
  // Envia notificação de valor atualizado
  if (deviceConnected) {
    pCharacteristic->setValue((uint8_t *)&value, 4);
    pCharacteristic->notify();
    value++;
    delay(10);  // Evita congestionamento ao enviar muitas notificações
  }

  // Se o dispositivo se desconectar
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);                   // Dê tempo para a stack de BLE se preparar
    pServer->startAdvertising();  // Reinicia a publicidade
    Serial.println("Reiniciando publicidade");
    oldDeviceConnected = deviceConnected;
  }
  
  // Se o dispositivo se conectar
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
}
