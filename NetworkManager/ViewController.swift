//
//  ViewController.swift
//  NetworkManager
//
//  Created by Akhilesh on 21/08/17.
//  Copyright © 2017 Akhilesh Gandotra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var picker: ImagePickerButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // demo
        NetworkManager(httpMethod: .post, fullUrlString: "https://itunes.apple.com/search?media=music&entity=song&term=fetish", params: nil).configure(showAlert: true, requestTimeOutInterval: 50).addHeaders(headers: ["abc":"abcd"]).completion { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let dict):
                print(dict)
                self.label1.text = "Received response"
                
            }
        }
    }
}
