//
//  defines.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 28.07.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Foundation

let GOTO_0:UInt8  =  0xA7
let SET_RING:UInt8  =  0xA3
let CLEAR_RING:UInt8  =  0xA4

let DREHKNOPF:UInt8 = 0xAA

let ACHSE0_START:UInt16 = 0x7FF // Startwert low
let ACHSE0_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR0:Float = 1.6

let ACHSE1_START:UInt16 = 600 // Startwert low
let ACHSE1_MAX:UInt16 = 1800 // Startwert high
let FAKTOR1:Float = 2.6

let ACHSE2_START:UInt16 = 300 // Startwert low
let ACHSE2_MAX:UInt16 = 1800 // Startwert high
let FAKTOR2:Float = 2.75

let ACHSE3_START:UInt16 = 0x7FF // Startwert low
let ACHSE3_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR3:Float = 1.6

let DREHKNOPF_START:UInt16 = 0x7FF
let FAKTOR_DREHKNOPF:Float = 18.1 // Anpassen auf Mitte bei 3272


// Trigo
//let ACHSE1_MAX:Double = 1800
//let ACHSE1_START:Double = 600
let pot2_maxValue_start:Double = 1800
let pot2_minValue_start:Double = 300
