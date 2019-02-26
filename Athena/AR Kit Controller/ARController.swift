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
import Vision


struct ListObject: Decodable {
    let id: Int
    let address: String!
    let rent: Int!
    let valuation: Int!
    let bedrooms: Int!
    let bathrooms: Int!
    let area: Int!
    let numFloors: Int!
    
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case address = "address"
        case rent  = "rent"
        case valuation = "valuation"
        case bedrooms = "bedrooms"
        case bathrooms = "bathrooms"
        case area = "area"
        case numFloors = "numFloors"
    }
}



class ARController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {
    
    //    var listing_Array = [ListObject]() //Array of dictionary
    var arrRes = [ListObject]() //Array of dictionary
    
    let textDepth : Float = 0.01 // the 'depth' of 3D text
    
    // COREML
    var visionRequests = [VNRequest]()
    
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    
    var latestPrediction : String = "…" // a variable containing the latest CoreML prediction
    
    @IBOutlet weak var discButton: UIButton!
    
    @IBOutlet weak var listing_CollectionVW: UICollectionView!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var camButton: UIButton!
    
    @IBOutlet var backRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var gsdgs: UILabel!
    
    
    @IBOutlet var leftRec: UISwipeGestureRecognizer!
    
    @IBOutlet var sceneView: ARSCNView!
    
