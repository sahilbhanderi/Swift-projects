//
//  MainViewController.swift
//  Aries
//
//  Created by Sahil Bhanderi on 11/22/19.
//  Copyright © 2019 Sahil Bhanderi. All rights reserved.
//

import UIKit
import Network

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class MainViewController: UIViewController, MisfitsMenuViewControllerDelegate, MemoryMenuViewControllerDelegate {

    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status != .satisfied {
                self.alert(message: "No Internet Connection", title: "Network Connection Error")
            }
        }
        monitor.start(queue: queue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "misfitsMenuSegue":
            let misfitsMenuViewController = segue.destination as! MisfitsMenuViewController
            misfitsMenuViewController.delegate = self
        case "memoryMenuSegue":
            let memoryMenuViewController = segue.destination as! MemoryMenuViewController
            memoryMenuViewController.delegate = self
        default:
            break
        }
    }
    
    func backToMainMenu() {
        self.dismiss(animated: true, completion: nil)
    }
}
