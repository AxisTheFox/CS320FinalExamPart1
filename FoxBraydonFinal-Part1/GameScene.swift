//
//  GameScene.swift
//  FoxBraydonFinal-Part1
//
//  Created by Braydon Fox on 12/10/16.
//  Copyright © 2016 Braydon Fox. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let launcher = SKSpriteNode(imageNamed: "red-circle")
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        launcher.setScale(0.4)
        launcher.position = CGPoint(x: self.size.width/2, y: 0)
        launcher.zPosition = 2
        self.addChild(launcher)
        
    }
    
    func launchProjectileTo(location: CGPoint) {
        
        let projectile = SKSpriteNode(imageNamed: "red-circle")
        projectile.setScale(0.1)
        projectile.position = launcher.position
        projectile.zPosition = 1
        self.addChild(projectile)
        
        let moveProjectile = SKAction.move(to: location, duration: 0.75)
        let deleteProjectile = SKAction.removeFromParent()
        
        let projectileSequence = SKAction.sequence([moveProjectile, deleteProjectile])
        projectile.run(projectileSequence)
    
    }
    
    func spawnObject() {
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            launchProjectileTo(location: pointOfTouch)
            
        }
        
    }
    
}
