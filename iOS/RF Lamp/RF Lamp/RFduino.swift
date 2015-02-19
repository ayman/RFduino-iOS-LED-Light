//
//  RFduino.swift
//  RF Lamp
//
//  Created by David A. Shamma on 2/18/15.
//  Copyright (c) 2015 David A. Shamma. All rights reserved.
//

import Foundation
import CoreBluetooth

class RFduino : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let RECEIVE_CHARACTERISTIC = "2221"
    let SEND_CHARACTERISTIC = "2222"
    let DISCONNECT_CHARACTERISTIC = "2223"
    
    var central: CBCentralManager!
    var peripheral: CBPeripheral!
    var service: CBService!
    var sendChar: CBCharacteristic!
    var receiveChar: CBCharacteristic!
    var disconnnectChar: CBCharacteristic!
    
    func startDiscovery() {
        central = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    func writeValue(data: NSData) {
        peripheral.writeValue(data, forCharacteristic: sendChar, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "CoreBluetooth BLE hardware is powered off"
        case .PoweredOn:
            msg = "CoreBluetooth BLE hardware is powered on and ready"
            self.central.scanForPeripheralsWithServices(nil, options: nil)
        case .Resetting:
            msg = "CoreBluetooth BLE hardware is resetting"
        case .Unauthorized:
            msg = "CoreBluetooth BLE state is unauthorized"
        case .Unknown:
            msg = "CoreBluetooth BLE state is unknown"
        case .Unsupported:
            msg = "CoreBluetooth BLE hardware is unsupported on this platform"
        }
        println("\(msg)")
    }
    
    func centralManager(central: CBCentralManager!,
                        didDiscoverPeripheral peripheral: CBPeripheral!,
                        advertisementData: (NSDictionary), RSSI: NSNumber!) {
        println("Discovered: \(peripheral.name)")
        if (peripheral.name != nil && peripheral.name == "RFduino") {
            self.central.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.central.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!,
                        didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if let actualError = error {
            // Handle Error
        }
        else {
            for service in peripheral.services as [CBService]!{
                println("Service: \(service.description)")
                self.service = service;
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!,
                    didDiscoverCharacteristicsForService service: CBService!,
                    error: NSError!) {
        if let actualError = error{
            println("There was an error...who knows....")
        } else {
            for characteristic in service.characteristics as [CBCharacteristic]{
                switch (characteristic.UUID.UUIDString) {
                // These are hardcoded in the RFDuino
                case RECEIVE_CHARACTERISTIC:
                    self.receiveChar = characteristic
                case SEND_CHARACTERISTIC:
                    self.sendChar = characteristic
                case DISCONNECT_CHARACTERISTIC:
                    self.disconnnectChar = characteristic
                default:
                    println("nothing")
                }
            }
        }
    }
}
