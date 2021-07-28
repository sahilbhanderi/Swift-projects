//
//  HintViewController.swift
//  Pentominoes
//
//  Created by Sahil Bhanderi on 9/24/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {
    
    var hintView : UIImageView!
    var hintNumber : Int!
    var tag : Int!
    let model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(hintView)
        var frame : CGRect
        hintView.center = view.center
        if hintNumber > model.numberPieces() {
            hintNumber = model.numberPieces()
        }
        for i in 0..<hintNumber {
            let solutionPosition = model.getSolutionPosition(tag: tag, index: i)
            let pieceView = UIImageView(image: UIImage(named: model.pieceName(index: i)))
            if solutionPosition.rotations % 2 == 0{
                frame = CGRect(x: CGFloat(solutionPosition.x*30), y: CGFloat(solutionPosition.y*30), width: pieceView.frame.width, height: pieceView.frame.height)
            }
            else {
                frame = CGRect(x: CGFloat(solutionPosition.x*30), y: CGFloat(solutionPosition.y*30), width: pieceView.frame.height, height: pieceView.frame.width)
            }
            var transform = CGAffineTransform.identity.rotated(by: CGFloat.pi/2 * CGFloat(solutionPosition.rotations))
            if solutionPosition.isFlipped {
                transform = transform.scaledBy(x: -1.0, y: 1.0)
            }
            pieceView.transform = transform
            pieceView.frame = frame
            hintView.addSubview(pieceView)
        }
    }
    
    func configure(with boardImage:UIImage, tag:Int, hintNumber:Int) {
        hintView = UIImageView(image:boardImage)
        self.hintNumber = hintNumber
        self.tag = tag
    }
}
