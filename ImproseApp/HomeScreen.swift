//
//  HomeScreen.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/20/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class HomeScreen: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var events = [Event]()
    let cellID = "EventCell"
    var eventRef: CollectionReference!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = events[indexPath.row].name
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            
            let eventToDelete = events[indexPath.row]
            eventRef.document(eventToDelete.id).delete()
            
        }
    }
    
    let detailSegueID = "DetailSegueHome"
    let attendSegue = "AttendSegue"
    
    var eventListener: ListenerRegistration!
    var authLH : AuthStateDidChangeListenerHandle!
    @IBOutlet var eventTable: UITableView!
    var isDeleting = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authLH = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if(Auth.auth().currentUser == nil){
                print("No user. Go back")
                self.navigationController?.popViewController(animated: true)
            }
            else{
                print( "You are signed in")
            }
        }
        
        eventTable.delegate = self
        eventTable.dataSource = self
        startListening()
    }
    
    func startListening(){
        
        if(eventListener != nil){
            eventListener.remove()
        }
        
        var query = eventRef.limit(to:25).order(by: "name", descending: true)
        
        
        eventListener = query.addSnapshotListener { (querySnapshot, error) in
            if let querySnaphot = querySnapshot{
                self.events.removeAll()
                querySnapshot?.documents.forEach{
                    (documentSnapshot) in
                    print(documentSnapshot.documentID)
                    self.events.append(Event(documentSnapshot: documentSnapshot))
                }
                
                self.eventTable.reloadData()
            }else{
                print("There was an error")
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventListener.remove()
        Auth.auth().removeStateDidChangeListener(authLH)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showMenu))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
        
        eventRef = Firestore.firestore().collection("Events")
        
        
    }
    
    @objc func showMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let homeAction = UIAlertAction(title: "Home", style: .default) { (action ) in
            
        }
        alertController.addAction(homeAction)
        
        let attendAction = UIAlertAction(title: "Attendence", style: .default) { (action ) in
            self.performSegue(withIdentifier: self.attendSegue, sender: nil)
        }
        alertController.addAction(attendAction)
        
        let meetingAction = UIAlertAction(title: "Meeting Records", style: .default) { (action ) in
            
        }
        alertController.addAction(meetingAction)
        
        let gameAction = UIAlertAction(title: "Games List", style: .default) { (action ) in
            
        }
        alertController.addAction(gameAction)
        
        let statsAction = UIAlertAction(title: "View Stats", style: .default) { (action ) in
            
        }
        alertController.addAction(statsAction)
        
        let suggestAction = UIAlertAction(title: "Suggestions", style: .default) { (action ) in
            
        }
        alertController.addAction(suggestAction)
        
        
        let signoutAction = UIAlertAction(title: "Sign out", style: .default) { (action ) in
            do{
                try Auth.auth().signOut()
            } catch{
                print("Sign out error")
            }
        }
        alertController.addAction(signoutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        present(alertController,animated: true, completion: nil)
    }
    
    @objc func showChange(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let createAction = UIAlertAction(title: "Add event", style: .default) { (action ) in
            self.showAddEventDialog()
            
        }
        alertController.addAction(createAction)
        
        let deleteAction = UIAlertAction(title: self.isDeleting ? "Stop Deleting" : "Delete Events", style: .default) { (action ) in
            self.isDeleting = !self.isDeleting
            self.eventTable.setEditing(self.isDeleting, animated: true)
        }
        alertController.addAction(deleteAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        present(alertController,animated: true, completion: nil)
    }
    
    @objc  func showAddEventDialog(){
        
        let alertController = UIAlertController(title: "Add a new event", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Event Name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Event Description"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Add Event", style: .default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            let descTextField = alertController.textFields![1] as UITextField
            print("Adding Event")
            
            self.eventRef.addDocument(data: ["name": nameTextField.text!, "desc": descTextField.text!, "createdBy":Auth.auth().currentUser!.uid])
            
        }
        alertController.addAction(submitAction)
        
        present(alertController,animated: true, completion: nil)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == detailSegueID){
            if let indexPath = eventTable.indexPathForSelectedRow{
                print(events[indexPath.row].name)
                (segue.destination as! EventDetailVC).eventRef = eventRef.document(events[indexPath.row].id)
            }
        }
        if(segue.identifier == attendSegue){
            
        }
        
    }
    
    
}


class Event{
    
    var name: String
    var desc: String
    var id: String
    var createdBy: String
    
    init(documentSnapshot: DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.name = data["name"] as! String
        self.desc = data["desc"] as! String
        self.createdBy = data["createdBy"] as! String
    }
    
}
