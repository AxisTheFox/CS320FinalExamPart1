//
//  GameScene.swift
//  FoxBraydonFinal-Part1
//
//  Created by Braydon Fox on 12/10/16.
//  Copyright © 2016 Braydon Fox. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameOver: Bool = false
    
    var gameScore = 0
    let scoreLabel = SKLabelNode()
    
    var timer = Timer()
    var countdown = 30
    
    let restartButton = SKSpriteNode(imageNamed: "refresh")
    
    let launcher = SKSpriteNode(imageNamed: "red-circle")
    
    struct PhysicsCategories {
        
        static let None : UInt32 = 0            // 0
        static let Projectile : UInt32 = 0b1    // 1
        static let Object : UInt32 = 0b10       // 2
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
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
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        launcher.setScale(0.4)
        launcher.position = CGPoint(x: self.size.width/2, y: 0)
        launcher.zPosition = 2
        self.addChild(launcher)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.black
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        scoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        scoreLabel.isHidden = true
        self.addChild(scoreLabel)
        
        restartButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        restartButton.zPosition = 100
        restartButton.name = "restartButton"
        restartButton.isHidden = true
        addChild(restartButton)
        
        startNewLevel()
        
    }
    
    func addScore() {
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Projectile && body2.categoryBitMask == PhysicsCategories.Object {
            
            // If projectile has hit the object
            addScore()
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    func startNewLevel() {
        
        gameOver = false
        
        gameScore = 0
        
        restartButton.isHidden = true
        
        if self.action(forKey: "spawningObjects") != nil {
            self.removeAction(forKey: "spawningObjects")
        }
        
        let spawn = SKAction.run(spawnObject)
        let waitToSpawn = SKAction.wait(forDuration: 0.7)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningObjects")
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if countdown > 0 {
            countdown -= 1
        } else {
            gameOver = true
            self.removeAction(forKey: "spawningObjects")
            for child in self.children {
                if child.physicsBody?.categoryBitMask == PhysicsCategories.Object || child.physicsBody?.categoryBitMask == PhysicsCategories.Projectile {
                    removeFromParent()
                }
            }
            restartButton.isHidden = false
            scoreLabel.isHidden = false
            countdown = 30
        }
    }
    
    func launchProjectileTo(location: CGPoint) {
        
        let projectile = SKSpriteNode(imageNamed: "red-circle")
        projectile.setScale(0.1)
        projectile.position = launcher.position
        projectile.zPosition = 1
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody!.affectedByGravity = false
        projectile.physicsBody!.categoryBitMask = PhysicsCategories.Projectile
        projectile.physicsBody!.collisionBitMask = PhysicsCategories.None
        projectile.physicsBody!.contactTestBitMask = PhysicsCategories.Object
        self.addChild(projectile)
        
        let moveProjectile = SKAction.move(to: location, duration: 0.4)
        let deleteProjectile = SKAction.removeFromParent()
        
        let projectileSequence = SKAction.sequence([moveProjectile, deleteProjectile])
        projectile.run(projectileSequence)
    
    }
    
    func spawnObject() {
        
        let randomXPosition = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXPosition, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXPosition, y: 0 - self.size.height * 1.2)
        
        let object = SKSpriteNode(imageNamed: "blue-circle")
        object.setScale(0.25)
        object.position = startPoint
        object.zPosition = 2
        object.physicsBody = SKPhysicsBody(circleOfRadius: object.size.width / 2)
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.categoryBitMask = PhysicsCategories.Object
        object.physicsBody!.collisionBitMask = PhysicsCategories.None
        object.physicsBody!.contactTestBitMask = PhysicsCategories.Projectile
        self.addChild(object)
        
        let moveObject = SKAction.move(to: endPoint, duration: 6.0)
        let deleteObject = SKAction.removeFromParent()
        let objectSequence = SKAction.sequence([moveObject, deleteObject])
        object.run(objectSequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if (!gameOver) {
                
                launchProjectileTo(location: pointOfTouch)
                
            } else {
                
                let sprites = nodes(at: pointOfTouch)
                
                for sprite in sprites {
                    
                    if let spriteNode = sprite as? SKSpriteNode {
                        
                        if spriteNode.name != nil {
                            
                            if spriteNode.name == "restartButton" {
                                
                                startNewLevel()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
}
