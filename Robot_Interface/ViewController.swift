//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

import Cocoa

 public var lastDataRead = Data.init(count:64)

let ACHSE0_START:UInt16 = 0x7FF // Startwert low
let ACHSE0_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR0:Float = 1.6

let ACHSE1_START:UInt16 = 0x7FF // Startwert low
let ACHSE1_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR1:Float = 1.6


class rJoystickView: NSView
{
   var weg: NSBezierPath = NSBezierPath()
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      Swift.print("JoystickView init")
      
   }

   // https://stackoverflow.com/questions/21751105/mac-os-x-convert-between-nsview-coordinates-and-global-screen-coordinates
   override func draw(_ dirtyRect: NSRect) 
   {
      // https://stackoverflow.com/questions/36596545/how-to-draw-a-dash-line-border-for-nsview
      super.draw(dirtyRect)
      
      // dash customization parameters
      let dashHeight: CGFloat = 1
      let dashColor: NSColor = .green
      
      // setup the context
      let currentContext = NSGraphicsContext.current()!.cgContext
      currentContext.setLineWidth(dashHeight)
      //currentContext.setLineDash(phase: 0, lengths: [dashLength])
      currentContext.setStrokeColor(dashColor.cgColor)
      
      // draw the dashed path
      currentContext.addRect(bounds.insetBy(dx: dashHeight, dy: dashHeight))
      currentContext.strokePath()
      
      NSColor.blue.set() // choose color
      let figure = NSBezierPath() // container for line(s)
      let x:Double = 10
      let y:Double = 10
      figure.move(to: NSMakePoint(CGFloat(x), CGFloat(y))) // start point
      figure.line(to: NSMakePoint(CGFloat(x + 100.0), CGFloat(y + 10.0))) // destination
      figure.lineWidth = 1  // hair line
      figure.stroke()  // draw line(s) in color
      weg.stroke()  // draw line(s) in color
   }
   
   override func mouseDown(with theEvent: NSEvent) 
   {
      
      super.mouseDown(with: theEvent)
      Swift.print("left mouse")
      let location = theEvent.locationInWindow
      Swift.print(location)
  //    NSPoint lokalpunkt = [self convertPoint: [anEvent locationInWindow] fromView: nil];
      let lokalpunkt = convert(theEvent.locationInWindow, from: nil)
      Swift.print(lokalpunkt)

      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"joystick"),
              object: nil,
              userInfo: ["message":"mousedown", "punkt":lokalpunkt])

      // setup the context
      // setup the context
      let dashHeight: CGFloat = 1
      let dashColor: NSColor = .green

 
  //    NSColor.blue.set() // choose color
  // https://stackoverflow.com/questions/47738822/simple-drawing-with-mouse-on-cocoa-swift
      //clearWeg()
      if weg.isEmpty
      {
         weg.move(to: lokalpunkt)
         weg.line(to: NSMakePoint(lokalpunkt.x, lokalpunkt.y+5))
         weg.line(to: lokalpunkt)
         weg.line(to: NSMakePoint(lokalpunkt.x+5, lokalpunkt.y))
         weg.line(to: lokalpunkt)
         weg.line(to: NSMakePoint(lokalpunkt.x, lokalpunkt.y-5))
         weg.line(to: lokalpunkt)
         weg.line(to: NSMakePoint(lokalpunkt.x-5, lokalpunkt.y))
         weg.line(to: lokalpunkt)
      }
      else
      {
         weg.line(to: lokalpunkt)
      }
      needsDisplay = true     

   }
   
   override func rightMouseDown(with theEvent: NSEvent) 
   {
      self.clearWeg()
      Swift.print("right mouse")
      let location = theEvent.locationInWindow
      Swift.print(location)
      needsDisplay = true
   }
 
   override func mouseDragged(with theEvent: NSEvent) 
   {
      Swift.print("mouseDragged")
      let location = theEvent.locationInWindow
      Swift.print(location)
      var lokalpunkt = convert(theEvent.locationInWindow, from: nil)
      Swift.print(lokalpunkt)
      weg.line(to: convert(theEvent.locationInWindow, from: nil))
      needsDisplay = true
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"joystick"),
              object: nil,
              userInfo: ["message":"mousedown", "punkt":lokalpunkt])
      

   }
   
   func clearWeg()
   {
      weg.removeAllPoints()
   }
   
   override func keyDown(with theEvent: NSEvent) {
      Swift.print( "Key Pressed" )
   }
   
} // rJoystickView


