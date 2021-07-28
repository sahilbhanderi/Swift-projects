//
//  MemoryGameViewController.swift
//  Aries
//
//  Created by Sahil Bhanderi on 12/8/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit

protocol MemoryGameViewControllerDelegate : NSObject {
    func backToMemoryMenu()
}

class MemoryGameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var model = AriesModel.sharedInstance
    weak var delegate : MemoryGameViewControllerDelegate?
    var types = ["galaxy", "iss", "sun", "supernova"]
    var randomType : String?
    var singleTap : UITapGestureRecognizer?
    var score : Int = 0
    var time = 60
    var timer = Timer()
    var isTimerRunning = false
    var last : UIView?
    let game = MemoryGame()
    var cards = [Card]()
    var difficulty : Int?
    var numCards : Int?
    var randomList : [Int] = []
    var count = 0
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(imageDataDownloaded(notification:)), name: Notification.Name.ImageDataDownloaded, object: nil)
        setupNewGame()
        responseLabel.isHidden = true
    }
    
    func setupNewGame() {
        reloading()
        randomList.shuffle()
        cards = game.newGame(cardsArray: self.cards)
        collectionView.reloadData()
    }
    
    func reloading() {
        switch difficulty {
            case 0:
                numCards = 8
            case 1:
                numCards = 16
            default:
                numCards = 20
        }
        for i in 0..<numCards! {
            let card = Card(id: i)
            cards.append(card)
            randomList.append(i)
        }
        for _ in 0..<numCards! / 2 {
            randomType = types.randomElement()
            model.loadData(type: randomType!)
            model.imageData(type: randomType!)
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(MemoryGameViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if time < 1 {
            timer.invalidate()
            responseLabel.isHidden = false
            collectionView.isUserInteractionEnabled = false
            responseLabel.text = "Time's up!"
            scoreLabel.text = "Score: "+String(score)
            startButton.isHidden = false
        }
        else {
            time -= 1
            timerLabel.text = "\(time)"
        }
    }
    
    func loadImages(_ imageNumber: Int, type: String, count :  Int) {
        var thisCount = count
        if let imageData = model.objectImageData(at: imageNumber, type: type),
            let image = UIImage(data: imageData) {
            for _ in 0..<2 {
                let random = self.cards[randomList[thisCount]]
                random.image = image
                if thisCount != numCards!-1 {
                    self.count += 1
                    thisCount += 1
                }
            }
        }
    }
    
    //MARK: - Observer Targets
    @objc func imageDataDownloaded(notification:Notification) {
        let userInfo = notification.userInfo!
        let imageNumber = userInfo["imageNumber"] as! Int
        let type = userInfo["type"] as! String
        if count == numCards!-1 {
            count = 0
        }
        let block = {
            self.loadImages(imageNumber, type: type, count: self.count)
        }
        DispatchQueue.main.async(execute: block)
    }
    
    func resetGame() {
        count = 0
        randomList = []
        game.restartGame()
        cards.removeAll()
        setupNewGame()
        time = 60
        timerLabel.text = "\(time)"
        responseLabel.isHidden = true
        score = 0
        scoreLabel.text = "Score: "+String(score)
        collectionView.isUserInteractionEnabled = true
    }
    
    @IBAction func onStartGame(_ sender: Any) {
        startButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.collectionView.isHidden = false
        }

        if time == 0 {
            resetGame()
        }
        runTimer()
    }
}

// MARK: - CollectionView Delegate Methods
extension MemoryGameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        
        guard let card = game.cardAtIndex(indexPath.item) else { return cell }
        cell.card = card
        cell.showCard(false, animated: false)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell
        
        if cell.shown { return }
        game.didSelectCard(cell.card)
        
        collectionView.deselectItem(at: indexPath, animated:true)
    }
}

extension MemoryGameViewController: MemoryGameProtocol {
    func memoryGameDidStart(_ game: MemoryGame) {
        collectionView.reloadData()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(imageDataDownloaded(notification:)), name: Notification.Name.ImageDataDownloaded, object: nil)
        
    }
    
    func memoryGame(_ game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            guard let index = game.indexForCard(card)
                else { continue
            }
            
            let cell = collectionView.cellForItem(
                at: IndexPath(item: index, section:0)
                ) as! CardCell
            cell.showCard(true, animated: true)
        }
    }
    
    func memoryGame(_ game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            guard let index = game.indexForCard(card)
                else { continue
            }
            
            let cell = collectionView.cellForItem(
                at: IndexPath(item: index, section:0)
                ) as! CardCell
            
            cell.showCard(false, animated: true)
        }
    }
    
    func memoryGameDidEnd(_ game: MemoryGame) {
        responseLabel.isHidden = false
        startButton.isHidden = false
        score = 60 - time
        scoreLabel.text = "Score: "+String(score)
        timer.invalidate()
        time = 0
        timerLabel.text = "\(time)"
        responseLabel.text = "Good job!"
        count = 0
    }
}
