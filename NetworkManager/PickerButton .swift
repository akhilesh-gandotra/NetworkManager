//
//  PickerButton.swift
//  CLApp
//
//  Created by Akhilesh Gandotra on 17/01/17.
//  Copyright © 2017 Akhilesh Gandotra All rights reserved.
//

import UIKit

enum PickerType {
    case camera
    case photoLibrary
    case both
}

enum SelectImageError: LocalizedError {
    case cameraNotFound
    case photoLibrary
    case pickerCancelled
    
    var errorDescription: String? {
        switch self {
        case .cameraNotFound:
            return "Camera not found in this device."
        case .photoLibrary:
            return "Photo library found in this device."
        case .pickerCancelled:
            return "Image picker cancelled"
        }
    }
}

class ImagePickerButton: UIButton, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK Variables
    var imageCallBack: ((_ filepath: String?, _ error: String?) -> Void)?
    var pickerType: PickerType? = .both
    var filePath: String?
    var error: SelectImageError?
    var fileName: String? = "#newFile"
    var picker: UIImagePickerController?
    var titles = [String]()
    var imageCallBack1: ((_ filepath: String?, _ error: String?) -> Void)?
    
    //MARK: Starting
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(ImagePickerButton.pressAction(_:)), for: UIControlEvents.touchUpInside)
    }
    
    deinit {
      //  self.removeImage()
    }
    
    //MARK: Customizables results for selecting file name and picker type
    @discardableResult
    func customize(type: PickerType, fileName: String?) -> ImagePickerButton {
        pickerType = type
        self.fileName = fileName
        return self
    }
    
    @discardableResult
    func titles(names: [String]) -> ImagePickerButton {
        
        return self
    }
    
    
    //MARK: Button Action
    func pressAction(_ sender: ImagePickerButton) {
        self.selectImage(fileName: fileName!, pickerType: self.pickerType!, callback: {[weak self](filePath, error) in
            if self!.imageCallBack != nil {
                if let _ = filePath {
                    self!.imageCallBack!(filePath, error)
                } else {
                    print(error ?? "nothing") // show Alert
                }
            }
        })
    }
  
    //MARK: Document Directory Path
    func pathToDocumentsDirectory() -> String {
        
        let documentsPath: AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as AnyObject
        if let path = documentsPath as? String {
            return path
        }
        fatalError("could not return path")
    }
    
    func removeImage() {
        let fileManager = FileManager.default
        let path = pathToDocumentsDirectory()
        if let _ = self.filePath {
            let filePath = "\(path)/\(fileName!)"
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            self.filePath = nil
        }
    }
    
    
    //MARK: Functions for selecting image from picker
    func selectImage( fileName: String, pickerType: PickerType, callback: @escaping (_ filepath: String?, _ error: String?) -> Void) {
        filePath = pathToDocumentsDirectory().appending("/\(fileName)")
        imageCallBack1 = callback
        self.openImagePicker(pickertype: pickerType)
    }
    
    
    func openImagePicker(pickertype: PickerType) {
        
              let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

        switch pickertype {
        case .camera:
           self.openCamera(actionSheet: actionSheet)
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
           })
           actionSheet.addAction(cancelAction)
           (UIApplication.shared.keyWindow?.rootViewController)!.present(actionSheet, animated: true, completion: nil)
        case .photoLibrary:
            self.openPhotoLibrary(actionSheet:actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {  (alert: UIAlertAction!) -> Void in
            })
             actionSheet.addAction(cancelAction)
              (UIApplication.shared.keyWindow?.rootViewController)!.present(actionSheet, animated: true, completion: nil)
            
        default:
            openCamera(actionSheet: actionSheet)
            openPhotoLibrary(actionSheet: actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {  (alert: UIAlertAction!) -> Void in
            })
            actionSheet.addAction(cancelAction)
            (UIApplication.shared.keyWindow?.rootViewController)!.present(actionSheet, animated: true, completion: nil)
            break
        }
    }
    
    func openCamera(actionSheet: UIAlertController) {
        
        picker = UIImagePickerController()
        self.picker?.delegate = self

        let cameraAction = UIAlertAction(title: "Take a new photo", style: .default, handler: {  (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                self.picker?.sourceType = UIImagePickerControllerSourceType.camera
                (UIApplication.shared.keyWindow?.rootViewController)!.present(self.picker!, animated: true, completion: nil)
            } else {
                self.error = .cameraNotFound
                self.imageCallBack1!(nil, self.error?.errorDescription)
            }
        })
        actionSheet.addAction(cameraAction)
  }
    
    func openPhotoLibrary(actionSheet: UIAlertController) {
        picker = UIImagePickerController()
        self.picker?.delegate = self
        let photoLibraryAction = UIAlertAction(title: "Choose from existing", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.picker?.sourceType = UIImagePickerControllerSourceType.photoLibrary
                (UIApplication.shared.keyWindow?.rootViewController)!.present(self.picker!, animated: true, completion: nil)
            } else {
                self.error = .photoLibrary
                self.imageCallBack1!(nil, self.error?.errorDescription)
            }
        })
        actionSheet.addAction(photoLibraryAction)
    }
    
    //MARK: Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if UIImageJPEGRepresentation(pickedImage, 1.0)!.count > 2*1024 {
                if let data = UIImageJPEGRepresentation(pickedImage, 0.2) {
                    do {
                        try data.write(to: URL(fileURLWithPath: filePath!), options: .atomic)
                    } catch {
                        print(error)
                    }
                }
            } else {
                if let data = UIImageJPEGRepresentation(pickedImage, 0.4) {
                    do {
                        try data.write(to: URL(fileURLWithPath: filePath!), options: .atomic)
                    } catch {
                        print(error)
                    }
                }
            }
        }
       imageCallBack!(filePath, error?.errorDescription)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageCallBack1!(nil, SelectImageError.pickerCancelled.errorDescription)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
