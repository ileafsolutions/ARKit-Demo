//
//  ViewController.swift
//  AR-Demo
//
//  Created by Vivek iLeaf on 10/16/17.
//  Copyright © 2017 Vivek iLeaf. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - ARKit Config Properties
    var arSceneDelegate : ViewControllerProtocol? = nil
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    private var selectedVirtualObjectRows = IndexSet()
 
    @IBOutlet weak var collectionView: UICollectionView!
    var screenCenter: CGPoint?

    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Virtual Object Manipulation Properties
    
    var dragOnInfinitePlanesEnabled = false
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {

                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var restartExperienceButton: UIButton!
    
    // MARK: - Queues
    
	let serialQueue = //DispatchQueue.main
        DispatchQueue(label: "com.levin.AR-Demo.serialSceneKitQueue")
	
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arSceneDelegate = ViewControllerViewModel() as ViewControllerProtocol
        self.arSceneDelegate?.didLoadARscene(target: self)

    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		if ARWorldTrackingConfiguration.isSupported {
			// Start the ARSession.
		self.arSceneDelegate?.resetTracking(target: self)
		} else {
			// This device does not support 6DOF world tracking.
			let sessionErrorMsg = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
			"Please quit the application."
			self.arSceneDelegate?.displayErrorMessage(target: self, title: "Unsupported platform", message: sessionErrorMsg, allowRestart: false)
		}
        
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
        
	}
   
    @IBAction func captureView(_ sender: UIButton)
    {
        self.arSceneDelegate?.screenShotMethod(target: self)
    }
    @IBAction func restartExperience(_ sender: Any) {
        self.arSceneDelegate?.restartSession(target: self)
    }

    

}

