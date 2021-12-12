//
//  DabaBaseManager.swift
//  ChatApp
//
//  Created by Sen Lin on 12/12/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    public func test(){
        print("Debug: TEST DATABASE")
        database.child("foo").setValue(["something": "yess"])
        database.child("bar").setValue(["handler": "yess"]) { error, reference in
            guard error == nil else{
                print("Debug: Error writing in database\(error?.localizedDescription)")
                return
            }
            
            print("Debug: success \(reference)")
        }
    }
}
