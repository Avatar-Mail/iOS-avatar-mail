//
//  ViewController.swift
//  IOSAvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        let testLabel = UILabel()
        testLabel.text = "Hello World"
        
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false

        testLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        testLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}