    var destinationLocation: CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    var directionsValue: Double!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        intialDataLoader()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 intialDataLoader()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func intialDataLoader() {
        
        locationManager.requestAlwaysAuthorization()
        
        // Hiding Initial Cardview
        listing_CollectionVW.isHidden = true

        
        

            sceneView.delegate = self

        
        
        
        // Show statistics such as fps and timing information
        
        // Shows Yellow Dots
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        
        
        locationManager.delegate = self
        
        // Set up Vision Model
//        guard let selectedModel = try? VNCoreMLModel(for: RN1015k500().model) else { // (Optional) This can be replaced with other models on https://developer.apple.com/machine-learning/
//            fatalError("Framework Not Implemented Correclty")
//        }
        
        // Set up Vision-CoreML Request
//        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
//        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
//        visionRequests = [classificationRequest]
        
        // Begin Loop to Update CoreML
        //        loopCoreMLUpdate()
        
        // Collection View Information
        listing_CollectionVW.delegate = self
        listing_CollectionVW.dataSource = self
        
        // Data Settings Function Calls
        let alighnemtInfo = ARConfiguration.WorldAlignment.gravityAndHeading
        print(alighnemtInfo)
        
        // Accuracy of the cordinate system
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Begin Tracking
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ARController.myviewTapped(_:)))
        
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.isUserInteractionEnabled = true
        
        for result in sceneView.hitTest(CGPoint(x: 0.5, y: 0.5), types: [.existingPlaneUsingExtent, .featurePoint]) {
            print(result.distance, result.worldTransform)
        }
    }
    
    
    fileprivate func fetchJSON() {
        let urlString = "https://morning-fjord-31620.herokuapp.com/building/\(destinationLocation.latitude)/\(destinationLocation.longitude)/\(String(describing: directionsValue!))"
        print(urlString)
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                }
                
                guard let data = data else { return }
                
                do {
                    // link in description for video on JSONDecoder
                    let decoder = JSONDecoder()
                    
                    var converterHandler = try decoder.decode(ListObject.self, from: data)
                    self.arrRes = [converterHandler]
                    
                    self.listing_CollectionVW.reloadData()
                    
                } catch let jsonErr {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.handleALERT()
                    })
                    print("Failed to decode:", jsonErr)

                    return
                }
            }
            }.resume()
        
        
    }
    
    @objc func handleALERT() {

        let alert = UIAlertController(title: "Uh oh", message: "This area does not look like it has any available houses. Please try again later", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        
        self.present(alert, animated: true)
    }
    
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        // Proceed to do the function that
        // @todo send degree and longitutude And Lat
        locationManager.delegate = self as CLLocationManagerDelegate
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
        
        fetchJSON()
        print(arrRes.count)
        listing_CollectionVW.isHidden = false
        //if tapGesture returns a value{
        //infoView.isHidden = false
        //houseImage.image = (pull from backend)
        // }
        
        //else {
        //infoView.isHidden = true
        //}
        viewInformationHandler()
        
        
    }
    
    func viewInformationHandler() {
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create 3D Text
            let node : SCNNode = createNewBubbleParentNode(latestPrediction)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
        
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.010)
        sphere.firstMaterial?.diffuse.contents = UIColor.green
        let sphereNode = SCNNode(geometry: sphere)
        
        // BUBBLE PARENT NODE
        let circularNodeParrent = SCNNode()
        circularNodeParrent.addChildNode(sphereNode)
        circularNodeParrent.constraints = [billboardConstraint]
        
        return circularNodeParrent
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }

        // Get Classifications
        let classifications = observations[0...1] // top 2 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")


        DispatchQueue.main.async {
            // Print Classifications
            print(classifications)
            print("--")

            // Store the latest prediction
            var objectName:String = "…"
            objectName = classifications.components(separatedBy: "-")[0]
            objectName = objectName.components(separatedBy: ",")[0]
            self.latestPrediction = objectName

        }
    }
    
    func loopCoreMLUpdate() {
        // While(True)
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            // 2. Recursive Call
            self.loopCoreMLUpdate()
        }
        
    }
    
    func updateCoreML() {
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
  
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
    
    
    func intialDesignLoader() {
        
        discButton.layer.cornerRadius = discButton.bounds.size.height/2
        discButton.clipsToBounds = true
        
        
        moreButton.layer.cornerRadius = moreButton.bounds.size.height/2
        moreButton.clipsToBounds = true
        
        
        camButton.layer.cornerRadius = camButton.bounds.size.height/2
        camButton.clipsToBounds = true
        camButton.isEnabled = false
        
    }
    
    
    @IBAction func backSwiped(_ sender: Any) {
        performSegue(withIdentifier: "camToDisc", sender: self)
    }
    
    @IBAction func leftSwiped(_ sender: Any) {
        performSegue(withIdentifier: "homeToMore", sender: self)
        
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
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
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
        
        if locations.first != nil {
            print("location:: (location)")
        }
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        destinationLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        manager.stopUpdatingLocation()
        
        //            var newLocation = locationWithBearing(bearing: directionsValue, distanceMeters: (5.0), origin: coordinations)
    }
    
    
    
    // MARK: - ARSCNViewDelegate
    
    //Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        
        
        return node
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
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
    
    @IBOutlet weak var Heroku: UILabel!
    @IBOutlet weak var sa: UILabel!
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        directionsValue = newHeading.magneticHeading
        manager.stopUpdatingHeading()

        
        if locationManager.location != nil{
            
        }
    }
    
}
extension ARController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectionCell", for: indexPath) as! ARControllerCollectionVW
        let valz = arrRes[indexPath.row]
        
        cell.listing_Title.text = "\(valz.address!)"
        cell.listing_Location.text = "🏠 House is in the area \(valz.area!)"
        if(valz.valuation == 0 || valz.valuation == nil) {
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            // localize to your grouping and decimal separator
            currencyFormatter.locale = Locale.current
            
            // We'll force unwrap with the !, if you've got defined data you may need more error checking
            let priceString = currencyFormatter.string(from: valz.rent! as NSNumber)!
            
            cell.listing_Variables.text = "Price: $\(priceString) \(valz.bedrooms!)bd \(valz.bathrooms!)ba"

        }
        cell.listing_Variables.text = "$\(valz.valuation!) \(valz.bedrooms!)bd \(valz.bathrooms!)ba"
        
        
        //        let imageURL = valz
        //        let url = URL(string: imageURL!)
        
        //        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        //            guard let data = data, error == nil else { return }
        //
        //            DispatchQueue.main.async() {    // execute on main thread
        //                cell.houseImage.image = UIImage(data: data)
        //            }
        //        }
        
        //        task.resume()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {}
    
    
}
