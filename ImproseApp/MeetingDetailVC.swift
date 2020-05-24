//  MeetingDetailVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/20/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MeetingDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var meeting : Meeting!
    let cellID = "GameCell"
    var meetingRef: DocumentReference!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (meeting?.games.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = meeting?.games[indexPath.row]
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            meeting?.games.remove(at: indexPath.row)
            meetingRef.updateData(["Games": meeting?.games])
        }
    }
    
    var gameListener: ListenerRegistration!
    @IBOutlet var gameTable: UITableView!
    @IBOutlet var namesLabel: UILabel!
    var isDeleting = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gameTable.delegate = self
        gameTable.dataSource = self
       
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
    }
    
    func startListening(){
        
        if(gameListener != nil){
            gameListener.remove()
        }
        
        gameListener = meetingRef.addSnapshotListener{
            (documentSnapshot, error) in
            self.meeting = Meeting(documentSnapshot: documentSnapshot!)
            self.gameTable.reloadData()
            self.navigationItem.title = self.meeting?.name
            self.updateView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListening()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
    }
    
    @objc func showChange(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let createAction = UIAlertAction(title: "Add game to meeting", style: .default) { (action ) in
            self.showAddGameDialog()
            
        }
        alertController.addAction(createAction)
        
        let renameAction = UIAlertAction(title: "Rename meeting", style: .default) { (action ) in
            self.showRenameDialog()
        }
        alertController.addAction(renameAction)
        
        let deleteAction = UIAlertAction(title: self.isDeleting ? "Stop Deleting" : "Delete Games", style: .default) { (action ) in
            self.isDeleting = !self.isDeleting
            self.gameTable.setEditing(self.isDeleting, animated: true)
        }
        alertController.addAction(deleteAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        present(alertController,animated: true, completion: nil)
    }
    
    @objc  func showAddGameDialog(){
        
        let alertController = UIAlertController(title: "Add a game to meeting", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Event Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Add Event", style: .default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            
            if(nameTextField.text != ""){
                if(!(self.meeting?.games.contains(nameTextField.text!))!){
                    self.meeting?.games.append(nameTextField.text!)
                    self.meetingRef.updateData(["games": self.meeting!.games])
                }
            }
            
        }
        alertController.addAction(submitAction)
        present(alertController,animated: true, completion: nil)
    }
    
    @objc  func showRenameDialog(){
        
        let alertController = UIAlertController(title: "Rename Meeting", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addTextField { (textField) in
            textField.text = self.meeting?.name
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Rename", style: .default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            
            if(nameTextField.text != ""){
                self.meeting?.name = nameTextField.text!
                self.meetingRef.updateData(["name": self.meeting!.name])
            }
        }
        
        alertController.addAction(submitAction)
        present(alertController,animated: true, completion: nil)
    }
    
    func updateView(){
        var message = "Members present:"
        meeting?.members.forEach{
            (name) in
            message = message + " \(name),"
        }
        
        namesLabel.text = String(message.prefix(message.count-1))
    }
    
}


