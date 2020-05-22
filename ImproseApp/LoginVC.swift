//  LoginVC.swift
//  ImproseSpp
//
//  Created by CSSE Department on 5/18/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Rosefire

class LoginVC: UIViewController{


       let segueID = "ShowHomeScreen"

       let REGISTRY_TOKEN = "15d691d3-dd8f-43ed-b2b6-304129cbc802"
        
       override func viewDidLoad() {
           super.viewDidLoad()
          
       }

       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           if (Auth.auth().currentUser != nil){
           self.performSegue(withIdentifier:self.segueID, sender: self)
           }

       }

       @IBAction func pressedRosefire(_ sender: Any) {
           Rosefire.sharedDelegate().uiDelegate = self // This should be your view controller
           Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
             if let err = err {
               print("Rosefire sign in error! \(err)")
               return
             }
           //  print("Result = \(result!.token!)")
             print("Result = \(result!.username!)")
             print("Result = \(result!.name!)")
             print("Result = \(result!.email!)")
             print("Result = \(result!.group!)")

             Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
               if let error = error {
                 print("Firebase sign in error! \(error)")
                 return
               }
               // User is signed in using Firebase!
                self.performSegue(withIdentifier:self.segueID, sender: self)
             }
           }

       }
}


