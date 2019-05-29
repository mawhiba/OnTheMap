//
//  LoginVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController {
  
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    
    @IBOutlet var loginButton: UIButton!
    
    
    @IBAction func login(_ sender: Any){
                updateUI(processing: true)
                guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty, !password.isEmpty
                else {
                    alert(title: "Warning", message: "Email and password shouldn't be empty.")
                    updateUI(processing: false)
                    return
                }
        
                UdacityAPI.postSession(with: email, password: password)  { (result, error) in
                    if let error = error {
                        self.alert(title: "Error", message: error.localizedDescription)
                        self.updateUI(processing: false)
                        return
                    }
                    if let error = result?["error"] as? String {
                        self.alert(title: "Error", message: error)
                        self.updateUI(processing: false)
                        return
                    }
                    if let session = result?["session"] as? [String:Any], let sessionId = session["id"] as? String {
                        print(sessionId)
                        UdacityAPI.deleteSession{ (error) in
                            if let error = error {
                                self.alert(title: "Error", message: error.localizedDescription)
                                self.updateUI(processing: false)
                                return
                            }
                            self.updateUI(processing: false)
                            DispatchQueue.main.async {
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                                self.performSegue(withIdentifier: "tbViewController", sender: self)
                            }
                        }
                    }
                    self.updateUI(processing: false)
                }
            }
    
    func updateUI(processing: Bool){
        DispatchQueue.main.async {
            self.emailTextField.isUserInteractionEnabled = !processing
            self.passwordTextField.isUserInteractionEnabled = !processing
            self.loginButton.isEnabled = !processing
            
        }
    }
}


