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
   @IBOutlet  weak var DrehknopfFeld:rDrehknopfView!
   
 
   
   @IBOutlet weak var Drehknopf_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Stepper_H: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Stepper_H_Feld: NSTextField!
   
   @IBOutlet weak var arm: NSButton!
   
   @IBOutlet weak var startx: NSTextField!
   @IBOutlet weak var starty: NSTextField!
   @IBOutlet weak var startz: NSTextField!
   
   
   @IBOutlet weak var endx: NSTextField!
   @IBOutlet weak var endy: NSTextField!
   @IBOutlet weak var endz: NSTextField!
   
   @IBOutlet weak var arm0: NSTextField!
   @IBOutlet weak var arm1: NSTextField!
 
   @IBOutlet weak var armwinkel0: NSTextField!
   @IBOutlet weak var armwinkel1: NSTextField!

   var hintergrundfarbe = NSColor()
   
   var geometrie = geom()
   
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
      hintergrundfarbe  = NSColor.init(red: 0.25, 
                                    green: 0.45, 
                                    blue: 0.45, 
                                    alpha: 0.25)
      self.view.layer?.backgroundColor =  hintergrundfarbe.cgColor
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      
      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(drehknopfAktion(_:)),name:NSNotification.Name(rawValue: "drehknopf"),object:nil)

      
      Pot1_Slider.maxValue = Double(ACHSE1_MAX)
      Pot1_Stepper_H.integerValue = Int(Pot1_Slider.maxValue)
      Pot1_Stepper_H_Feld.integerValue = Int(Pot1_Slider.maxValue)
      
      Pot1_Slider.minValue = Double(ACHSE1_START)
      Pot1_Stepper_L.integerValue = Int(Pot1_Slider.minValue)
      Pot1_Stepper_L_Feld.integerValue = Int(Pot1_Slider.minValue)
      Pot1_Feld_wert.integerValue = Int(UInt16(ACHSE1_MAX ))
      Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_MAX) * FAKTOR1))
      Pot1_Slider.integerValue = Int(ACHSE1_MAX)
      
      let intpos1 = UInt16(Float(ACHSE1_MAX) * FAKTOR1)
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos1 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos1 & 0x00FF) & 0xFF) // lb

      
      Pot2_Slider.maxValue = pot2_maxValue_start
      Pot2_Stepper_H.integerValue = Int(Pot2_Slider.maxValue)
      Pot2_Stepper_H_Feld.integerValue = Int(Pot2_Slider.maxValue)
      
      Pot2_Slider.minValue = pot2_minValue_start
      Pot2_Stepper_L.integerValue = Int(Pot2_Slider.minValue)
      Pot2_Stepper_L_Feld.integerValue = Int(Pot2_Slider.minValue)
      Pot2_Feld_wert.integerValue = Int(UInt16(pot2_maxValue_start ))
      Pot2_Feld.integerValue = Int(UInt16(Float(pot2_maxValue_start) * FAKTOR2))
      Pot2_Slider.integerValue = Int(pot2_maxValue_start)
    
      let intpos2 = UInt16(Float(pot2_maxValue_start) * FAKTOR2)
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos2 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos2 & 0x00FF) & 0xFF) // lb
    
      
      
      teensy.write_byteArray[0] = SET_1 // Code
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Trigo viewDidLoad senderfolg: \(senderfolg)")
      }

