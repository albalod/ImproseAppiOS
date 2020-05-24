//
//  SuggestDetailVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/21/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class SuggestDetailVC: UIViewController{
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var suggest : Suggestion?
    var suggestRef: DocumentReference!

    var suggestListener: ListenerRegistration!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        suggestListener = suggestRef.addSnapshotListener{(documentSnapshot, error) in
            if let error = error{
                print ("Error getting reference \(error)")
            }
            if documentSnapshot!.exists{
                self.suggest = Suggestion(documentSnapshot: documentSnapshot!)
                print (self.suggest?.content)
                
                self.updateView()
            }
            else{
                //ELSE
            }
        }
        
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        suggestListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateView(){
        contentLabel.text = suggest?.content
        
    }
    
}

