import Foundation
import SwiftUI

struct CurtainView: View {
    @State private var slider: Double = 1
    @State private var slider2: Double = -1
    @State private var selectedButton: Int? = nil
    @ObservedObject var bluetoothManager: BluetoothManager// Bluetooth manager para enviar dados

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Color("background")
                    .ignoresSafeArea()
                VStack {
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                            .frame(width: 400, height: 430)
                            .foregroundColor(.square)
                        HStack {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Button(action: {
                                Task {
                                    await bluetoothManager.attemptConnection()
                                }
                            }, label: {
                                if let _ = bluetoothManager.connectedPeripheral {
                                    Text("Conectado")
                                } else {
                                    Text("Desconectado")
                                }
                            })
                            
                            Spacer()
                            Image(systemName: "battery.100percent")
                            Text("\(bluetoothManager.batteryLevel)%")
                        }
                        .frame(width: 300)
                        .padding(.bottom, 380)
                        HStack {
                            if let connectedPeripheral = bluetoothManager.connectedPeripheral {
                                Text("\(connectedPeripheral.name ?? "Desconhecido")")
                                    .padding()
                                Image(systemName: "chevron.down")
                            }
                            
                        }
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .padding(.bottom, 350)
                        ZStack {
                            Image("trilho")
                                .padding(.bottom, 260)
                            
                                //.scaledToFit()
                            HStack {
                                Image("lado_cortina")
                                    //.resizable()
                                    .scaledToFit()
                                    .frame(width: 300)
                                    .offset(x: CGFloat(slider) * 70)
                                    .animation(.easeInOut, value: slider)
                                Image("lado_cortina")
                                    //.resizable()
                                    .scaledToFit()
                                    .frame(width: 300)
                                    .offset(x: CGFloat(slider2) * 70)
                                    .animation(.easeInOut, value: slider)
                            }
                            .padding(.top, 50)
                        }
                        
                        
                                                        
                                                        
                    }
                    
                    // Sliders para controle gradual
                    HStack {
                        Slider(value: $slider, in: -1...1, onEditingChanged: { _ in
                            //bluetoothManager.sendSliderValue(sliderValue: slider)
                        })
                        .frame(width: 170)
                        .accentColor(.gray)
                        
                        Slider(value: $slider2, in: -1...1, onEditingChanged: { _ in
                            //bluetoothManager.sendSliderValue(sliderValue: slider)
                        })
                        .frame(width: 170)
                        .accentColor(.gray)
                        
                        
//                        Slider(value: $slider, in: -1...1, onEditingChanged: { _ in
//                                            // Envie os valores para o BluetoothManager
//                                            bluetoothManager.sendSliderValues(sliderValue1: slider, sliderValue2: slider2)
//                                        })
//                                        .frame(width: 170)
//                                        .accentColor(.gray)
//
//                                        Slider(value: $slider2, in: -1...1, onEditingChanged: { _ in
//                                            // Envie os valores para o BluetoothManager
//                                            bluetoothManager.sendSliderValues(sliderValue1: slider, sliderValue2: slider2)
//                                        })
                    }
                    
                    // Botões de controle
                    HStack {
                        ZStack {
                            Button {
                                bluetoothManager.moverMotorEsquerda()
                            } label: {
                                Circle()
                                    .scaledToFill()
                            }
                            Image(systemName: "curtains.open")
                                .foregroundColor(.background)
                            
                        }
                        ZStack {
                            Button {
                                bluetoothManager.desligarMotor()
                            } label: {
                                Circle()
                                    .scaledToFill()
                            }
                            Image(systemName: "pause.fill")
                                .foregroundColor(.background)
                        }
                        
                        ZStack {
                            Button {
                                bluetoothManager.moverMotorDireita()
                            } label: {
                                Circle()
                                    .scaledToFill()
                            }
                            Image(systemName: "curtains.closed")
                                .foregroundColor(.background)
                        }
                    }
                    .frame(width: 50, height: 50)
                    
                    chooseColor(bluetoothManager: bluetoothManager)
                    
                }
                .padding(.top, 100)
                .foregroundColor(.white)
            }
            .ignoresSafeArea()
            
        }
    }
}

#Preview {
    CurtainView(bluetoothManager: BluetoothManager())
}

struct chooseColor: View {
    @State private var selectedButton: Int? = nil
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        Text("Choose Color")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top)
        HStack {
            ZStack {
                Button {
                    selectedButton = 1
                    bluetoothManager.ligarLed()
                } label: {
                    Circle()
                        .foregroundColor(.light1)
                        .overlay(
                            Circle()
                                .stroke(selectedButton == 1 ? Color.white : Color.clear, lineWidth: 8)
                        )
                }
            }
            
            ZStack {
                Button {
                    selectedButton = 2
                    bluetoothManager.ligarLed()
                } label: {
                    Circle()
                        .foregroundColor(.light2)
                        .overlay(
                            Circle()
                                .stroke(selectedButton == 2 ? Color.white : Color.clear, lineWidth: 8)
                        )
                }
            }
            
            ZStack {
                Button {
                    selectedButton = 3
                    bluetoothManager.desligarLed()
                } label: {
                    Circle()
                        .foregroundColor(.clear)
                        .overlay(
                            Circle()
                                .stroke(selectedButton == 3 ? Color.white : Color.clear, lineWidth: 8)
                        )
                }
                Image(systemName: "lightbulb.slash.fill")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
            
            ZStack {
                Button {
                    selectedButton = 4
                    bluetoothManager.ligarLed()
                } label: {
                    Circle()
                        .foregroundColor(.light3)
                        .overlay(
                            Circle()
                                .stroke(selectedButton == 4 ? Color.white : Color.clear, lineWidth: 8)
                        )
                }
            }
            
            ZStack {
                Button {
                    selectedButton = 5
                    bluetoothManager.ligarLed()
                } label: {
                    Circle()
                        .foregroundColor(.light4)
                        .overlay(
                            Circle()
                                .stroke(selectedButton == 5 ? Color.white : Color.clear, lineWidth: 8)
                        )
                }
            }
        }
        .frame(width: 350, height: 50)
        .padding()
    }
}
