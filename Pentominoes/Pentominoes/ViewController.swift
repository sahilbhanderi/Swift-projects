//
//  ViewController.swift
//  Pentominoes
//
//  Created by Sahil Bhanderi on 9/15/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//  Based on SampleCode2019 © 2019 John Hannan
//

import UIKit

struct PieceView {
    var pieceView : UIImageView
    var pieceImage : UIImage?
    var oldLocation : CGRect
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var boardOutlet: UIImageView!
    @IBOutlet var boardButtons: [UIButton]!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    
    let model = Model()
    
    let numberOfRows = 2
    let numberOfPieces : Int
    var selectedBoardTag = 0
    
    var pieceViews : [PieceView]
    
    // Constants for animations
    let kAnimationInterval  = 1.0
    let kMoveScaleFactor : CGFloat = 1.2
    let kEatScaleFactor : CGFloat = 1.25
    
    var mainPan : UIPanGestureRecognizer?
    var singleTap : UITapGestureRecognizer?
    var doubleTap : UITapGestureRecognizer?
    var originalLocations: [UIView : CGRect] = [:]
    var numHints : Int = 0

    //MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        numberOfPieces = model.numberPieces()

        var _pieceViews : [PieceView] = []
        // create the piece views
        for i in 0..<numberOfPieces {
            let pieceName = model.pieceName(index: i)
            let pieceImage = UIImage(named: pieceName)
            let pieceView = UIImageView(image: pieceImage)
            let oldLocation = pieceView.frame
            _pieceViews.append(PieceView(pieceView: pieceView, pieceImage: pieceImage!, oldLocation: oldLocation))
        }
        pieceViews = _pieceViews
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for aView in pieceViews {
            let selector = #selector(ViewController.movePentominoe(_:))
            mainPan = UIPanGestureRecognizer(target: self, action: selector)
            mainPan?.delegate = self
            let singleTapSelector = #selector(ViewController.rotatePentominoe(_:))
            singleTap = UITapGestureRecognizer(target: self, action: singleTapSelector)
            singleTap?.delegate = self
            let doubleTapSelector = #selector(ViewController.flipPentominoe(_:))
            doubleTap = UITapGestureRecognizer(target: self, action: doubleTapSelector)
            doubleTap!.numberOfTapsRequired = 2
            doubleTap?.delegate = self
            mainView.addSubview(aView.pieceView)
            aView.pieceView.isUserInteractionEnabled = true
            aView.pieceView.addGestureRecognizer(mainPan!)
            aView.pieceView.addGestureRecognizer(singleTap!)
            aView.pieceView.addGestureRecognizer(doubleTap!)
            singleTap?.require(toFail: doubleTap!)
            mainView.bringSubviewToFront(aView.pieceView)
        }
        resetButton.isEnabled = false
        solveButton.isEnabled = false
        hintButton.isEnabled = false
        
