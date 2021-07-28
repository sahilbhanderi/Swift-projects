//
//  MemoryMenuViewController.swift
//  Aries
//
//  Created by Sahil Bhanderi on 11/23/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit

protocol MemoryMenuViewControllerDelegate : NSObject {
    func backToMainMenu()
}

class MemoryMenuViewController: UIViewController, MemoryGameViewControllerDelegate {

    weak var delegate : MemoryMenuViewControllerDelegate?
    var difficulty : Int = 0

    @IBOutlet weak var difficultyLevel: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch difficultyLevel.selectedSegmentIndex
        {
            case 0:
                difficulty = 0
            case 1:
                difficulty = 1
            default:
                difficulty = 2
        }
    }
    
    //MARK: - Segues
    @IBAction func dismissByUnwinding(_ segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "memoryGameSegue":
            let navController = segue.destination as! UINavigationController
            let memoryGameViewController = navController.topViewController as! MemoryGameViewController
            memoryGameViewController.delegate = self
            memoryGameViewController.difficulty = difficulty
        default:
            break
        }
    }

    @IBAction func backToMainMenu(_ sender: Any) {
        delegate?.backToMainMenu()
    }
    
    func backToMemoryMenu() {
        self.dismiss(animated: true, completion: nil)
    }

}
