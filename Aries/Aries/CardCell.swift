//
//  CardCell.swift
//  Aries
//
//  Created by Sahil Bhanderi on 12/9/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//  Code based on https://medium.com/better-programming/building-a-memory-card-game-6513f34dd25c
//

import UIKit

class CardCell: UICollectionViewCell {
    
    // MARK: - Properties

    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    var card: Card? {
        didSet {
            guard let card = card else { return }
            frontImageView.image = card.image
            
            frontImageView.layer.cornerRadius = 5.0
            backImageView.layer.cornerRadius = 5.0
            
            frontImageView.layer.masksToBounds = true
            backImageView.layer.masksToBounds = true
        }
    }
    
    var shown: Bool = false
    
    // MARK: - Methods
    
    func showCard(_ show: Bool, animated: Bool) {
        frontImageView.isHidden = false
        backImageView.isHidden = false
        shown = show
        frontImageView.image = card!.image

        if animated {
            if show {
                UIView.transition(
                    from: backImageView,
                    to: frontImageView,
                    duration: 0.5,
                    options: [.transitionFlipFromRight, .showHideTransitionViews],
                    completion: { (finished: Bool) -> () in
                })
            } else {
                UIView.transition(
                    from: frontImageView,
                    to: backImageView,
                    duration: 0.5,
                    options: [.transitionFlipFromRight, .showHideTransitionViews],
                    completion:  { (finished: Bool) -> () in
                })
            }
        } else {
            if show {
                bringSubviewToFront(frontImageView)
                backImageView.isHidden = true
            } else {
                bringSubviewToFront(backImageView)
                frontImageView.isHidden = true
            }
        }
    }
}