class ViewController: NSViewController, NSWindowDelegate
{
   
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var teensy = usb_teensy()
   
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start_Knopf: NSButton!
   @IBOutlet weak var Stop_Knopf: NSButton!
   @IBOutlet weak var Send_Knopf: NSButton!
   @IBOutlet weak var Start_Read_Knopf: NSButton!
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   @IBOutlet weak var USB_OK: NSOutlineView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!

   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   
   @IBOutlet weak var Pot0_Feld: NSTextField!
   @IBOutlet weak var Pot0_Slider: NSSlider!
   @IBOutlet weak var Pot0_Stepper_H: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot0_Stepper_H_Feld: NSTextField!
   
   
   @IBOutlet weak var Pot1_Feld: NSTextField!
   @IBOutlet weak var Pot1_Slider: NSSlider!
   @IBOutlet weak var Pot1_Stepper_H: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot1_Stepper_H_Feld: NSTextField!

   
   
   @IBOutlet weak var Pot2_Feld: NSTextField!
   @IBOutlet weak var Pot2_Slider: NSSlider!
   @IBOutlet weak var Pot2_Stepper: NSStepper!

   @IBOutlet weak var Pot3_Feld: NSTextField!
   @IBOutlet weak var Pot3_Slider: NSSlider!
   @IBOutlet weak var Pot3_Stepper: NSStepper!

   @IBOutlet weak var Joystickfeld: rJoystickView!
   
   var formatter = NumberFormatter()
   
   
    
   var achse0_start:UInt16  = ACHSE0_START;
   var achse0_max:UInt16   = ACHSE0_MAX;

   
   
   // const fuer USB
   let SET_0:UInt8 = 0xA1
   let SET_1:UInt8 = 0xB1
   let GET_U:UInt8 = 0xA2
   let GET_I:UInt8 = 0xB2
   
   let SET_P:UInt8 = 0xA3
   let GET_P:UInt8 = 0xB3

   let SIN_START:UInt8 = 0xC0
   let SIN_END:UInt8 = 0xC1
   
   let U_DIVIDER:Float = 9.8
   let ADC_REF:Float = 3.26
   
   let ACHSE0_BYTE_H = 4
   let ACHSE0_BYTE_L = 5

   let ACHSE1_BYTE_H = 6
   let ACHSE1_BYTE_L = 7

    override func viewDidLoad()
   {
      super.viewDidLoad()
      
      self.view.window?.acceptsMouseMovedEvents = true
 
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
       formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down

      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      
      // Pot 0
      Pot0_Slider.integerValue = Int(ACHSE0_START)
      Pot0_Feld.integerValue = Int(ACHSE0_START)
      Pot0_Stepper_L.integerValue = 0
      Pot0_Stepper_L_Feld.integerValue = 0
      Pot0_Stepper_H.integerValue = Int(Pot0_Slider.maxValue)
      Pot0_Stepper_H_Feld.integerValue = Int(Pot0_Slider.maxValue)
      
      // Pot 1
      Pot1_Slider.integerValue = Int(ACHSE1_START)
      Pot1_Feld.integerValue = Int(ACHSE1_START)
      Pot1_Stepper_L.integerValue = 0
      Pot1_Stepper_L_Feld.integerValue = 0 
      Pot1_Stepper_H.integerValue = Int(Pot1_Slider.maxValue)
      Pot1_Stepper_H_Feld.integerValue = Int(Pot1_Slider.maxValue)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb

      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[0] = SET_0
     

      
   }
   
