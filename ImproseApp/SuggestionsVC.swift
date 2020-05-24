//
//  SuggestionsVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class SuggestionsVC: UITableViewController{
    
    var suggests = [Suggestion]()
    let cellID = "SuggestCell"
    var suggestRef: CollectionReference!
    
    let detailSegueID = "DetailSegueSuggest"
    
    var eventListener: ListenerRegistration!
    var isDeleting = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }
    
    func startListening(){
        
        eventListener = suggestRef.addSnapshotListener { (querySnapshot, error) in
            if let querySnaphot = querySnapshot{
                self.suggests.removeAll()
                querySnapshot?.documents.forEach{
                    (documentSnapshot) in
                    self.suggests.append(Suggestion(documentSnapshot: documentSnapshot))
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
        
        navigationItem.title = "Suggestions"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
        
        suggestRef = Firestore.firestore().collection("Suggestions")
    }
    
    @objc func showChange(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let createAction = UIAlertAction(title: "Add suggestion", style: .default) { (action ) in
            self.showAddSuggestionDialog()
            
        }
        alertController.addAction(createAction)
        
        let deleteAction = UIAlertAction(title: self.isDeleting ? "Stop Deleting" : "Delete suggestions", style: .default) { (action ) in
            self.isDeleting = !self.isDeleting
            self.tableView.setEditing(self.isDeleting, animated: true)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true, completion: nil)
    }
    
    @objc  func showAddSuggestionDialog(){
        
        let alertController = UIAlertController(title: "Suggest an idea", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Your suggestion"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Add suggestion", style: .default) { (action) in
            let contentTextField = alertController.textFields![0] as UITextField
            let content = contentTextField.text
            
            if(content != ""){
                self.suggestRef.addDocument(data: ["content": content])
            }
        }
        alertController.addAction(submitAction)
        present(alertController,animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == detailSegueID){
            if let indexPath = tableView.indexPathForSelectedRow{
                (segue.destination as! SuggestDetailVC).suggestRef = suggestRef.document(suggests[indexPath.row].id)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return suggests.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
           cell.textLabel?.text = suggests[indexPath.row].content
           return cell;
       }
       
       
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if(editingStyle == .delete){
               let suggestToDelete = suggests[indexPath.row]
               suggestRef.document(suggestToDelete.id).delete()
           }
       }
}


class Suggestion{

    var id: String
    var content: String
    
    init(documentSnapshot: DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.content = data["content"] as! String
    }
    
}
