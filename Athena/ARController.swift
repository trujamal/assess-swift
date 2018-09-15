//
//  ViewController.swift
//  Athena
//
//  Created by Aalap Patel on 9/14/18.
//  Copyright © 2018 Aalap Patel. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var discView: UIView!
    @IBOutlet weak var discButton: UIButton!
    
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var camView: UIView!
    
    @IBOutlet weak var camButton: UIButton!
    
    @IBOutlet var backRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discView.layer.cornerRadius = discView.bounds.size.height/2
        discView.clipsToBounds = true
        
        discButton.layer.cornerRadius = discButton.bounds.size.height/2
        discButton.clipsToBounds = true
        
        
        moreView.layer.cornerRadius = moreView.bounds.size.height/2
        moreView.clipsToBounds = true
        
        moreButton.layer.cornerRadius = moreButton.bounds.size.height/2
        moreButton.clipsToBounds = true
        
        camView.layer.cornerRadius = camView.bounds.size.height/2
        camView.clipsToBounds = true
        
        camButton.layer.cornerRadius = camButton.bounds.size.height/2
        camButton.clipsToBounds = true
        camButton.isEnabled = false
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        

        
    }
    
    
    @IBAction func backSwiped(_ sender: Any) {
        performSegue(withIdentifier: "camToDisc", sender: self)
    }
    
    @IBAction func discPressed(_ sender: Any) {
        performSegue(withIdentifier: "camToDisc", sender: self)
        
    }
    @IBAction func moreClicked(_ sender: Any) {
        performSegue(withIdentifier: "homeToMore", sender: self)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
extension UITabBarController {
    
    /**
     Show or hide the tab bar.
     
     - Parameter hidden: `true` if the bar should be hidden.
     - Parameter animated: `true` if the action should be animated.
     - Parameter transitionCoordinator: An optional `UIViewControllerTransitionCoordinator` to perform the animation
     along side with. For example during a push on a `UINavigationController`.
     */
    func setTabBar(
        hidden: Bool,
        animated: Bool = true,
        along transitionCoordinator: UIViewControllerTransitionCoordinator? = nil
        ) {
        guard isTabBarHidden != hidden else { return }
        
        let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        let vc: UIViewController? = viewControllers?[selectedIndex]
        var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
        let originalInsets = newInsets
        newInsets?.bottom -= offsetY
        
        /// Helper method for updating child view controller's safe area insets.
        func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
            cvc?.additionalSafeAreaInsets = additionalSafeArea
            cvc?.view.setNeedsLayout()
        }
        
        // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
        if hidden, let insets = newInsets { set(childViewController: vc, additionalSafeArea: insets) }
        
        guard animated else {
            tabBar.frame = endFrame
            return
        }
        
        // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
        // if we're showing the tab bar.
        weak var tabBarRef = self.tabBar
        if let tc = transitionCoordinator {
            tc.animateAlongsideTransition(in: self.view, animation: { _ in tabBarRef?.frame = endFrame }) { context in
                if !hidden, let insets = context.isCancelled ? originalInsets : newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: { tabBarRef?.frame = endFrame }) { didFinish in
                if !hidden, didFinish, let insets = newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        }
    }
    
    /// `true` if the tab bar is currently hidden.
    var isTabBarHidden: Bool {
        return !tabBar.frame.intersects(view.frame)
    }
    
}
