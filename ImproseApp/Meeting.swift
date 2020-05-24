//
//  Meeting.swift
//  ImproseApp
//
//Users/csse/Documents/ImproseApp/ImproseApp/  Created by CSSE Department on 5/22/20.
//  Copyright © 2020 Rose-Hulman CSSE484. All rights reserved.
//

import UIKit
import Firebase

class Meeting{
    
    var id: String
    var name: String
    var members: [String]
    var games: [String]
    
    init(documentSnapshot: DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.name = data["name"] as! String
        self.members = data["members"] as! [String]
        self.games = data["games"] as! [String]
        
    }
    
    
}
