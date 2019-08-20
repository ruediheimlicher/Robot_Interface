//
//  geom.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 15.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Foundation
import Cocoa
import Darwin

/*
// center and radius of 1st circle
*                                double x0, double y0, double r0,
*                                // center and radius of 2nd circle
*                                double x1, double y1, double r1,
*                                // 1st intersection point
*                                double *xi, double *yi,              
*                                // 2nd intersection point
*                                double *xi_prime, double *yi_prime)
*/




open class geom: NSObject
{

   override init()
   {
      super.init()
   }

   open func armwinkel(X0:Double, Y0:Double, R0:Double, X1:Double, Y1:Double, R1:Double )->(Double,Double)
   {
      
      // Berechnung fuer 2-teiligen Arm. X0, Y0: Koord Startpunkt, X1, Y1: Endpunkte in Ebene des Arms
     
      // Gelenk des Arms
      // erster Schnittpunkt 
      var xs0:Double = 0 
      var ys0:Double = 0 

      // zweiter Schnittpunkt
      var xs1:Double = 0 
      var ys1:Double = 0 
      
      //kreispunkte()
      //var xx = kreispunkte()
      var result = circle_circle_intersection(X0,Y0,R0,X1,Y1,R1,&xs0, &ys0, &xs1, &ys1)
      
      // Koord oberer Punkt:
      var xs:Double = xs0
      var ys:Double = ys0
      if (ys1 > ys0)
      {
         xs = xs1
         ys = ys1
      }
      
      // Winkel:
      var phi0:Double = asin((xs-X0)/R0) * 180/Double.pi
      var phi10:Double = acos((Y1-ys)/R1) * 180/Double.pi
      var phi1 = (90 - phi0) + phi10
      return (phi0,phi1)
   }
   
} // class 
