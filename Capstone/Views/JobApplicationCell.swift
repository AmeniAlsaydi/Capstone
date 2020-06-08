//
//  JobApplicationCell.swift
//  Capstone
//
//  Created by Amy Alsaydi on 6/7/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class JobApplicationCell: UICollectionViewCell {
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var submittedDateLabel: UILabel!
    
    override func layoutSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 12
    }
    
    
    // FIXME: understand public - private - internal
    public func configureCell(application: JobApplication) {
        
        
        
        positionLabel.text = application.positionTitle.capitalized
        companyNameLabel.text = application.companyName.capitalized
        submittedDateLabel.text = application.dateApplied.dateValue().dateString("mm/dd/yyyy")
    }
    
}
