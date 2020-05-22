//
//  EventDetailVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/21/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EventDetailVC: UIViewController{
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    
    var event : Event?
    var eventRef: DocumentReference!
    
    var eventListener: ListenerRegistration!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        eventListener = eventRef.addSnapshotListener{(documentSnapshot, error) in
            if let error = error{
                print ("Error getting reference \(error)")
            }
            if documentSnapshot!.exists{
                self.event = Event(documentSnapshot: documentSnapshot!)
                print (self.event?.name)
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(self.showEditDialog))
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
        eventListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func showEditDialog(){
        
        let alertController = UIAlertController(title: "Edit event details", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Event Name"
            textField.text = self.event?.name
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Event Description"
            textField.text = self.event?.desc
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            let descTextField = alertController.textFields![1] as UITextField
            
            self.eventRef.updateData(["name": nameTextField.text!, "desc": descTextField.text!, "createdBy": Auth.auth().currentUser!.uid])
        }
        
        alertController.addAction(submitAction)
        
        present(alertController,animated: true, completion: nil)
    }
    
    func updateView(){
        nameLabel.text = event?.name
        descLabel.text = event?.desc
        authorLabel.text = event?.createdBy
        
    }
    
}
