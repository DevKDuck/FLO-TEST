//
//  ViewController.swift
//  FLOTEST
//
//  Created by duck on 2023/11/20.
//

import UIKit

class ViewController: UIViewController {
    
    let repository = Repository()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        repository.fetchMusicDate{ [weak self]  ent in
            print(ent)
        }
    }


}

