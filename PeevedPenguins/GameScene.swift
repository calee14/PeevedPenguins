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
    
    //Level loader holder
    var levelNode: SKNode!
    
    //Camera helpers
    var cameraTarget: SKNode?
    
    //UI Connections
    var buttonRestart: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //Set reference to catapultArm node
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        
        //Set reference to the level loader node
        levelNode = childNode(withName: "//levelNode")
        
        //Load Level 1
        let resourcePath = Bundle.main.path(forResource: "Level1", ofType: "sks")
        let newLevel = SKReferenceNode(url: NSURL(fileURLWithPath: resourcePath!) as URL)
        levelNode.addChild(newLevel)
        
        //UI Connections
        buttonRestart = childNode(withName: "//buttonRestart") as! MSButtonNode
        
        //Setup restart button selection handler
        buttonRestart.selectedHandler = {
            
            //Grab reference to our spriteKit view
            let skView = self.view as SKView!
            
            //Load Game scene
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            //Ensure correct aspect mode
            scene?.scaleMode = .aspectFill
            
            //Show debug
            skView?.showsPhysics = true
            skView?.showsDrawCount = true
            skView?.showsFPS = false
            
            //Restart game scene
            skView?.presentScene(scene)
        }
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
        
        //Set camera to follow penguin
        cameraTarget = penguin.avatar
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //Check we have a valid camera target to follow
        if let cameraTarget = cameraTarget {
            
            //Set camera position to follow target horizontally, keep vertical locked
            camera?.position = CGPoint(x: cameraTarget.position.x, y: camera!.position.y)
            
        }
        
        //Clamp camera scrolling to our visible scene area only
        camera?.position.x.clamp(v1: 283, 677)
        
    }
}