   @objc func joystickAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let punkt:CGPoint = info?["punkt"] as! CGPoint
      print("joystickAktion:\t \(punkt)")
      print("x: \(punkt.x) y: \(punkt.y)")

      let h = Double(Joystickfeld.bounds.size.height)
      let faktorh:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / h
      let y = Double(punkt.y)
      let achse0 = Int(y*faktorh)
      print("y: \(y) achse0: \(achse0)")
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb

      let w = Double(Joystickfeld.bounds.size.width)
      let faktorw:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / w
      let x = Double(punkt.x)
      let achse1 = Int(x*faktorw)
      print("x: \(x) achse1: \(achse1)")
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }

   
   }
 
 
   @objc func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
      var ii = 0
      while ii < 10
      {
         //print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
      
      let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      let info = notification.userInfo
      
      //print("info: \(String(describing: info))")
      //print("new Data")
      let data = notification.userInfo?["data"]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      while i < 10
      {
         //print("i: \(i)  wert: \(lastDataRead[i])\t")
         i = i+1
      }

      if let d = notification.userInfo!["usbdata"]
      {
            
         //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,... 
         let t = type(of:d)
         //print("typ: \(t)\n") // typ: Array<UInt8>
         
         //print("element: \(d[1])\n")
         
         print("d as string: \(String(describing: d))\n")
         if d != nil
         {
            //print("d not nil\n")
            var i = 0
            while i < 10
            {
               //print("i: \(i)  wert: \(d![i])\t")
               i = i+1
            }
            
         }
        
         
         //print("dic end\n")
      }
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")

   }
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   @IBAction func report_Slider1(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_1 // Code 
      print("report_Slider1 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let intpos = sender.intValue 
      
      let Istring = formatter.string(from: NSNumber(value: intpos))
      print("intpos: \(intpos) IString: \(Istring)") 
      Pot1_Feld.stringValue  = Istring!
      
      
      self.Pot1_Stepper_H.floatValue = sender.floatValue

      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_I_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_I_Stepper IntVal: \(sender.intValue)")
      let I = Pot1_Feld.floatValue
      let intpos = sender.intValue 
      
      let pos = sender.floatValue
      let Istring = formatter.string(from: NSNumber(value: intpos))
 //     print("report_U_Stepper u: \(u) Istring: \(Istring ?? "0")")
      Pot1_Feld.stringValue  = Istring!
      
      self.Pot1_Stepper_H.floatValue = sender.floatValue
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_StartSinus(_ sender: NSButton)
   {
      print("report_StartSinus ")
      teensy.write_byteArray[0] = SIN_START
      teensy.write_byteArray[1] = SIN_START
      let startwert = ACHSE0_START
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   @IBAction func report_StopSinus(_ sender: NSButton)
   {
      print("report_StopSinus ")
      teensy.write_byteArray[0] = SIN_END
      teensy.write_byteArray[1] = SIN_END
      let startwert = ACHSE0_START
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
  
   @IBAction func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
    
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      Pot0_Feld.stringValue  = Ustring!
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
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_L_Feld.integerValue = intpos
      
      Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   @IBAction func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }

   
   @IBAction func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
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
   
   @IBAction func report_Slider2(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_P // Code 
      print("report_Slider2 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let p = pos / Float(sender.maxValue) * 5.12
      let Pstring = formatter.string(from: NSNumber(value: p))
    //  print("report_Slider0 pos: \(intpos)  u: \(u) Ustring: \(Ustring ?? "0")")

      print("report_Slider2 p: \(p) Pstring: \(Pstring ?? "0")")
      let intpos = sender.intValue 
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intpos & 0x00FF) & 0xFF)
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intpos & 0xFF00) >> 8)
      _ = teensy.send_USB()
      
   }


   @IBAction func report_set_Pot1(_ sender: AnyObject)
   {
      
   }

   
   
   
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         var start_read_USB_erfolg = teensy.start_read_USB(true)
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true

      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "report_start_read_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false

      }
      
      //teensy.start_teensy_Timer()
      
      //     var somethingToPass = "It worked"
      
      //      let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tester:"), userInfo: somethingToPass, repeats: true)
      
   }
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      let present = teensy.dev_present()
      let hidstatus = teensy.status()
      
      print("USBOpen usbstatus vor check: \(usbstatus) hidstatus: \(hidstatus) present: \(present)")
      if (usbstatus > 0) // already open
      {
         print("USB-Device ist schon da")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist schon da"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
        // return

      }
      let erfolg = teensy.USBOpen()
      usbstatus = erfolg
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
         print("status 1")
         USB_OK.backgroundColor = NSColor.green
         print("USB-Device da")
         /*
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist da"
         warnung.addButton(withTitle: "OK")
         //warnung.runModal()
          */
         let manu = get_manu()
         //println(manu) // ok, Zahl
