//
//  UserJob.swift
//  Capstone
//
//  Created by Amy Alsaydi on 5/26/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import Foundation
import Firebase

struct UserJob {
    var title: String
    var companyName: String
    var beginDate: Timestamp
    var endDate: Timestamp
    var currentEmployer: Bool
    var description: String
    var responsibilities: [String]
    var starSituationIDs: [String]
    var interviewQuestionIDs: [String]
    var contactIDs: [String]
    var contacts: [Contact]
    
}
