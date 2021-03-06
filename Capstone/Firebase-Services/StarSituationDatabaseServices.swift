//
//  StarSituationDatabaseServices.swift
//  Capstone
//
//  Created by Amy Alsaydi on 6/9/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

extension DatabaseService {
    public func addToStarSituations(starSituation: StarSituation, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.starSituationsCollection).document(starSituation.id).setData(["id": starSituation.id, "situation": starSituation.situation, "task": starSituation.task as Any, "action": starSituation.action as Any, "result": starSituation.result as Any, "userJobID": starSituation.userJobID as Any, "interviewQuestionsIDs": starSituation.interviewQuestionsIDs]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    public func fetchStarSituations(completion: @escaping (Result<[StarSituation], Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.starSituationsCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let situations = snapshot.documents.map{ StarSituation($0.data()) }
                completion(.success(situations))
            }
        }
    }
    // must be deleted from the collection as well as the all ids from where star situations are being referenced
    public func removeStarSituation(situation: StarSituation, completion:  @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        // delete from main star situations collection
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.starSituationsCollection).document(situation.id).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    public func removeStarSituationfromUserJob(situation: StarSituation, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        // situation.userJobID is needed here to remove the id reference from its array of star situations
        // if its nil then the star situation has not been associated with a job and probably doesnt exsit in as an id reference is any job
        guard let jobID = situation.userJobID else {
            completion(.success(false))
            return
        }
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.userJobCollection).document(jobID).updateData(["starSituationIDs": FieldValue.arrayRemove(["\(situation.id)"])]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func addStarSituationToUserJob(situation: StarSituation, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        guard let jobID = situation.userJobID else {
            completion(.success(false))
            return
        }
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.userJobCollection).document(jobID).updateData(["starSituationIDs": FieldValue.arrayUnion(["\(situation.id)"])]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    // Function to update a star situation: with a user job id if its selected to be be added to a list of starSituationIDs
    // takes in the current userjob (or just the id)
    // takes in a situation
    // updates the userJobID field wit the passed userjob id info
    // this would be called when a user job is created or updated
    public func updateStarSituationWithUserJobId(userJobID: String, starSitutationID: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.starSituationsCollection).document(starSitutationID).updateData(["userJobID": userJobID]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    // remove user job from star situation
    
    public func removeUserJobFromStarStory(starSitutationID: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else {return}
        let userID = user.uid
        
        let id: String? = nil 
        
        db.collection(DatabaseService.userCollection).document(userID).collection(DatabaseService.starSituationsCollection).document(starSitutationID).updateData(["userJobID": id as Any]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