//         var manustring = UnsafePointer<CUnsignedChar>(manu)
         //println(manustring) // ok, Zahl
         
         let manufactorername = String(cString: UnsafePointer(manu!))
         print("str: %s", manufactorername)
         manufactorer.stringValue = manufactorername
         
         //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         Start_Knopf.isEnabled = true
         Send_Knopf.isEnabled = true
      }
      else
         
      {
         print("status 0")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "check_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         
         if let taste = USB_OK
         {
            //print("Taste USB_OK ist nicht nil")
            taste.backgroundColor = NSColor.red
         //USB_OK.backgroundColor = NSColor.redColor()
            
         }
         else
         {
            print("Taste USB_OK ist nil")
         }
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
         Send_Knopf.isEnabled = false
         return
      }
      print("antwort: \(teensy.status())")
   }
   
   @IBAction func report_stop_read_USB(_ sender: AnyObject)
   {
      if teensy.dev_present() > 0
      {
         teensy.read_OK = false
         if teensy.dev_present() > 0
         {
            Start_Knopf.isEnabled = true
            Send_Knopf.isEnabled = true
         }
         else
         {
            Start_Knopf.isEnabled = false
         }
         Stop_Knopf.isEnabled = false
      }
   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      if teensy.dev_present() > 0
      {
         var senderfolg = teensy.send_USB()
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "send_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Send_Knopf.isEnabled = false

      }
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("send_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      Anzeige.stringValue = "not OK"
      println("kein USB-Device")
      }
      else
      {
      usbstatus = 1
      println("USB-Device da")
      var manu = get_manu()
      //println(manu) // ok, Zahl
      var manustring = UnsafePointer<CUnsignedChar>(manu)
      //println(manustring) // ok, Zahl
      
      let manufactorername = String.fromCString(UnsafePointer(manu))
      println("str: %s", manufactorername!)
      manufactorer.stringValue = manufactorername!
      
      /*
      var strA = ""
      strA.append(Character("d"))
      strA.append(UnicodeScalar("e"))
      println(strA)
      
      let x = manu
      let s = "manufactorer"
      println("The \(s) is \(manu)")
      var pi = 3.14159
      NSLog("PI: %.7f", pi)
      let avgTemp = 66.844322156
      println(NSString(format:"AAA: %.2f", avgTemp))
      */
      }
      */
      
   }
   
   // https://nabtron.com/quit-cocoa-app-window-close/
   override func viewDidAppear() 
   {
      print("viewDidAppear")
      self.view.window?.delegate = self as? NSWindowDelegate 
   }
   
   func windowShouldClose(_ sender: Any) 
   {
      print("windowShouldClose")
      NSApplication.shared().terminate(self)
   }

   
   override var representedObject: Any? {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   
}

