//
//  ViewController.swift
//  NetworkManager
//
//  Created by Akhilesh on 21/08/17.
//  Copyright © 2017Akhilesh Gandotra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkManager(httpMethod: .post, fullUrlString: "https://itunes.apple.com/search?media=music&entity=song&term=fetish", params: nil).configure(showAlert: false, requestTimeOutInterval: 50).addHeaders(headers: ["abc":"abcd"]).completion { (result) in
             UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .failure(let error):
                print(error)
            case .success(let dict):
                print(dict)
            }
        }
    }
}
