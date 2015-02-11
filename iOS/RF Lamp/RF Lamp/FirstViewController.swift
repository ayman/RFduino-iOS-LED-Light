//
//  FirstViewController.swift
//  RF Lamp
//
//  Created by David A. Shamma on 2/7/15.
//  GPL 3.0.
//

import Foundation
import UIKit
import CoreBluetooth

// Example: https://gist.github.com/nolili/a583ea045dafafebb17f

class FirstViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var central: CBCentralManager!
    var rfduino: CBPeripheral!

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
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!,
                    didDiscoverCharacteristicsForService service: CBService!,
                    error: NSError!) {
        if let actualError = error{
            
        } else {
            for characteristic in service.characteristics as [CBCharacteristic]{
                println(" \(characteristic.UUID.UUIDString)")
            }
        }
    }

}