/*
       
      Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_START) * FAKTOR1))
      */
      
      Drehknopf_Stepper_H_Feld.integerValue = Int(DrehknopfFeld.maxwinkel)
      Drehknopf_Stepper_H.integerValue = Int(DrehknopfFeld.maxwinkel)
      
      Drehknopf_Stepper_L_Feld.integerValue = Int(DrehknopfFeld.minwinkel)
      Drehknopf_Stepper_L.integerValue = Int(DrehknopfFeld.minwinkel)
      
      DrehknopfFeld.hgfarbe = hgfarbe
      print("Trigo globalusbstatus: \(globalusbstatus)")
      
      
   }
   
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let status:Int = info?["usbstatus"] as! Int // 
      print("Trigo usbstatusAktion:\t \(status) ")
      usbstatus = Int32(status)
   }
   
   @objc  func drehknopfAktion(_ notification:Notification) 
   {
      print("Trigo drehknopfAktion usbstatus:\t \(usbstatus)  globalusbstatus: \(globalusbstatus) selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      if (selectedDevice == self.view.identifier)
      {
         

        // print("Trigo drehknopfAktion passt")
         teensy.write_byteArray[0] = DREHKNOPF
         
         let info = notification.userInfo
         let ident = Int(info?["ident"] as! String)
         let punkt:CGPoint = info?["punkt"] as! CGPoint

         let winkel = (punkt.x )
         
         let winkel2 = Int(10*(winkel + 180))
         
         
         Drehknopf_Feld.integerValue = Int(winkel)
         let h = Double(Joystickfeld.bounds.size.height)
         //let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h
         let randbereich = abs(DrehknopfFeld.minwinkel) + abs(DrehknopfFeld.maxwinkel)
         let faktordrehknopf = 360/(360 - randbereich )
         
         // minwinkel ist negativ von Scheitelpunkt aus
         let wert = CGFloat(Float((winkel + 180 + (DrehknopfFeld.minwinkel))*faktordrehknopf) * FAKTOR_DREHKNOPF) // red auf 0
         
         var achse0:UInt16 = 0
         if (wert > 0)
         {
            achse0 =  UInt16(wert)
         }
         else
         {
            achse0 = 0
         }
        
         
         print("Drehknopf winkel: \(winkel) winkel2: \(winkel2) ***   faktordrehknopf: \(faktordrehknopf) wert: \(wert) achse0: \(achse0)")
         teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
   //    teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
   //    teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
 
         if (globalusbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("Trigo Drehknopfaktion senderfolg: \(senderfolg)")
         }         
      } // identifier passt
   }
   
   // MARK joystick
   @objc override func joystickAktion(_ notification:Notification) 
   {
  //    print("Trigo joystickAktion usbstatus:\t \(usbstatus)  selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      
      if (selectedDevice == self.view.identifier)
      {
  //       print("Trigo joystickAktion passt")
         
         let info = notification.userInfo
         let ident = Int(info?["ident"] as! String)
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         
         
         let wegindex:Int = info?["index"] as! Int // 
         let first:Int = info?["first"] as! Int
   //      print("Trigo joystickAktion:\t \(punkt)")
   //      print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first) ident: \(ident)")
         
         if ident == 2001 // Drehknopf
         {
            print("Drehknopf ident 2001")
            teensy.write_byteArray[0] = DREHKNOPF
            let winkel = Int(punkt.x )
            print("Drehknopf winkel: \(winkel)")
         }
         else if ident == 2000
         {
            
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
               print("joystickAktion anz: \(anz)")
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
         } // if 2000
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("joystickaktion  senderfolg: \(senderfolg)")
         }
      }
      else
      {
//         print("Trigo joystickAktion passt nicht")
      }
      
      
   }
   
   //MARK Geometrie
   
    @IBAction  func report_armwinkel(_ sender: NSButton)
    {
      var winkeltup = winkelvonpunkt(x: 12, y: 16, z: 30)
         print("report_armwinkel winkelvonpunkt: \(winkeltup)")
      armwinkel0.doubleValue = winkeltup.0
      armwinkel1.doubleValue = winkeltup.1
      
   }
   
    func winkelvonpunkt( x:Double  ,  y:Double,   z:Double) -> (Double, Double)
      {
         var phi0:Double , phi1:Double 
         phi0 = 13
         phi1 = 17
      //   let arm0:Double = 75
      //   let arm1:Double = 65
         var x0:Double = startx.doubleValue, y0:Double = startz.doubleValue, r0:Double = arm0.doubleValue, x1:Double = endx.doubleValue, y1:Double = endz.doubleValue, r1:Double = arm1.doubleValue 
         var xi0:Double = 0, yi0:Double = 0, xi1: Double = 0, yi1:Double = 0, xi11: Double = 0, yi11:Double = 0
         /*
          int circle_circle_intersection(double x0, double y0, double r0,
          double x1, double y1, double r1,
          double *xi, double *yi,
          double *xi_prime, double *yi_prime)

          */
      //   var resultat = circle_circle_intersection(0, 0, arm0, x, y, arm1, &xi1, &yi1, &xi11, &yi11)
         
         var robotarmwinkel:(Double,Double) = geometrie.armwinkel(X0: x0 , Y0: y0, R0: r0, X1: x1, Y1: y1, R1: r1)
         print("robotarmwinkel: \(robotarmwinkel)")
     //    Swift.print("
         return (robotarmwinkel.0, robotarmwinkel.1)
   }
   
   //MARK: Slider 0
   @IBAction override func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      print("Trigo report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot0_Feld.integerValue  = Int(intpos)
      Pot0_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot0_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot0_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot0_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("rBasis report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   @IBAction override func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("Trigo report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_L_Feld.integerValue = intpos
      
      Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   
   @IBAction override func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("Trigo report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }
   @IBAction override func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("Trigo report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
      let intpos = sender.intValue 
      self.Pot0_Slider.floatValue = Pot0_wert //sender.floatValue
      self.Pot0_Stepper_L.floatValue = Pot0_wert//sender.floatValue
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(Pot0_LO)
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(Pot0_HI)
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_Pot0 U: %d",senderfolg)
         }
      }
   }
   
   
   // MARK:Slider 1
   @IBAction override func report_Slider1(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_1 // Code
      print("report_Slider1 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      Pot1_Feld_wert.integerValue = Int(pos)
      let intpos = UInt16(pos * FAKTOR1)
      let Istring = formatter.string(from: NSNumber(value: intpos))
      print("report_Slider1 intpos: \(intpos) IString: \(Istring)") 
      Pot1_Feld.integerValue  = Int(intpos)
      
      Pot1_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot1_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot1_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot1_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction override func report_Pot1_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot1_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_L_Feld.integerValue = intpos
      
      Pot1_Slider.minValue = sender.doubleValue 
      print("report_Pot1_Stepper_L Pot1_Slider.minValue: \(Pot1_Slider.minValue)")
      
      
   }
   
   @IBAction override func report_Pot1_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot1_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_H_Feld.integerValue = intpos
      
      Pot1_Slider.maxValue = sender.doubleValue 
      print("report_Pot1_Stepper_H Pot1_Slider.maxValue: \(Pot1_Slider.maxValue)")
      
   }
   
   @IBAction override func report_Slider2(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_2 // Code 
      print("Trigo report_Slider2 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      Pot2_Feld_wert.integerValue  = Int(pos)
      let intpos = UInt16(pos * FAKTOR2)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider2 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider2 senderfolg: \(senderfolg)")
      }
   }

   @IBAction override func report_Pot2_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot2_Stepper_L_Feld.integerValue = intpos
      
      Pot2_Slider.minValue = sender.doubleValue 
      print("report_Pot2_Stepper_L Pot2_Slider.minValue: \(Pot2_Slider.minValue)")
      
   }
   
   @IBAction override func report_Pot2_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot2_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot2_Stepper_H_Feld.integerValue = intpos
      
      Pot2_Slider.maxValue = sender.doubleValue 
      print("report_Pot2_Stepper_H Pot2_Slider.maxValue: \(Pot2_Slider.maxValue)")
      
   }

   
     
   @IBAction override func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("Trigo report_Slider3 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider3 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot3_Feld.integerValue  = Int(intpos)
      Pot3_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot3_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot3_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot3_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_Slider3 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction override func report_Pot3_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot3_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot3_Stepper_L_Feld.integerValue = intpos
      
      Pot3_Slider.minValue = sender.doubleValue 
      print("report_Pot3_Stepper_L Pot3_Slider.minValue: \(Pot3_Slider.minValue)")
      
   }
   
   @IBAction override func report_Pot3_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot3_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot3_Stepper_H_Feld.integerValue = intpos
      
      Pot3_Slider.maxValue = sender.doubleValue 
      print("report_Pot3_Stepper_H Pot3_Slider.maxValue: \(Pot3_Slider.maxValue)")
      
   }
   
   
   @IBAction  func report_Drehknopf_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_L_Feld.integerValue = intpos
      
      DrehknopfFeld.minwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_L DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      //   abdeckpfad.fill()
      
      DrehknopfFeld.needsDisplay = true
      
   }
   


   @IBAction  func report_Drehknopf_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_H_Feld.integerValue = intpos
      
      DrehknopfFeld.maxwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_H DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      DrehknopfFeld.needsDisplay = true

   }
   
  
}
