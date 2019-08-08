//
//  rTrigo.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 06.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

class rTrigo: rViewController 
{
   override func viewDidAppear() 
   {
      print ("Trigo viewDidAppear selectedDevice: \(selectedDevice)")
   }


    override func viewDidLoad() 
    {
        super.viewDidLoad()
      self.view.window?.acceptsMouseMovedEvents = true
      //let view = view[0] as! NSView
      self.view.wantsLayer = true
      var a:NSColor  = NSColor.init(red: 193/255, 
                               green: 205/255, 
                               blue: 205/255, 
                               alpha: 1.0)
      self.view.layer?.backgroundColor =  a.cgColor
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      
      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
     // NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)

   
   
   
   }
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let status:Int = info?["usbstatus"] as! Int // 
      print("Basis usbstatusAktion:\t \(status)")
      usbstatus = Int32(status)
   }
   
   // MARK joystick
   @objc override func joystickAktion(_ notification:Notification) 
   {
      print("Trigo joystickAktion usbstatus:\t \(usbstatus)  selectedDevice: \(selectedDevice) ident: \(self.view.identifier)")
      
      if (selectedDevice == self.view.identifier)
      {
         print("Trigo joystickAktion passt")
         let info = notification.userInfo
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         let wegindex:Int = info?["index"] as! Int // 
         let first:Int = info?["first"] as! Int
         print("Basis joystickAktion:\t \(punkt)")
         print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first)")
         
         teensy.write_byteArray[0] = SET_ROB // Code 
         
         // Horizontal Pot0
         let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
         let faktorw:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / w
         //      print("w: \(w) faktorw: \(faktorw)")
         var x = Double(punkt.x)
         if (x > w)
         {
            x = w
         }
         /*
          goto_x.integerValue = Int(Float(x*faktorw))
          joystick_x.integerValue = Int(Float(x*faktorw))
          goto_x_Stepper.integerValue = Int(Float(x*faktorw))
          */
         let achse0 = UInt16(Float(x*faktorw) * FAKTOR0)
         //print("x: \(x) achse0: \(achse0)")
         teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
         
         
         let h = Double(Joystickfeld.bounds.size.height)
         let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h
         
         let faktorz = 1
         //     print("h: \(h) faktorh: \(faktorh)")
         var y = Double(punkt.y)
         if (y > h)
         {
            y = h
         }
         let z = 0
         
         /*
          goto_y.integerValue = Int(Float(y*faktorh))
          joystick_y.integerValue = Int(Float(y*faktorh))
          goto_y_Stepper.integerValue = Int(Float(y*faktorh))
          */
         
         let achse1 = UInt16(Float(y*faktorh) * FAKTOR1)
         //print("y: \(y) achse1: \(achse1)")
         teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb
         let achse2 =  UInt16(Float(z*faktorz) * FAKTOR2)
         teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((achse2 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((achse2 & 0x00FF) & 0xFF) // lb
         
         
         let message:String = info?["message"] as! String
         if ((message == "mousedown") && (first >= 0))// Polynom ohne mousedragged
         {
            teensy.write_byteArray[0] = SET_RING
            let anz = servoPfad?.anzahlPunkte()
            if (wegindex > 1)
            {
               print("")
               print("joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
               
               let lastposition = servoPfad?.pfadarray.last
               
               let lastx:Int = Int(lastposition!.x)
               let nextx:Int = Int(achse0)
               let hypx:Int = (nextx - lastx) * (nextx - lastx)
               
               let lasty:Int = Int(lastposition!.y)
               let nexty:Int = Int(achse1)
               let hypy:Int = (nexty - lasty) * (nexty - lasty)
               
               let lastz:Int = Int(lastposition!.z)
               let nextz:Int = Int(achse2)
               let hypz:Int = (nextz - lastz) * (nextz - lastz)
               
               print("joystickAktion lastx: \(lastx) nextx: \(nextx) lasty: \(lasty) nexty: \(nexty)")
               
               let hyp:Float = (sqrt((Float(hypx + hypy + hypz))))
               
               let anzahlsteps = hyp/schrittweiteFeld.floatValue
               print("Trigo joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")
               
               teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
               teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
               
               teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
               teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
               
               teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
               teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb
               
               print("joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
               
            }
            else
            {
               print("joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
               teensy.write_byteArray[HYP_BYTE_H] = 0 // hb // Start, keine Hypo
               teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
               teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb // Start, Index 0
               teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
               
            }
            
            servoPfad?.addPosition(newx: achse0, newy: achse1, newz: 0)
         }
         
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            //print("report_Slider0 senderfolg: \(senderfolg)")
         }
      }
      else
      {
         print("Trigo joystickAktion passt nicht")
      }
      
      
   }

    
}
