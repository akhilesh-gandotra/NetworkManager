//
//  ViewController.swift
//  NetworkManager
//
//  Created by Akhilesh on 21/08/17.
//  Copyright © 2017Akhilesh Gandotra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var picker: ImagePickerButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        NetworkManager(httpMethod: .post, fullUrlString: "https://itunes.apple.com/search?media=music&entity=song&term=fetish", params: nil).configure(showAlert: false, requestTimeOutInterval: 50).addHeaders(headers: ["abc":"abcd"]).completion { (result) in
//             UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let dict):
//                print(dict)
//            }
        
        
        picker.imageCallBack = { (filepath,error) in
            
             if let data =  UIImageJPEGRepresentation(UIImage(contentsOfFile: filepath!)!, 0.1) {
                let file = MultipartFile(name: "profilePic", mimeType: "image/jpg", data: data as Data, fileName: "dp.jpg")
                
                
                NetworkManager(httpMethod: .put, fullUrlString: "https://api-staging.praoshealth.com/v1/updateProfile", params: nil, files: [file]).completion(callback: { (result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let dict) :
                        print(dict)
                    }
                })
            }
    }
   
        
    
    }
}
