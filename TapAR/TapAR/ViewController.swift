//
//  ViewController.swift
//  TapAR
//
//  Created by Prajakta Morale on 12/1/17.
//  Copyright © 2017 Prajakta Morale. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    
    @IBOutlet weak var sceneView: ARSCNView!

    @IBOutlet weak var tapView: UITextView!
    
    @IBOutlet weak var methodStatus: UILabel!
    
    @IBOutlet weak var touchStatus: UILabel!
    
    @IBOutlet weak var tapStatus: UILabel!
    
    
    let bubbleDepth : Float = 0.01 // 3D text depth
    var augmenttext : String = "Tap" //String to display in bubble
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set view delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable Default Lighting - makes the 3D text a bit poppier.
        sceneView.autoenablesDefaultLighting = true
        
        
        // Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
       
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let tapCount = touch!.tapCount
        
        //tap status display on screen
        tapStatus.text = "\(tapCount) taps"
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let tapCount = touch!.tapCount
        
        //tap status display on screen
        tapStatus.text = "\(tapCount) taps"
        print(tapStatus.text!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touchCount = touches.count
        let touch = touches.first
        let tapCount = touch!.tapCount
        
        //tapstatus display on screen
        tapStatus.text = "\(tapCount) taps"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
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
        
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            
            
            
            var objectA:String = "Tap";
            objectA = (String(describing: self.tapStatus.text ?? "taps"));
            self.augmenttext = objectA
            
        }
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint])
        // For hitpoints.
        
        if let closestResult = arHitTestResults.first {
            
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create 3D Text
            let node : SCNNode = createNewBubbleParentNode(augmenttext)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        
        // billboard constrains
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        //bubble
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        var font = UIFont(name: "Arial", size: 0.20)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents = UIColor.red
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        //node
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
       
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        // BUBBLE parent
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
    }
    
        }

extension UIFont {

    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