        boardOutlet.isUserInteractionEnabled = true
        super.view.isUserInteractionEnabled = true
    }

    //MARK: - Size Changes
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // width & height for each color view
        let height = mainView.bounds.size.height / CGFloat(numberOfPieces/2)
        let width = mainView.bounds.size.width / CGFloat(numberOfPieces/2)
        
        // re-position all the color views
        for i in 0..<numberOfPieces {
            let aView = pieceViews[i]
            
            let x =  CGFloat(i % numberOfPieces/2) * width + 30
            let y : CGFloat
            if i % 2 == 0{
                y = CGFloat(i / numberOfPieces/2) * height + 50
            }
            else {
                y = CGFloat(i / numberOfPieces/2) * height + 250
            }
            let frame = CGRect(x: x, y: y, width: pieceViews[i].pieceView.frame.width, height: pieceViews[i].pieceView.frame.height)
            aView.pieceView.frame = frame
            pieceViews[i].oldLocation = aView.pieceView.frame
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            let height = size.height / CGFloat(numberOfPieces/2)
            let width = size.width / CGFloat(numberOfPieces)
            // re-position all the color views
            for i in 0..<numberOfPieces {
                let aView = pieceViews[i]
                if(mainView.contains(aView.pieceView)) {
                    let x = CGFloat(i % numberOfPieces) * width
                    let y = height / 2 - 30
                    let frame = CGRect(x: x, y: y, width: pieceViews[i].pieceView.frame.width, height: pieceViews[i].pieceView.frame.height)
                    aView.pieceView.frame = frame
                    pieceViews[i].oldLocation = aView.pieceView.frame
                }
            }
        }
        else {
                // width & height for each color view
                let height = size.height / CGFloat(numberOfPieces/2)
                let width = size.width / CGFloat(numberOfPieces/2)
                // re-position all the color views
                for i in 0..<numberOfPieces {
                    let aView = pieceViews[i]
                    if(mainView.contains(aView.pieceView)) {

                        let x =  CGFloat(i % numberOfPieces/2) * width + 30
                        let y : CGFloat
                        if i % 2 == 0{
                            y = CGFloat(i / numberOfPieces/2) * height + 50
                        }
                        else {
                            y = CGFloat(i / numberOfPieces/2) * height + 250
                        }
                        let frame = CGRect(x: x, y: y, width: pieceViews[i].pieceView.frame.width, height: pieceViews[i].pieceView.frame.height)
                        aView.pieceView.frame = frame
                        pieceViews[i].oldLocation = aView.pieceView.frame
                    }
                }
            }
    }
    
    //MARK: Action Methods

    @IBAction func changeBoard(_ sender: Any) {
        numHints = 0
        selectedBoardTag = (sender as AnyObject).tag
        boardOutlet.image = UIImage(named: model.boardName(tag: selectedBoardTag))
        if selectedBoardTag != 0 {
            solveButton.isEnabled = true
            resetButton.isEnabled = false
            hintButton.isHidden = false
            hintButton.isEnabled = true
        }
        else {
            solveButton.isEnabled = false
            resetButton.isEnabled = false
            hintButton.isEnabled = false
        }
        for pentominoe in boardOutlet.subviews {
            pentominoe.transform = CGAffineTransform.identity
            let oldFrame = originalLocations[pentominoe]
            pentominoe.frame = oldFrame!
            mainView.addSubview(pentominoe)
        }
    }
    
    func boardSolution(tag t: Int) {
        var frame : CGRect
        hintButton.isHidden = true
        for i in 0..<numberOfPieces {
            let solutionPosition = model.getSolutionPosition(tag: t, index: i)
            if solutionPosition.rotations % 2 == 0{
                frame = CGRect(x: CGFloat(solutionPosition.x*30), y: CGFloat(solutionPosition.y*30), width: pieceViews[i].pieceView.frame.width, height: pieceViews[i].pieceView.frame.height)
            }
            else {
                frame = CGRect(x: CGFloat(solutionPosition.x*30), y: CGFloat(solutionPosition.y*30), width: pieceViews[i].pieceView.frame.height, height: pieceViews[i].pieceView.frame.width)
            }
            var transform = CGAffineTransform.identity.rotated(by: CGFloat.pi/2 * CGFloat(solutionPosition.rotations))
            if solutionPosition.isFlipped {
                transform = transform.scaledBy(x: -1.0, y: 1.0)
            }
            let newFrame = boardOutlet.convert(frame, to: mainView)
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: { self.pieceViews[i].pieceView.transform = transform
                self.pieceViews[i].pieceView.frame = newFrame
            }, completion: nil)
        }
    }
    
    @IBAction func solveBoard(_ sender: UIButton) {
        for pentominoe in boardOutlet.subviews {
            pentominoe.transform = CGAffineTransform.identity
            let oldFrame = originalLocations[pentominoe]
            pentominoe.frame = oldFrame!
            mainView.addSubview(pentominoe)
        }
        if selectedBoardTag != 0 {
            boardSolution(tag: selectedBoardTag)
            for i in 0..<boardButtons.count {
                boardButtons[i].isEnabled = false
                solveButton.isEnabled = false
                resetButton.isEnabled = true
            }
        }
    }
    
    @IBAction func resetBoard(_ sender: Any) {
        if selectedBoardTag != 0 {
            numHints = 0
            solveButton.isEnabled = true
            resetButton.isEnabled = false
            for i in 0..<numberOfPieces {
                for i in 0..<boardButtons.count {
                    boardButtons[i].isEnabled = true
                }
                let animation = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: CGFloat.pi)
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: { self.pieceViews[i].pieceView.transform = animation}, completion: nil)
                pieceViews[i].pieceView.removeFromSuperview()
                pieceViews[i].pieceView.transform = CGAffineTransform.identity
                pieceViews[i].pieceView.frame = pieceViews[i].oldLocation
                mainView.addSubview(pieceViews[i].pieceView)
                hintButton.isHidden = true
            }
            for pentominoe in boardOutlet.subviews {
                pentominoe.transform = CGAffineTransform.identity
                let oldFrame = originalLocations[pentominoe]
                pentominoe.frame = oldFrame!
                mainView.addSubview(pentominoe)
            }
        }
        hintButton.isHidden = false
    }
    
    @IBAction func giveHint(_ sender: Any) {
        numHints += 1
        performSegue(withIdentifier: "HintSegue", sender: sender)
    }
    
    //MARK: - Gesture Handlers
    
    @objc func movePentominoe(_ sender: UIPanGestureRecognizer) {
        resetButton.isEnabled = true
        let pentominoe = sender.view!
        let location = sender.location(in: self.view)
        var transform : CGAffineTransform
        
        switch sender.state {
        case .began:
            if mainView.frame.contains(location) {
                originalLocations[pentominoe] = pentominoe.frame
            }
            self.view.bringSubviewToFront(pentominoe)
            self.view.addSubview(pentominoe)
            let frame = CGRect(origin: location, size: pentominoe.frame.size)
            pentominoe.frame = frame
            transform = pentominoe.transform.scaledBy(x: kMoveScaleFactor, y: kMoveScaleFactor)
            pentominoe.transform = transform

        case .changed:
              pentominoe.center = location
            
        case .ended:
            if !boardOutlet.frame.contains(location) {
                let oldFrame = self.originalLocations[pentominoe]
                UIView.animate(withDuration: 0.6,
                    animations: {
                        pentominoe.transform = CGAffineTransform.identity
                        let frame = self.mainView.convert(oldFrame!, to: self.view)
                        pentominoe.frame = frame
                        
                }, completion: {_ in self.mainView.addSubview(pentominoe)
                    pentominoe.frame = oldFrame!
                })
            }
            else {
                UIView.animate(withDuration: 0.6,
                    animations: {
                        pentominoe.transform = pentominoe.transform.scaledBy(x: 1/self.kMoveScaleFactor, y: 1/self.kMoveScaleFactor)
                    })
                let frame = pentominoe.convert(pentominoe.bounds, to: boardOutlet)
                pentominoe.frame = frame
                boardOutlet.addSubview(pentominoe)
            }
        default:
            break
        }
    }
    
    @objc func rotatePentominoe(_ sender: UITapGestureRecognizer) {
        let pentominoe = sender.view!
        if boardOutlet.subviews.contains(pentominoe) {
            let xScale = pentominoe.transform.a
            let yScale = pentominoe.transform.d
            UIView.animate(withDuration: 0.6, delay: 0,
                animations: {
                    if ((xScale<0 && yScale>0) || (xScale>0 && yScale<0)) {
                        pentominoe.transform = pentominoe.transform.scaledBy(x: self.kMoveScaleFactor, y: self.kMoveScaleFactor).rotated(by: -CGFloat.pi/2)
                    }
                    else {
                        pentominoe.transform = pentominoe.transform.scaledBy(x: self.kMoveScaleFactor, y: self.kMoveScaleFactor).rotated(by: CGFloat.pi/2)
                    }
                },
                completion: { _ in
                    pentominoe.transform = pentominoe.transform.scaledBy(x: 1/self.kMoveScaleFactor, y: 1/self.kMoveScaleFactor)
                })
            boardOutlet.addSubview(pentominoe)

            }
    }
    
    @objc func flipPentominoe(_ sender: UITapGestureRecognizer) {
        let pentominoe = sender.view!
        if boardOutlet.subviews.contains(pentominoe) {
            UIView.animate(withDuration: 0.6,
                           animations: {
                            pentominoe.transform = pentominoe.transform.scaledBy(x: self.kMoveScaleFactor, y: self.kMoveScaleFactor).scaledBy(x: -1, y:1)
            },
                           completion: { _ in
                            pentominoe.transform = pentominoe.transform.scaledBy(x: 1/self.kMoveScaleFactor, y: 1/self.kMoveScaleFactor)
            })
        }
    }
    
    //MARK: - Segues
    @IBAction func dismissByUnwinding(_ segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "HintSegue":
            let hintViewController = segue.destination as! HintViewController
            hintViewController.configure(with: UIImage(named: model.boardName(tag: selectedBoardTag))!, tag: selectedBoardTag, hintNumber: numHints)
        default:
            break
        }
        
    }
}
