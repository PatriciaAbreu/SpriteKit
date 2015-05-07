//
//  GamerOverScene.swift
//  Teste1_SpriteKit
//
//  Created by Patricia de Abreu on 04/05/15.
//  Copyright (c) 2015 Patricia de Abreu. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {

    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor(red: 255/255, green: 92/255, blue: 107/255, alpha: 1)
        
        // 2
        var message = won ? "You Won!" : "GAME OVER!!!"
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let view = view {
            let scene = GameScene(size: size)
         
            view.presentScene(scene)
        }
    }
}
