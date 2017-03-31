//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Cappillen on 3/25/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //game object connnections
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    
    //Level loader holder
    var levelNode: SKNode!
    
    //Camera helpers
    var cameraTarget: SKNode?
    
    //UI Connections
    var buttonRestart: MSButtonNode!
    
    //Physics helpers
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointPin?
    
    override func didMove(to view: SKView) {
        //Setup your scene here
        
        //Set physics contact delegate 
        physicsWorld.contactDelegate = self
        
        //Set reference to catapultArm node
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        
        //Set reference to the level loader node
        levelNode = childNode(withName: "//levelNode")
        
        //Load Level 1
        let resourcePath = Bundle.main.path(forResource: "Level1", ofType: "sks")
        let newLevel = SKReferenceNode(url: NSURL(fileURLWithPath: resourcePath!) as URL)
        levelNode.addChild(newLevel)
        
        //Create catapult arm physics body of type alpha
        let catapultArmBody = SKPhysicsBody (texture: catapultArm!.texture!, size: catapultArm.size)
        
        //Set mass, needs to be heavy enough to hit the penguin with solid force
        catapultArmBody.mass = 0.5
        
        //Apply gravity to catapultArm
        catapultArmBody.affectedByGravity = false
        
        //Improves physics collision handling of fast moveing objects
        catapultArmBody.usesPreciseCollisionDetection = true
        
        //Assign the physics body to the catapult arm
        catapultArm.physicsBody = catapultArmBody
        
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
        
        //Pin joint catapult and catapult arm
        let catapultPinJoint = SKPhysicsJointPin.joint(withBodyA: catapult.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: CGPoint(x: 220, y: 105))
        physicsWorld.add(catapultPinJoint)
        
        //Spring joint catapult arm and cantilever node 
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: catapultArm.position + CGPoint(x:17, y:30), anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        
        //Make this joint a but more springy
        catapultSpringJoint.frequency = 3.5
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Called when a touch begins
        
        //There will only be one touch as multi touch is not enabled by default
        for touch in touches {
            
            //Grab scene position of touch
            let location = touch.location(in: self)
            
            //Get node reference if we're touching a node 
            let touchedNode = atPoint(location)
            
            //Is it the catapult arm?
            if touchedNode.name == "catapultArm" {
                
                //Reset touch node position
                touchNode.position = location
                
                //Spring joint touch node and catapult arm
                touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
                physicsWorld.add(touchJoint!)
                
                let resourcePath = Bundle.main.path(forResource: "Penguin", ofType: "sks")
                let penguin = MSReferenceNode(url: NSURL(fileURLWithPath: resourcePath!) as URL)
                addChild(penguin)
                
                //Position penguin in hte catapult bucket area
                penguin.avatar.position = catapultArm.position + CGPoint(x: 32, y: 50)
                
                //Improves physics collision handling of fast moving objects
                penguin.avatar.physicsBody?.usesPreciseCollisionDetection = true
                
                //Setup pin joint between penguin and catapult arm
                penguinJoint = SKPhysicsJointPin.joint(withBodyA: catapultArm.physicsBody!, bodyB: penguin.avatar.physicsBody!, anchor: penguin.avatar.position)
                physicsWorld.add(penguinJoint!)
                
                //Remove any camera actions
                camera?.removeAllActions()
                
                //Set camera to follow penguin
                cameraTarget = penguin.avatar
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Called when a touch moved
        
        //There will only be one touch as multi touch is not enabled by default
        for toucn in touches {
            
            //Grab scene position of touch and update touchNode position
            let location         = toucn.location(in: self)
            touchNode.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Called when a touch ended
        
        //Let it fly!, remove joints used in catapult launch
        if let touchJoint = touchJoint { physicsWorld.remove(touchJoint) }
        if let penguinJoint = penguinJoint { physicsWorld.remove(penguinJoint) }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Physics contact delegate implementation
        
        //Get reference to the bodies involved in the collision
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        //Get references to the physics body parent SKSprinteNode
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        //Check if either physics body was a seal
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            //Was the collision more than a gentle nudge?
            if contact.collisionImpulse > 2.0 {
                
                //Kill the Seal(s)
                if contactA.categoryBitMask == 2 { dieSeal(node: nodeA) }
                if contactB.categoryBitMask == 2 { dieSeal(node: nodeB) }
            }
        }
        
    }
    
    func dieSeal(node: SKNode) {
        //Seal Death
        
        //Load our particle effect
        let particles = SKEmitterNode(fileNamed: "SealExplosion")!
        
        //Play SFX
        let sealSFX = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
        self.run(sealSFX)
        
        //Convert node location (currently inside level 1, to scene space)
        particles.position = convert(node.position, from: node)
        
        //Restrict total particles to reduce runtime of particle
        particles.numParticlesToEmit = 25
        
        //Add particles to scene
        addChild(particles)
        
        //Create our hero death action
        let sealDeath = SKAction.run({
            //Remove Seal node from Scene
            node.removeFromParent()
            
        })
        
        self.run(sealDeath)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //Check we have a valid camera target to follow
        if let cameraTarget = cameraTarget {
            
            //Set camera position to follow target horizontally, keep vertical locked
            camera?.position = CGPoint(x: cameraTarget.position.x, y: camera!.position.y)
            
            //Clamp camera scrolling to our visible scene area only
            camera?.position.x.clamp(v1: 283, 677)
            
            //Check penguin has come to rest
            if (cameraTarget.physicsBody?.joints.count)! == 0 && (cameraTarget.physicsBody?.velocity.length())! < 0.18 {
                
                cameraTarget.removeFromParent()
                
                //Reset catapult arm
                catapultArm.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                catapultArm.physicsBody?.angularVelocity = 0
                catapultArm.zRotation = 0
                
                //Reset camera
                let cameraReset = SKAction.move(to: CGPoint(x: 284, y: camera!.position.y), duration: 1.5)
                let cameraDelay = SKAction.wait(forDuration: 0.5)
                let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
                
                camera?.run(cameraSequence)
                
            }
            
            if (cameraTarget.position.x) > 980 || (cameraTarget.position.x) < -10 {
                
                cameraTarget.removeFromParent()
                
                //Reset catapult arm
                catapultArm.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                catapultArm.physicsBody?.angularVelocity = 0
                catapultArm.zRotation = 0
                
                //Reset camera
                let cameraReset = SKAction.move(to: CGPoint(x: 284, y: camera!.position.y), duration: 1.5)
                let cameraDelay = SKAction.wait(forDuration: 0.5)
                let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
                
                camera?.run(cameraSequence)
            }
        }
        
        
    }
}
