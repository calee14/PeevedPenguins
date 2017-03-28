//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Cappillen on 3/25/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //game object connnections
    var catapultArm: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        //Set reference to catapultArm node
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Add a new penguin to the scene
        let rescourcePath = Bundle.main.path(forResource: "Penguin", ofType: "sks")
        let penguin = MSReferenceNode(url: NSURL(fileURLWithPath: rescourcePath!) as URL)
        addChild(penguin)
        
        //Move penguin to the catapult bucket area
        penguin.avatar.position = catapultArm.position + CGPoint(x: 32, y: 50)
        
        //Impulse vector
        let launchDirection = CGVector(dx: 1, dy: 0)
        let force = launchDirection * 500
        
        //Apply impulse to penguin
        penguin.avatar.physicsBody?.applyImpulse(force)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
