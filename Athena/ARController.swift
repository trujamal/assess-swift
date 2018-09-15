//
//  HomeController.swift
//  Athena
//
//  Created by Aalap Patel | Jamal Rasool on 9/14/18.
//
//

import Foundation
import UIKit
import ARKit
import CoreLocation
import MapKit

class ARController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

   
    @IBOutlet weak var discButton: UIButton!
    
    
    @IBOutlet weak var moreButton: UIButton!
    

    @IBOutlet weak var camView: UIView!

  @IBOutlet weak var camButton: UIButton!
    
    @IBOutlet var backRecognizer: UISwipeGestureRecognizer!
    
    @IBOutlet var sceneView: ARSCNView!
    
    var destinationLocation: CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    var directionsValue: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    
        // Shows Yellow Dots
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Data Settings Function Calls
        configuration_Settings()
        getUserLocation()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeController.myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        
        for result in sceneView.hitTest(CGPoint(x: 0.5, y: 0.5), types: [.existingPlaneUsingExtent, .featurePoint]) {
            print(result.distance, result.worldTransform)
        }
        
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        // Proceed to do the function that
        // @todo send degree and longitutude And Lat
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Create a transform with a translation of 0.2 meters in front of the camera.
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        
        let transform = simd_mul((sceneView.session.currentFrame?.camera.transform)!, translation)
        
        // Add a new anchor to the session.
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    func intialDesignLoader() {
        
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
        configuration.planeDetection = .vertical
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func configuration_Settings() {
        let alighnemtInfo = ARConfiguration.WorldAlignment.gravityAndHeading
        print(alighnemtInfo)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        // Create anchor using the camera’s current position
        if let currentFrame = sceneView.session.currentFrame {
            // Create a transform with a translation of 0.2 meters in front
            // of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            let transform = simd_mul(
                currentFrame.camera.transform,
                translation
            )
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's
        // session.
        let labelNode = SKLabelNode(text: "🏠 A New Place Is Found")
        
        return labelNode;
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        destinationLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        manager.stopUpdatingLocation()
        
        //        var newLocation = locationWithBearing(bearing: directionsValue, distanceMeters: (5.0), origin: coordinations)
    }
    
    func getUserLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestLocation()
        locationManager.delegate = self as! CLLocationManagerDelegate
        
        // Accuracy of the cordinate system
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Begin Tracking
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
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
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if anchor is ARPlaneAnchor {
            print("Horizontal surface detected")
        }
        
        
        return node
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6)
        
        let rbearing = bearing * Double.pi / 180.0
        
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(rbearing))
        let lon2 = lon1 + atan2(sin(rbearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        directionsValue = newHeading.magneticHeading
        manager.stopUpdatingHeading()
        
        callWebQueryReq(destinationLocation, didGetDegrees: directionsValue)
    }
    
    func callWebQueryReq(_ coordinates: CLLocationCoordinate2D, didGetDegrees: Double) {
        
        // Handle WebCall
        let parameters = ["latitude: \(coordinates.latitude)", "longitude: \(coordinates.longitude)","Direction: \(didGetDegrees)"] as [String]
        
        //create the url with URL
        let url = URL(string: "www.thisismylink.com/postName.php")! //Should be herroku backend
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    
                    
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
        
        
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

extension ARController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}
