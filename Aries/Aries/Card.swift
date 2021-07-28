//
//  Card.swift
//  Aries
//
//  Created by Sahil Bhanderi on 12/9/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//  Code based on https://medium.com/better-programming/building-a-memory-card-game-6513f34dd25c
//
import UIKit

class Card {
    var id: Int
    var shown: Bool = false
    var image: UIImage!
    
    static var allCards = [Card]()
    
    init(image: UIImage) {
        self.id = 0
        self.shown = false
        self.image = image
    }
    
    func equals(_ card: Card) -> Bool {
        return (card.image == image)
    }
    
    func duplicateCard() -> Card {
        return Card(card: self)
    }
    
    init(card: Card) {
        self.id = card.id
        self.shown = card.shown
        self.image = card.image
    }
    
    init(id: Int) {
        self.id = id
    }
}

extension Array {
    mutating func shuffleCards() {
        for _ in 0...self.count {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}
