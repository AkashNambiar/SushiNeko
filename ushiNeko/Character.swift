//
//  Character.swift
//  ushiNeko
//
//  Created by Akash Nambiar on 6/26/17.
//  Copyright © 2017 Akash Nambiar. All rights reserved.
//

import SpriteKit

class Character: SKSpriteNode {
    
    var side: Side = .left {
        didSet{
            if side == .left {
                xScale = 1
                position.x = 70
            } else {
                xScale = -1
                position.x = 252
            }
            
            /* Load/Run the punch action */
            let punch = SKAction(named: "Punch")!
            run(punch)
        }
    }
    
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
