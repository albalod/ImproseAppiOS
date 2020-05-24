//
//  StatVC.swift
//  ImproseApp
//
//  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class StatVC: UITableViewController{
    
    var playerCounts : [String: Int] = [:]
    let cellID = "StatCell"
    var playerRef: CollectionReference!
    
    var eventListener: ListenerRegistration!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }
    
    func startListening(){
        
        eventListener = playerRef.addSnapshotListener { (querySnapshot, error) in
            if let querySnaphot = querySnapshot{
                self.playerCounts = [:]
                querySnapshot?.documents.forEach{
                    (documentSnapshot) in
                    var meet = Meeting (documentSnapshot: documentSnapshot)
                    meet.members.forEach{
                        (member) in
                        if(self.playerCounts[member] != nil){
                            let newVal = self.playerCounts[member]! + 1
                            self.playerCounts.updateValue(newVal, forKey: member)
                        }
                        else{
                            self.playerCounts.updateValue(1, forKey: member)
                        }
                    }
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
        
        navigationItem.title = "Player Stats"
        
        playerRef = Firestore.firestore().collection("Meetings")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return playerCounts.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        var  x = 0
        for (name, count) in playerCounts{
            if(x == indexPath.row){
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = "Meetings attended: \(count)"
                break;
            }
            x = x + 1
        }
           return cell;
       }
}
