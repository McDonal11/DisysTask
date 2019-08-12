//
//  ViewController.swift
//  task
//
//  Created by Gopal on 10/08/19.
//  Copyright © 2019 Gopal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var idCardImgVw: UIImageView!
    @IBOutlet weak var nameImgVw: UIImageView!
    @IBOutlet weak var bioPassportImgVw: UIImageView!
    @IBOutlet weak var emailImgVw: UIImageView!
    @IBOutlet weak var unifiedNumberImgVw: UIImageView!
    @IBOutlet weak var mobileImgVw: UIImageView!
    
    
    @IBOutlet weak var idNumber: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var passportNum: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var unifiedNumber: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    @IBOutlet var kbToolBarVw: UIView!
    
    let imageTintColor = UIColor(red: 255/255, green: 205/255, blue: 157/255, alpha: 1.0)
    
    var previousButton : UIBarButtonItem?
    var nextButton : UIBarButtonItem?
    var activeTxtFldTag : Int = 0
    
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        toolbar.tintColor = imageTintColor
        
        previousButton  = UIBarButtonItem(image: UIImage(named: "leftArrow"), style: .plain, target: self, action: #selector(LoginViewController.keyboardPreviousButton))
        nextButton  = UIBarButtonItem(image: UIImage(named: "rightArrow"), style: .plain, target: self, action: #selector(LoginViewController.keyboardNextButton))
        var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(LoginViewController.inputToolbarDonePressed))
        
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        
        nextButton!.width = 50.0
        
        
        toolbar.setItems([previousButton!, fixedSpaceButton, nextButton!, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    var KB_Height : CGFloat = 0
    var fldPoint : CGPoint?
    var screenHeight : CGFloat = 0
    var allTextFieldArr = [UITextField]()
    var fieldValuesArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateThisScreenUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        screenHeight = self.view.frame.height
    }

    //MARK:- PROCEED BUTTON ACTION
    @IBAction func proceedBtnAcn(_ sender: UIButton) {
        
        fieldValuesArr.removeAll()
        let emptyTxtFld = allTextFieldArr.filter { textFld in
            
            guard textFld.text == "" else {
                
                fieldValuesArr.append(textFld.text!)
                return false
            }
            
            return true
        }
        
        if emptyTxtFld.count > 0 {
            
            self.showOnlyAlert(message: "Enter all fields", title: "Error")
        }
        else {
            
            if fieldValuesArr[3].isValidEmail() {
                
                if Reachability().isConnectedToNetwork() {
                    
                    postApiCall()
                }
                else {
                    
                    self.showOnlyAlert(message: "Check Internet connection", title: "Alert")
                }
                
            }
            else {
                
                self.showOnlyAlert(message: "Enter valid Email Id", title: "Error")
            }
            
        }
    }
    
    //MARK:- API CALL
    func postApiCall() {
        
        actInd.isActivityIndicatorNeed(need: true)
        proceedBtn.isHidden = true
        self.view.isUserInteractionEnabled = false
        
        let params = [
            "eid" : fieldValuesArr[0],
            "name" : fieldValuesArr[1],
            "idbarahno" : fieldValuesArr[2],
            "emailaddress" : fieldValuesArr[3],
            "unifiednumber" : fieldValuesArr[4],
            "mobileno" : fieldValuesArr[5]
        ]
        
        let apiUrl = Singleton.shared.baseURL + "iskan/v1/certificates/towhomitmayconcern"
        
        Singleton.shared.apiCall(apiType: "POST", apiURL: apiUrl, parameters: params) { (result, error) in
            
            DispatchQueue.main.async {
                
                if let JSON = result {
                    
                    if let success = JSON["success"] as? Bool {
                        
                        if success {
                            
                            UserDefaults.standard.set(self.fieldValuesArr[1], forKey: "loggeduser")
                            self.performSegue(withIdentifier: "detail", sender: nil)
                        }
                        else {
                            
                            self.actInd.isActivityIndicatorNeed(need: false)
                            self.proceedBtn.isHidden = false
                            self.view.isUserInteractionEnabled = true
                            
                            self.showOnlyAlert(message: JSON["message"] as? String ?? "Login failed", title: "Alert")
                        }
                    }
                    else {
                        
                        self.showOnlyAlert(message: "Invalid format", title: "Alert")
                        self.actInd.isActivityIndicatorNeed(need: false)
                        self.proceedBtn.isHidden = false
                        self.view.isUserInteractionEnabled = true
                    }
                    
                } else if let error = error {
                    //print("Post_error:     \(error.localizedDescription)")
                    
                    self.showOnlyAlert(message: error.localizedDescription, title: "Error")
                    self.actInd.isActivityIndicatorNeed(need: false)
                    self.proceedBtn.isHidden = false
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
        
    }
    
    
    //MARK:- UITEXTFIELD DELEGATES
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        fldPoint = textField.convert(textField.center, to: self.view)
        
        moveScreenUp()
        
        activeTxtFldTag = textField.tag
        
        previousButton?.isEnabled = true
        nextButton?.isEnabled = true
        
        if activeTxtFldTag == 1 {
            previousButton?.isEnabled = false
        }
        if activeTxtFldTag == 6 {
            nextButton?.isEnabled = false
        }
    }
    
    //MARK:- SCREEN UP / DOWN
    @objc func keyboardWillShow(sender: NSNotification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            KB_Height = keyboardRectangle.height
        }
        
        moveScreenUp()
        
        print("keyboard_Will_Show    ", KB_Height)
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
        KB_Height = 0
        self.view.frame.origin.y = 0
        
    }
    
    @objc func keyboardNextButton() {
        
        previousNextTextField(status: "next")
    }
    
    @objc func keyboardPreviousButton() {

        previousNextTextField(status: "previous")
        
    }
    
    @objc func inputToolbarDonePressed() {
        
        self.view.endEditing(true)
    }

    func previousNextTextField(status: String) {
        
        if status == "next" {
            activeTxtFldTag = activeTxtFldTag + 1
        }
        else if status == "previous" {
            activeTxtFldTag = activeTxtFldTag - 1
        }
        
        let activeTxtFld = allTextFieldArr.filter { textFld in
            
            guard textFld.tag == activeTxtFldTag else {
                
                return false
            }
            return true
        }
        
        activeTxtFld[0].becomeFirstResponder()
    }
    
    func moveScreenUp() {
        
        if KB_Height != 0 {
            
            if ((screenHeight - (fldPoint?.y)!) <= KB_Height) {
                
                UIView.animate(withDuration: 0.4) {
                    
                    self.view.frame.origin.y = -(self.KB_Height + 30 - (self.screenHeight - (self.fldPoint?.y)!))
                }
            }
            else {
                
                UIView.animate(withDuration: 0.8) {
                    
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
    
    func updateThisScreenUI() {
        
        actInd.isActivityIndicatorNeed(need: false)
        
        allTextFieldArr.append(idNumber)
        allTextFieldArr.append(name)
        allTextFieldArr.append(passportNum)
        allTextFieldArr.append(email)
        allTextFieldArr.append(unifiedNumber)
        allTextFieldArr.append(phoneNumber)
        
        idCardImgVw.image = idCardImgVw.changeImageColor(color: imageTintColor)
        nameImgVw.image = nameImgVw.changeImageColor(color: imageTintColor)
        bioPassportImgVw.image = bioPassportImgVw.changeImageColor(color: imageTintColor)
        emailImgVw.image = emailImgVw.changeImageColor(color: imageTintColor)
        unifiedNumberImgVw.image = unifiedNumberImgVw.changeImageColor(color: imageTintColor)
        mobileImgVw.image = mobileImgVw.changeImageColor(color: imageTintColor)
        
        idNumber.inputAccessoryView = inputToolbar
        name.inputAccessoryView = inputToolbar
        passportNum.inputAccessoryView = inputToolbar
        email.inputAccessoryView = inputToolbar
        unifiedNumber.inputAccessoryView = inputToolbar
        phoneNumber.inputAccessoryView = inputToolbar
    }
}


extension UIImageView {
    func changeImageColor( color:UIColor) -> UIImage
    {
        image = image!.withRenderingMode(.alwaysTemplate)
        tintColor = color
        return image!
    }
}

extension UIViewController {
    
    func showOnlyAlert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension String {
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = self.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
}

extension UIActivityIndicatorView {
    
    func isActivityIndicatorNeed(need: Bool) {
        
        if need {
            
            self.isHidden = false
            self.startAnimating()
            
        }
        else {
            
            self.isHidden = true
            self.stopAnimating()
        }
        
    }
    
}


extension UIView {
    
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 1.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.3
        }, completion: completion)
    }
}
