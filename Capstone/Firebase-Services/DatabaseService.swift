//
//  DatabaseService.swift
//  Capstone
//
//  Created by Amy Alsaydi on 5/26/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    public static let shared = DatabaseService()
    private init() {}
    
    static let testCollection = "tester"
    static let userCollection = "users"
    static let userJobCollection = "userJobs"
    
    private let db = Firestore.firestore()
    
    public func testFirebase(completion: @escaping (Result<[TestModel], Error>) -> ()) {
        
        db.collection(DatabaseService.testCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                
                let testJobs = snapshot.documents.map { TestModel($0.data())}
                completion(.success(testJobs))
            }
        }
    }
    
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>)-> ()) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        db.collection(DatabaseService.userCollection).document(authDataResult.user.uid).setData(["email": email, "createdDate": Timestamp(date: Date()), "id": authDataResult.user.uid]) { error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    
    
    public func fetchUserJobs(completion: @escaping (Result<[UserJob], Error>)->()) {
        guard let user = Auth.auth().currentUser else { return}
        
        let userID = user.uid // use this to test -> "LOT6p7nkxfM69CCtjB41" 
        
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.userJobCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let userJobs = snapshot.documents.map { UserJob($0.data())}
                completion(.success(userJobs))
            }
        }
        
    }
    
}
