//
//  GamesVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class GamesVC: UITableViewController{
    
    var games = [Game]()
    let cellID = "GameCell"
    var gamesRef: CollectionReference!
    
    let detailSegueID = "DetailSegueGame"
    
    var eventListener: ListenerRegistration!
    var isDeleting = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }
    
    func startListening(){
        
        eventListener = gamesRef.addSnapshotListener { (querySnapshot, error) in
            if let querySnaphot = querySnapshot{
                self.games.removeAll()
                querySnapshot?.documents.forEach{
                    (documentSnapshot) in
                    self.games.append(Game(documentSnapshot: documentSnapshot))
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
        
        navigationItem.title = "Games"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showChange))
        
        gamesRef = Firestore.firestore().collection("Games")
    }
    
    @objc func showChange(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let createAction = UIAlertAction(title: "Add game", style: .default) { (action ) in
            self.showAddSuggestionDialog()
            
        }
        alertController.addAction(createAction)
        
        let deleteAction = UIAlertAction(title: self.isDeleting ? "Stop deleting" : "Delete game", style: .default) { (action ) in
            self.isDeleting = !self.isDeleting
            self.tableView.setEditing(self.isDeleting, animated: true)
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true, completion: nil)
    }
    
    @objc  func showAddSuggestionDialog(){
        
        let alertController = UIAlertController(title: "Add an Improv Game", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Game name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Game description"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Add game", style: .default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            let name = nameTextField.text
            
            let gameTextField = alertController.textFields![1] as UITextField
            let game = gameTextField.text
            
            if(name != "" && game != ""){
                self.gamesRef.addDocument(data: ["name": name, "desc": game])
            }
        }
        alertController.addAction(submitAction)
        present(alertController,animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == detailSegueID){
            if let indexPath = tableView.indexPathForSelectedRow{
                (segue.destination as! GamesDetailVC).gameRef = gamesRef.document(games[indexPath.row].id)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = games[indexPath.row].name
        return cell;
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let gameToDelete = games[indexPath.row]
            gamesRef.document(gameToDelete.id).delete()
        }
    }
}


class Game{
    
    var id: String
    var name: String
    var desc: String
    
    init(documentSnapshot: DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.name = data["name"] as! String
        self.desc = data["desc"] as! String
    }
    
}
