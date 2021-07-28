//
//  ViewController.swift
//  Word Solver
//
//  Created by Sahil Bhanderi on 9/2/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var currentWordLabel: UILabel!
    @IBOutlet weak var scrambledLetterOutlet: UISegmentedControl!
    @IBOutlet weak var checkWordButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var newWordButton: UIButton!
    @IBOutlet weak var sizeOfWordPanel: UISegmentedControl!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var numberOfResultsLabel: UILabel!
    
    let wordModel = WordModel()
    var indexLetters = [Int]()
    var countCorrect = 0
    var countTotal = 0
    
    @IBAction func scrambledLetterUISegmentedControl(_ sender: Any) {
        appState(for: State.playing)
        let letter = scrambledLetterOutlet.titleForSegment(at: scrambledLetterOutlet.selectedSegmentIndex)
        indexLetters.append(scrambledLetterOutlet.selectedSegmentIndex)
        scrambledLetterOutlet.setEnabled(false, forSegmentAt: scrambledLetterOutlet.selectedSegmentIndex)
        if indexLetters.count == scrambledLetterOutlet.numberOfSegments {
            appState(for: State.done)
        }
        currentWordLabel.text = currentWordLabel.text! + letter!
    }
    
    @IBAction func undo(_ sender: Any) {
        appState(for: State.playing)
        let currentWord = currentWordLabel.text
        scrambledLetterOutlet.setEnabled(true, forSegmentAt: indexLetters.removeLast())
        if currentWord?.isEmpty == false {
            currentWordLabel.text = String(currentWord!.dropLast())
            if currentWordLabel.text!.isEmpty == true {
                appState(for: State.ready)
            }
        }
    }
    
    @IBAction func checkWord(_ sender: Any) {
        if wordModel.isDefined(currentWordLabel.text!) {
            resultLabel.text = wordModel.randomCorrectResponse
            countCorrect += 1
            countTotal += 1
        }
        else {
            resultLabel.text = wordModel.randomIncorrectResponse
            countTotal += 1
        }
        numberOfResultsLabel.text = "\(countCorrect) of \(countTotal) Correct"
        indexLetters.removeAll()
        appState(for: State.ready)
    }
    
    @IBAction func newWord(_ sender: Any) {
        appState(for: State.ready)
        currentWordLabel.text = ""
        resultLabel.text = ""
        numberOfResultsLabel.text = ""
        let randomWord = Array(wordModel.randomWord).shuffled()
        for index in 0..<randomWord.count
        {
            scrambledLetterOutlet.setTitle(String(randomWord[index]), forSegmentAt: index)
            scrambledLetterOutlet.setEnabled(true, forSegmentAt: index)
        }
    }
    
    @IBAction func numberOfLettersUISegmentedControl(numberOfLettersSegment: UISegmentedControl) {
        switch numberOfLettersSegment.selectedSegmentIndex
        {
        case 1:
            wordModel.setCurrentWordSize(newSize: 5)
            scrambledLetterOutlet.removeAllSegments()
            for _ in 0...4
            {
                scrambledLetterOutlet.insertSegment(withTitle: "", at: 0, animated: false)
            }
            newWord(self)
        case 2:
            wordModel.setCurrentWordSize(newSize: 6)
            scrambledLetterOutlet.removeAllSegments()
            for _ in 0...5
            {
                scrambledLetterOutlet.insertSegment(withTitle: "", at: 0, animated: false)
            }
            newWord(self)
        default:
            wordModel.setCurrentWordSize(newSize: 4)
            scrambledLetterOutlet.removeAllSegments()
            for _ in 0...3
            {
                scrambledLetterOutlet.insertSegment(withTitle: "", at: 0, animated: false)
            }
            newWord(self)
        }
    }
    
    enum State {
        case ready
        case playing
        case done
    }
    
    func appState(for state: State)
    {
        switch state {
        case State.ready:
            checkWordButton.isEnabled = false
            checkWordButton.alpha = 0.2
            undoButton.isEnabled = false
            undoButton.alpha = 0.2
            sizeOfWordPanel.isEnabled = true
            newWordButton.isEnabled = true
            newWordButton.alpha = 1
            resultLabel.isHidden = false
            numberOfResultsLabel.isHidden = false
        case State.playing:
            checkWordButton.isEnabled = false
            checkWordButton.alpha = 0.2
            undoButton.isEnabled = true
            undoButton.alpha = 1
            sizeOfWordPanel.isEnabled = false
            newWordButton.isEnabled = false
            newWordButton.alpha = 0.2
            resultLabel.isHidden = true
            numberOfResultsLabel.isHidden = true
        case State.done:
            checkWordButton.isEnabled = true
            checkWordButton.alpha = 1
            undoButton.isEnabled = true
            undoButton.alpha = 1
            sizeOfWordPanel.isEnabled = false
            newWordButton.isEnabled = false
            newWordButton.alpha = 0.2
            resultLabel.isHidden = false
            numberOfResultsLabel.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newWord(self)
        appState(for: State.ready)
    }

}

