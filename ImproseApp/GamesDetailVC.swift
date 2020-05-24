//
//  GamesDetailVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/21/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class GamesDetailVC: UIViewController{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    var game : Game?
    var gameRef: DocumentReference!

    var gameListener: ListenerRegistration!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gameListener = gameRef.addSnapshotListener{(documentSnapshot, error) in
            if let error = error{
                print ("Error getting reference \(error)")
            }
            if documentSnapshot!.exists{
                self.game = Game(documentSnapshot: documentSnapshot!)
            
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
        gameListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateView(){
        nameLabel.text = game?.name
        descLabel.text = game?.desc
    }
    
}

