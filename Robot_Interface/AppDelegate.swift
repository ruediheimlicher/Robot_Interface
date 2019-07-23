//
//  AppDelegate.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

@IBOutlet weak var window: NSWindow!

   func applicationDidFinishLaunching(_ aNotification: Notification) {
      // Insert code here to initialize your application
       //self.window.acceptsMouseMovedEvents = true
   }

   func applicationWillTerminate(_ aNotification: Notification) {
      // Insert code here to tear down your application
   }


   
}

