//
//  FirstViewController.swift
//  RF Lamp
//
//  Created by David A. Shamma on 2/7/15.
//  GPL 3.0.
//

import UIKit
import CoreBluetooth

// Example: https://gist.github.com/nolili/a583ea045dafafebb17f

class FirstViewController:
      UIViewController,
      CBCentralManagerDelegate,
      CBPeripheralDelegate {
    var central: CBCentralManager!
    var rfduino: CBPeripheral!
    var service: CBService!
    var sendChar: CBCharacteristic!
    var receiveChar: CBCharacteristic!
    var disconnnectChar: CBCharacteristic!
    
    @IBOutlet var onSwitch : UISwitch!
    @IBOutlet var onLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("loaded")
        central = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        // central = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwitchTapped(sender: AnyObject){
        var rawArray:[UInt8] = [0xFF, 0xFF, 0xFF];
        if !((sender as UISwitch).on) {
            rawArray = [0x00, 0x00, 0x00]
        } else {
            
        }
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        rfduino.writeValue(data, forCharacteristic: sendChar, type: CBCharacteristicWriteType.WithoutResponse)
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
            self.rfduino = peripheral
            self.rfduino.delegate = self
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
                println(" \(characteristic.UUID.UUIDString)")
                switch (characteristic.UUID.UUIDString) {
                // These are hardcoded in the RFDuino
                case "2221":
                    self.receiveChar = characteristic
                case "2222":
                    self.sendChar = characteristic
                case "2223":
                    self.disconnnectChar = characteristic
                default:
                    println("nothing")
                }
            }
        }
    }
}
