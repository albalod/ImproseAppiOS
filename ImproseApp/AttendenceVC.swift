//
//  AttendenceVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Toast_Swift
import Firebase

class AttendenceVC: UIViewController{
    
    var style = ToastStyle()
    
    var meetingRef : CollectionReference!
    var meetingListener: ListenerRegistration!
    var meeting : Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style.backgroundColor = .init(red: CGFloat(0.5), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(1))
        style.messageColor = .white
        
        navigationItem.title = "Attendence"
        
        meetingRef = Firestore.firestore().collection("Meetings")
        meeting = nil
        
    }
    
    
    @IBOutlet weak var meetingField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    
    @IBAction func pressedAddButton(_ sender: Any) {
        
        var message: String
        message = "Member added"
        
        var meetingName = meetingField!.text
        var memberName = nameField!.text
        
        var createdNew = false
        if(meetingName == ""){
            message = "Add a meeting name!"
            self.view.endEditing(true)
            self.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
        }
        else if(memberName == ""){
            message = "Add a name!"
            self.view.endEditing(true)
            self.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
        }
        else{
            meetingListener = meetingRef.whereField("name", isEqualTo: meetingName).addSnapshotListener { (querySnapshot, error) in
                if let querySnaphot = querySnapshot{
                    querySnapshot?.documents.forEach{
                        (documentSnapshot) in
                        self.meeting = Meeting(documentSnapshot:documentSnapshot)
                    }
                    if (self.meeting == nil){
                        self.meetingRef.addDocument(data: ["name": meetingName, "members": [memberName], "games":[String]()])
                        createdNew = true
                        message = "Created meeting and added member!"
                    }
                }else{
                    print("There was an error")
                    return
                }
            }
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                if(!createdNew){
                    if(self.meeting!.members.contains(memberName!)){
                        message = "This member has already been recorded!"
                    }
                    else{
                        self.meeting?.members.append(memberName!)
                        Firestore.firestore().collection("Meetings").document(self.meeting!.id).updateData(["members": self.meeting!.members])
                    }
                    
                }
                self.nameField.text = ""
                self.view.endEditing(true)
                self.view.makeToast(message, duration: 2.0, position: .bottom, style: self.style)
                return
            }
        }
    }
    
    
}

