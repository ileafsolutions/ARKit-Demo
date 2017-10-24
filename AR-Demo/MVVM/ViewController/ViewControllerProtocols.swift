//
//  ViewControllerProtocols.swift
//  AR-Demo
//
//  Created by Vivek iLeaf on 10/24/17.
//  Copyright © 2017 Vivek iLeaf. All rights reserved.
//

import Foundation
import UIKit
import ARKit

@objc protocol ViewControllerProtocol:class
{
    var planes : [ARPlaneAnchor: Plane] {get set}
    var focusSquare: FocusSquare?{get set}
    func didLoadARscene(target:ViewController)
    func resetTracking(target:ViewController)
    func restartSession(target:ViewController)
    func displayErrorMessage(target:ViewController,title: String, message: String, allowRestart: Bool)
    func screenShotMethod(target:ViewController)
    //Planes
    func addPlane(target:ViewController,node: SCNNode, anchor: ARPlaneAnchor)
    func updatePlane(target:ViewController,anchor: ARPlaneAnchor)
    func removePlane(target:ViewController,anchor: ARPlaneAnchor)
    
    //Focus Square
    
    func setupFocusSquare(target:ViewController)
    func updateFocusSquare(target:ViewController)
}
