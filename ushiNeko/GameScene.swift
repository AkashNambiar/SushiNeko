//
//  GameScene.swift
//  ushiNeko
//
//  Created by Akash Nambiar on 6/25/17.
//  Copyright © 2017 Akash Nambiar. All rights reserved.
//

import SpriteKit

enum Side {
    case left, right, none
}

enum GameState {
    case title, ready, playing, gameOver
}

var sushiBase: SushiPiece!
var cat: Character!
var sushiTower: [SushiPiece] = []
var state: GameState = .title
var playButton: MSButtonNode!
var healthBar: SKSpriteNode!
var bar: SKSpriteNode!
var scoreLabel: SKLabelNode!

var health: CGFloat = 1.0 {
    didSet {
        /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
        healthBar.xScale = health
    }
}

var score: Int = 0 {
    didSet {
        scoreLabel.text = String(score)
    }
}

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        sushiBase = childNode(withName: "sushiBase") as! SushiPiece
        cat = childNode(withName: "character") as! Character
        playButton = childNode(withName: "playButton") as! MSButtonNode
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        bar = childNode(withName: "bar") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        playButton.selectedHandler = {
            state = .ready
        }
        
        sushiBase.connectChopsticks()
        
        sushiTower.removeAll()
        
        addPiece(side: .none)
        addRandomPiece(total: 10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        
        /* Game not ready to play */
        if state == .gameOver || state == .title { return }
        /* Game begins on first touch */
        if state == .ready {
            state = .playing
        }
        
        /* We only need a single touch here */
        let touch = touches.first!
        
        /* Get touch position in scene */
        let location = touch.location(in: self)
        
        /* Was touch on left/right hand side of screen? */
        if location.x > size.width / 2 {
            cat.side = .right
        } else {
            cat.side = .left
        }
        
        /* Grab sushi piece on top of the base sushi piece, it will always be 'first' */
        if let firstPiece = sushiTower.first as SushiPiece? {
            /* Check character side against sushi piece side (this is our death collision check)*/
            if cat.side == firstPiece.side {
                
                /* Drop all the sushi pieces down a place (visually) */
                moveTowerDown()
                
                gameOver()
                
                /* No need to continue as player is dead */
                return
            }
            
            /* Remove from sushi tower array */
            sushiTower.removeFirst()
            firstPiece.flip(cat.side)
            
            healthBar.zPosition += 1
            bar.zPosition += 1
            scoreLabel.zPosition += 1
            
            /* Add a new sushi piece to the top of the sushi tower */
            addRandomPiece(total: 1)
            
            //          addPiece(side: .none)
            //            moveTowerDown()
            
            
            health += 0.1
            score += 1
            
            if health > 1.0 {
                health = 1.0
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if state != .playing {
            return
        }
        /* Decrease Health */
        health -= 0.0
        /* Has the player ran out of health? */
        if health < 0 {
            gameOver()
        }
        
        moveTowerDown()
    }
    
    func addPiece(side : Side){
        /* Add a new sushi piece to the sushi tower */
        
        /* Copy original sushi piece */
        let newPiece = sushiBase.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        /* Access last piece properties */
        let lastPiece = sushiTower.last
        
        /* Add on top of last piece, default on first piece */
        let lastPosition = lastPiece?.position ?? sushiBase.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
        /* Increment Z to ensure it's on top of the last piece, default on first piece*/
        let lastZPosition = lastPiece?.zPosition ?? sushiBase.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        /* Set side */
        newPiece.side = side
        
        /* Add sushi to scene */
        addChild(newPiece)
        
        /* Add sushi piece to the sushi tower */
        sushiTower.append(newPiece)
    }
    
    func addRandomPiece(total: Int){
        
        for _ in 1 ... total {
            
            /* Need to access last piece properties */
            let lastPiece = sushiTower.last!
            
            /* Need to ensure we don't create impossible sushi structures */
            if lastPiece.side != .none {
                addPiece(side: .none)
            } else {
                
                /* Random Number Generator */
                let rand = arc4random_uniform(100)
                
                if rand < 45 {
                    /* 45% Chance of a left piece */
                    addPiece(side: .left)
                } else if rand < 90 {
                    /* 45% Chance of a right piece */
                    addPiece(side: .right)
                } else {
                    /* 10% Chance of an empty piece */
                    addPiece(side: .none)
                }
            }
        }
    }
    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    func gameOver() {
        /* Game over! */
        
        state = .gameOver
        score = 0
        
        /* Turn all the sushi pieces red*/
        for sushiPiece in sushiTower {
            sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        }
        
        /* Make the base turn red */
        sushiBase.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        
        /* Make the player turn red */
        cat.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        
        /* Change play button selection handler */
        playButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
    }
}
