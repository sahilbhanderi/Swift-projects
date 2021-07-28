//
//  ViewController.swift
//  Aries
//
//  Created by Sahil Bhanderi on 11/17/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit

protocol MisfitsGameViewControllerDelegate : NSObject {
    func backToMisfitsMenu()
}

class MisfitsGameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var model = AriesModel.sharedInstance
    weak var delegate : MisfitsGameViewControllerDelegate?
    var types = ["galaxy", "iss", "sun", "supernova"]
    var usedTypes = [String]()
    var randomType : String?
    var misfitType : String?
    var singleTap : UITapGestureRecognizer?
    var misfitTag : Int?
    var score : Int = 0
    var time : Int?
    var timer = Timer()
    var isTimerRunning = false
    var difficulty : Int?
    var randomList = [0,1,2,3]
    var count = -1

    @IBOutlet var celestialObjects: [UIImageView]!
    @IBOutlet weak var scoreOutlet: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch difficulty {
        case 0:
            time = 60
        case 1:
            time = 45
        default:
            time = 30
        }
        
        reloadGame()
        responseLabel.isHidden = true
        for aView in celestialObjects {
            aView.isHidden = true
        }
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(imageDataDownloaded(notification:)), name: Notification.Name.ImageDataDownloaded, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        usedTypes = []
        for aView in celestialObjects {
            aView.image = nil
        }
    }
    
    func reloading(){
        randomType = types.randomElement()
        while usedTypes.contains(randomType!) {
            randomType = types.randomElement()
        }
        usedTypes.append(randomType!)
        misfitType = types.randomElement()
        while usedTypes.contains(misfitType!) {
            misfitType = types.randomElement()
        }
        
        model.loadData(type: randomType!)
        for _ in 0..<3 {
            model.imageData(type: randomType!)
        }

        model.loadData(type: misfitType!)
        model.imageData(type: misfitType!)
        for aView in celestialObjects {
            let singleTapSelector = #selector(MisfitsGameViewController.selectMisfit(_:))
            singleTap = UITapGestureRecognizer(target: self, action: singleTapSelector)
            singleTap?.delegate = self
            aView.addGestureRecognizer(singleTap!)
            aView.isUserInteractionEnabled = true
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(MisfitsGameViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if time! < 1 {
            timer.invalidate()
            for aView in celestialObjects {
                aView.isUserInteractionEnabled = false
            }
            responseLabel.text = "Time's up!"
            responseLabel.isHidden = false
            scoreOutlet.text = "Score: "+String(score)
            startButton.isHidden = false
        }
        else {
            time! -= 1
            timerLabel.text = "\(time!)"
        }
    }
    
    func loadImages(_ imageNumber: Int, type: String, count :  Int){
        if let imageData = model.objectImageData(at: imageNumber, type: type),
            let image = UIImage(data: imageData) {
            let random = self.celestialObjects[randomList[count]]
            random.image = image
            if type == misfitType {
                misfitTag = random.tag
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.responseLabel.isHidden == false {
                for aView in self.celestialObjects {
                    aView.isHidden = false
                }
            }
        }
    }

    //MARK: - Observer Targets
    @objc func imageDataDownloaded(notification:Notification) {
        let userInfo = notification.userInfo!
        let imageNumber = userInfo["imageNumber"] as! Int
        let type = userInfo["type"] as! String
        if count == 3 {
            count = -1
        }
        let block = {
            self.count += 1
            if type == self.misfitType {
                self.loadImages(0, type: type, count : self.count)
            }
            else {
                self.loadImages(imageNumber, type: type, count : self.count)
            }
        }
        DispatchQueue.main.async(execute: block)
    }
    
    func reloadGame() {
        usedTypes = []
        for aView in celestialObjects {
            aView.image = nil
            aView.isHidden = false
        }
        reloading()
        randomList.shuffle()
        count = -1
    }
    
    @IBAction func onStartGame(_ sender: Any) {
        for aView in celestialObjects {
            aView.isHidden = false
        }
        startButton.isHidden = true
        if time == 0 {
            reloadGame()
            switch difficulty {
            case 0:
                time = 60
            case 1:
                time = 45
            default:
                time = 30
            }
            timerLabel.text = "\(time!)"
            responseLabel.isHidden = true
        }
        runTimer()
    }
    
    @objc func selectMisfit(_ sender: UITapGestureRecognizer) {
        let selectedCelestialObject = sender.view
        responseLabel.isHidden = false
        if selectedCelestialObject?.tag == misfitTag {
            score = score + 1
            scoreOutlet.text = "Score: "+String(score)
            responseLabel.text = "Correct!"
            reloadGame()
        }
        else {
            responseLabel.text = "Try Again!"
        }
        count = -1
    }
}
