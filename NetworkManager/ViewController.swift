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
        
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        NetworkManager(httpMethod: .post, fullUrlString: "https://itunes.apple.com/search?media=music&entity=song&term=fetish", params: nil).configure(showAlert: false, requestTimeOutInterval: 50).addHeaders(headers: ["abc":"abcd"]).completion { (result) in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let dict):
//                print(dict)
//                self.label1.text = "Received response"
//                
//            }
//        }
        
        
        
        picker.imageCallBack = { (filePath,error) in
            if let filePath = filePath, let image = UIImage(contentsOfFile: filePath), let data =  UIImageJPEGRepresentation(image, 0.1) {
                let file = MultipartFile(name: "profilePic", mimeType: "image/jpeg", data: data, fileName: "dp.jpg")
//                files?.append(HSFile(data: data as Data, name: "profilePic", fileName: "dp.jpg", mimeType: "image/jpg"))
            
            
            
            NetworkManager(httpMethod: .put, fullUrlString: "https://api-staging.praoshealth.com/api/v1/updateProfile", params: nil, files: [file]).completion(callback: { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let dict):
                    print(dict)
                }
            })
                }
        }
    }
}
