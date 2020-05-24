//
//  MeetingC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class MeetingVC: UITableViewController{
    
    var meetings = [Meeting]()
    let cellID = "MeetingCell"
    var meetingRef: CollectionReference!
    
    let detailSegueID = "DetailSegueMeeting"
    
    var eventListener: ListenerRegistration!
    var isDeleting = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }
    
    func startListening(){
        
        eventListener = meetingRef.addSnapshotListener { (querySnapshot, error) in
            if let querySnaphot = querySnapshot{
                self.meetings.removeAll()
                querySnapshot?.documents.forEach{
                    (documentSnapshot) in
                    self.meetings.append(Meeting(documentSnapshot: documentSnapshot))
                }
                self.tableView.reloadData()
            }else{
                print("There was an error")
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Meeting Records"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
        
        meetingRef = Firestore.firestore().collection("Meetings")
    }
    
    @objc func showChange(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let deleteAction = UIAlertAction(title: self.isDeleting ? "Stop deleting" : "Delete meetings", style: .default) { (action ) in
            self.isDeleting = !self.isDeleting
            self.tableView.setEditing(self.isDeleting, animated: true)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == detailSegueID){
            if let indexPath = tableView.indexPathForSelectedRow{
                (segue.destination as! MeetingDetailVC).meetingRef = meetingRef.document(meetings[indexPath.row].id)
                (segue.destination as! MeetingDetailVC).meeting = meetings[indexPath.row]
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return meetings.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
           cell.textLabel?.text = meetings[indexPath.row].name
           return cell;
       }
       
       
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if(editingStyle == .delete){
               let meetingToDelete = meetings[indexPath.row]
               meetingRef.document(meetingToDelete.id).delete()
           }
       }
}
