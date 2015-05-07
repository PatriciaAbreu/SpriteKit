//
//  GameViewController.swift
//  Teste1_SpriteKit
//
//  Created by Patricia de Abreu on 04/05/15.
//  Copyright (c) 2015 Patricia de Abreu. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}



class GameViewController: UIViewController {

    var background: SKSpriteNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
//            // Configure the view.
//            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            
//            /* Sprite Kit applies additional optimizations to improve rendering performance */
//            skView.ignoresSiblingOrder = true
//            
//            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = .ResizeFill
//            
//            loadBackground(scene)
//
//            skView.presentScene(scene)
        
        
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsPhysics = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
//            loadBackground(scene)
            
            skView.presentScene(scene)
        }
    }
    
    
    
    func loadBackground(scene: GameScene){
        if background == nil {
            background = SKSpriteNode(imageNamed: "background")
            background.name = "background"
            background.size = scene.size
            background.position = CGPointMake(scene.size.width/2, scene.size.height/2)
            scene.addChild(background)
        }
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
