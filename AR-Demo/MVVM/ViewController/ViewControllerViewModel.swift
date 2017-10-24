//
//  ViewControllerViewModel.swift
//  AR-Demo
//
//  Created by Vivek iLeaf on 10/24/17.
//  Copyright © 2017 Vivek iLeaf. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit


// MARK: - App Settings for Gesture if you want to used for future enabling and disabling
public enum Setting: String
{
    case scaleWithPinchGesture
    case dragOnInfinitePlanes
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.dragOnInfinitePlanes.rawValue: true
            ])
    }
}

class ViewControllerViewModel: ViewControllerProtocol
{
    var planes: [ARPlaneAnchor : Plane] = [:]
    
    var focusSquare: FocusSquare?
    

    
    // MARK: - Setup ARScene View
    func didLoadARscene(target:ViewController)
   {
    let pinch = UIPinchGestureRecognizer(target: target.arSceneDelegate, action: #selector(self.pinch(sender:)))
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped(sender:)))
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
    longPressGestureRecognizer.minimumPressDuration = 0.2
    target.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    target.sceneView.addGestureRecognizer(tap)
    target.sceneView.addGestureRecognizer(pinch)
     Setting.registerDefaults()
    setupUIControls(target: target)
    setupScene(target: target)
    }
    // MARK: - ScreenShot
    func screenShotMethod(target:ViewController) {

        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(target.sceneView.snapshot(), nil, nil, nil)
        target.showAlertViewDismissAutomatically(title: "Captured", message: "Please enjoy your AR View from your Photos Library")
    }
    
    // MARK: - Setup
    
    func setupScene(target:ViewController) {
        
        // Synchronize updates via the `serialQueue`.
        target.virtualObjectManager = VirtualObjectManager(updateQueue: target.serialQueue)
        target.virtualObjectManager.delegate = target
        
        // set up scene view
        target.sceneView.setup()
        target.sceneView.delegate = target
        target.sceneView.session = target.session
        // sceneView.showsStatistics = true
        
        target.sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: target.serialQueue)
        
        self.setupFocusSquare(target: target)
        
        DispatchQueue.main.async {
            target.screenCenter = target.sceneView.bounds.mid
        }
    }
    
    func setupUIControls(target:ViewController) {
        target.textManager = TextManager(viewController: target)
        
        // Set appearance of message output panel
        target.messagePanel.layer.cornerRadius = 3.0
        target.messagePanel.clipsToBounds = true
        target.messagePanel.isHidden = true
        target.messageLabel.text = ""
    }
    // MARK: - Restart Session
    func restartSession(target:ViewController)
    {
        guard target.restartExperienceButtonIsEnabled, !target.isLoadingObject else { return }
        
        DispatchQueue.main.async {
            target.restartExperienceButtonIsEnabled = false
            
            target.textManager.cancelAllScheduledMessages()
            target.textManager.dismissPresentedAlert()
            target.textManager.showMessage("STARTING A NEW SESSION")
            
            target.virtualObjectManager.removeAllVirtualObjects()
            
            self.focusSquare?.isHidden = true
            
            self.resetTracking(target: target)
            
            target.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            // Show the focus square after a short delay to ensure all plane anchors have been deleted.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.setupFocusSquare(target: target)
            })
            
            // Disable Restart button for a while in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                target.restartExperienceButtonIsEnabled = true
            })
        }
    }
    
    func resetTracking(target:ViewController) {
        target.session.run(target.standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        target.textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
                                    inSeconds: 7.5,
                                    messageType: .planeEstimation)
    }
    // MARK: - Gestures Methods
    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty {
            
            let result = hitTest.first!
            if sender.state == .began {
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotation)
                result.node.parent?.runAction(forever)
            } else if sender.state == .ended {
                result.node.parent?.removeAllActions()
            }
        }
        
    }
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation)
        if !hitTest.isEmpty {
            let node = hitTest.first!.node
            if node == sceneView.scene.rootNode.childNode(withName: "lightBulb0001_GES", recursively: true)
            {
                if node.geometry?.material(named: "lamp_bulb_MAT")?.selfIllumination.contents as! UIColor == UIColor.yellow
                {
                    node.geometry?.material(named: "lamp_bulb_MAT")?.diffuse.contents = UIColor.white
                    node.geometry?.material(named: "lamp_bulb_MAT")?.selfIllumination.contents = UIColor.white
                }
                else
                {
                    node.geometry?.material(named: "lamp_bulb_MAT")?.diffuse.contents = UIColor.yellow
                    node.geometry?.material(named: "lamp_bulb_MAT")?.selfIllumination.contents = UIColor.yellow
                }
                
                
                
            }
        }
    }
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            
            let results = hitTest.first!
            let node = results.node.parent
            
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(pinchAction)
            sender.scale = 1.0
        }
        
        
    }
    
    
    // MARK: - Error handling
    
    func displayErrorMessage(target:ViewController,title: String, message: String, allowRestart: Bool = false) {
        // Blur the background.
        target.textManager.blurBackground()
        
        if allowRestart {
            // Present an alert informing about the error that has occurred.
            let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
                target.textManager.unblurBackground()
                target.restartExperience(self)
            }
            target.textManager.showAlert(title: title, message: message, actions: [restartAction])
        } else {
            target.textManager.showAlert(title: title, message: message, actions: [])
        }
    }
    
    // MARK: - Planes
    
    func addPlane(target:ViewController,node: SCNNode, anchor: ARPlaneAnchor) {
        
        let plane = Plane(anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
        
        target.textManager.cancelScheduledMessage(forType: .planeEstimation)
        target.textManager.showMessage("SURFACE DETECTED")
        if target.virtualObjectManager.virtualObjects.isEmpty {
            target.textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
        }
    }
    
    func updatePlane(target:ViewController,anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(target:ViewController,anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    // MARK: - Focus Squares
    
    func setupFocusSquare(target:ViewController) {
        target.serialQueue.async {
            self.focusSquare?.isHidden = true
            self.focusSquare?.removeFromParentNode()
            self.focusSquare = FocusSquare()
            target.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
        }
        
        target.textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
    func updateFocusSquare(target:ViewController) {
        guard let screenCenter = target.screenCenter else { return }
        
        DispatchQueue.main.async {
            var objectVisible = false
            for object in target.virtualObjectManager.virtualObjects {
                if target.sceneView.isNode(object, insideFrustumOf: target.sceneView.pointOfView!) {
                    objectVisible = true
                    break
                }
            }
            
            if objectVisible {
                self.focusSquare?.hide()
            } else {
                self.focusSquare?.unhide()
            }
            
            let (worldPos, planeAnchor, _) = target.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
                                                                                                   in: target.sceneView,
                                                                                                       objectPos: self.focusSquare?.simdPosition)
            if let worldPos = worldPos {
                target.serialQueue.async {
                    self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: target.session.currentFrame?.camera)
                }
                target.textManager.cancelScheduledMessage(forType: .focusSquare)
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,VirtualObjectManagerDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.arSceneDelegate?.updateFocusSquare(target: self)
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = session.currentFrame?.lightEstimate {
            sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: DispatchQueue.main)
        } else {
            sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: DispatchQueue.main)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //serialQueue.async {
        self.arSceneDelegate?.addPlane(target: self, node: node, anchor: planeAnchor)
        self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        //}
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //serialQueue.async {
        self.arSceneDelegate?.updatePlane(target: self, anchor: planeAnchor)
        self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        //}
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //serialQueue.async {
        self.arSceneDelegate?.removePlane(target: self, anchor: planeAnchor)
        //}
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable:
            self.collectionViewHeight.constant = 0
            fallthrough
        case .limited:
            self.collectionViewHeight.constant = 0
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            self.collectionViewHeight.constant = 100
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        self.arSceneDelegate?.displayErrorMessage(target: self, title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        textManager.blurBackground()
        textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        textManager.unblurBackground()
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        restartExperience(self)
        textManager.showMessage("RESETTING SESSION")
    }
    
    
    
    // MARK: - CollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VirtualObjectManager.availableObjects.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "objcell", for: indexPath) as? ARObjectCollectionViewCell else {
            fatalError("Expected `ARObjectCollectionViewCell` type for reuseIdentifier objcell. Check the configuration in Main.storyboard.")
        }
        
        cell.object = VirtualObjectManager.availableObjects[indexPath.row]
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            guard let cameraTransform = session.currentFrame?.camera.transform else {
                return
            }
            
            let definition = VirtualObjectManager.availableObjects[indexPath.row]
            let object = VirtualObject(definition: definition)
            let position = self.arSceneDelegate?.focusSquare?.lastPosition ?? float3(0)
            virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
            if object.parent == nil {
                serialQueue.async {
                    
                    self.sceneView.scene.rootNode.addChildNode(object)
                    
                    
                }
            }
        }
    }
    
    // MARK: - Virtual Object Manager Delegate
    
    func virtualObjectManager(_ manager: VirtualObjectManager, willLoad object: VirtualObject) {
        DispatchQueue.main.async {
            // Show progress indicator
            self.spinner = UIActivityIndicatorView()
            self.spinner!.center = self.sceneView.center
            self.spinner!.bounds.size = CGSize(width:10, height: 10)
            
            self.sceneView.addSubview(self.spinner!)
            self.spinner!.startAnimating()
            
            self.isLoadingObject = true
        }
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, didLoad object: VirtualObject) {
        DispatchQueue.main.async {
            self.isLoadingObject = false
            
            // Remove progress indicator
            self.spinner?.removeFromSuperview()
            
        }
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlace object: VirtualObject) {
        textManager.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
    }
    
    
    // MARK: - Gesture Recognizers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if virtualObjectManager.virtualObjects.isEmpty {
            return
        }
        virtualObjectManager.reactToTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        virtualObjectManager.reactToTouchesCancelled(touches, with: event)
    }
}
