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

class FirstViewController: UIViewController, CBCentralManagerDelegate {
    var central: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("loaded")
        // central = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        central = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: (NSDictionary), RSSI: NSNumber!) {
        println("Discovered: \(peripheral.name)")
        // textField.text = textField.text + "Discovered: \(peripheral.name)\n"
        
        
        // self.connectingPeripheral = peripheral
        // centralManager.stopScan()
        // self.centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "CoreBluetooth BLE hardware is powered off"
        case .PoweredOn:
            msg = "CoreBluetooth BLE hardware is powered on and ready"
            // blueToothReady = true;
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

}
