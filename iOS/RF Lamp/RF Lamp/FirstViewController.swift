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

class FirstViewController: UIViewController {
    var rfduino : RFduino!
    
    @IBOutlet var onSwitch : UISwitch!
    @IBOutlet var onLabel : UILabel!
    @IBOutlet var highButton : UIButton!
    @IBOutlet var mediumButton : UIButton!
    @IBOutlet var lowButton : UIButton!
    @IBOutlet var hSlide : UISlider!
    @IBOutlet var sSlide : UISlider!
    @IBOutlet var bSlide : UISlider!
    @IBOutlet var hField : UITextField!
    @IBOutlet var sField : UITextField!
    @IBOutlet var bField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("loaded")
        // central = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        rfduino = RFduino()
        rfduino.startDiscovery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwitchTapped(sender: AnyObject){
        var rawArray:[UInt8] = [0xFF, 0xFF, 0xFF];
        if !((sender as UISwitch).on) {
            rawArray = [0x00, 0x00, 0x00]
        }
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        rfduino.writeValue(data)
    }
    
    @IBAction func lightValue(sender: AnyObject) {
        var b = (sender as UIButton)
        var rawArray:[UInt8] = [0x7F, 0x7F, 0x7F];
        if (b.currentTitle == "Medium") {
            rawArray = [0x40, 0x40, 0x40]
        } else if (b.currentTitle == "Low") {
            rawArray = [0x0A, 0x0A, 0x0A]
        }
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        rfduino.writeValue(data)
    }

    @IBAction func sliderChanged(sender: AnyObject) {
        var s = (sender as UISlider)
        var f = self.hField
        if (s == self.sSlide) {
            f = self.sField
        } else if (s == self.bSlide) {
            f = self.bField
        }
        f.text = NSString(format: "%.2f", s.value)
    }
    
    @IBAction func sliderDone(sender: AnyObject) {
        // Float and CGFloat are not auto casted!
        var hf : CGFloat = CGFloat(hSlide.value)
        var sf : CGFloat = CGFloat(sSlide.value)
        var vf : CGFloat = CGFloat(bSlide.value)
        var c = UIColor(hue: hf, saturation: sf, brightness: vf, alpha: 1.0)
        var rf = CGFloat(1.0)
        var gf = CGFloat(1.0)
        var bf = CGFloat(1.0)
        var af = CGFloat(1.0)
        c.getRed(&rf, green: &gf, blue: &bf, alpha: &af)
        println(c)
        var rd = UInt8(255 * rf)
        var gd = UInt8(255 * gf)
        var bd = UInt8(255 * bf)
        var rawArray:[UInt8] = [rd, gd, bd];
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        rfduino.writeValue(data)
    }    
}
