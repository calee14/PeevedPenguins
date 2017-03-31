//
//  MainScene.swift
//  PeevedPenguins
//
//  Created by Cappillen on 3/25/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    
    //UI Connections
    var buttonPlay: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //Setup your scene here 
        
        //Set UI connections
        buttonPlay = self.childNode(withName: "buttonPlay") as! MSButtonNode
        
        //Setup restart button selection handler
        buttonPlay.selectedHandler = {
            
            //Grab reference to our SpriteKit view
            let skView = self.view as SKView!
            
            //Load Game Scene
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            //Ensure correct aspect mode
            scene?.scaleMode = .aspectFit
            
            //Show debug
            skView?.showsPhysics = true
            skView?.showsDrawCount = true
            skView?.showsFPS = true
            
            //Start game scene 
            skView?.presentScene(scene)
            
        }
    }
}

