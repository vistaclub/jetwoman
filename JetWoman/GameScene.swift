//
//  GameScene.swift
//  JetWoman
//
//  Created by Jason Wong on 2018-06-22.
//  Copyright © 2018 Jason Wong. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var jetWoman : SKSpriteNode?
    private var startButton : SKSpriteNode?
    private var scoreLabel : SKLabelNode?
    private var highscorelabel : SKLabelNode?
    private var crashFire : SKNode?
    
    let characters = ["Click","A","B","C","D","E","1","2","3","4"]
    let keyCodes   = [-1,0,11,8,2,14,18,19,20,21]
    
    var currentCharacter : String?
    var currentKeyCode : Int?
    
    let jetWomanCategory : UInt32 = 2
    let spikesCategory : UInt32 = 3
    
    var score = 0
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            // label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        self.jetWoman = self.childNode(withName: "jetwoman") as? SKSpriteNode
        self.startButton = self.childNode(withName: "startbutton") as? SKSpriteNode
        self.scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        self.highscorelabel = self.childNode(withName: "highscorelabel") as? SKLabelNode
        self.crashFire = self.childNode(withName: "crashFire")
        crashFire?.alpha = 0.0

        let highscore = UserDefaults.standard.integer(forKey: "highscore")
        highscorelabel?.text = "High:\(highscore)"
        scoreLabel?.text = "Score:\(score)"
        
    }
    
    func startGame() {
        if let jetWoman = self.jetWoman {
            jetWoman.position = CGPoint(x: 0, y: 100)
            jetWoman.physicsBody?.pinned = false
       }
    }
    
    func updateHighScore() {
        let highscore = UserDefaults.standard.integer(forKey: "highscore")
        highscorelabel?.text = "High:\(highscore)"

    }
    
    func chooseNextKey() {
        let count = UInt32(characters.count)
        let randomIndex = Int(arc4random_uniform(count))
        currentCharacter = characters[randomIndex]
        currentKeyCode = keyCodes[randomIndex]
        if let label = self.label {
            label.text = currentCharacter
            label.alpha = 1.0
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = event.location(in: self)
        let nodesAtPoint = nodes(at: point)
        for node in nodesAtPoint {
            if node.name == "startbutton" {
                if let jetWoman = self.jetWoman {
                    jetWoman.position = CGPoint(x: 0, y: 100)
                    jetWoman.physicsBody?.pinned = false
                    jetWoman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
                    node.removeFromParent()
                    score = 0
                    scoreLabel?.text = "Score:\(score)"
                    chooseNextKey()
                    crashFire?.alpha = 0.0
                }
            }
        }
        if let theKeyCode = currentKeyCode {
            if theKeyCode == -1 {
                if let jetWoman = self.jetWoman {
                    jetWoman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: (200 - score*5)))
                    score += 1
                    scoreLabel?.text = "Score:\(score)"
                    chooseNextKey()
                }
            }
        }
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        if let theKeyCode = currentKeyCode {
            if theKeyCode >= 0 {
            switch event.keyCode {
            case UInt16(theKeyCode):
                if let jetWoman = self.jetWoman {
                    jetWoman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: (200 - score*5)))
                    score += 1
                    scoreLabel?.text = "Score:\(score)"
                    chooseNextKey()
                }
            default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
            }
        }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == spikesCategory || bodyB.categoryBitMask == spikesCategory {
            print("Ran into Spikes")
            if let startButton = self.startButton {
                if startButton.parent != self {
                    crashFire?.alpha = 1.0
                    addChild(startButton)
                    currentCharacter = nil
                    currentKeyCode = nil
                    if let label = self.label {
                        label.alpha = 0.0
                    }
                    // Check if high score
                    let highscore = UserDefaults.standard.integer(forKey: "highscore")
                    if score > highscore {
                        UserDefaults.standard.set(score, forKey: "highscore")
                        UserDefaults.standard.synchronize()
                        highscorelabel?.text = "High:\(score)"
                        
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
