//
//  SettingCell.swift
//  Capstone
//
//  Created by Tsering Lama on 6/11/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    public func configureCell(setting: ProfileCells) {
        settingsImage.image = setting.images
        settingsName.text = setting.title
        iconImageView.tintColor = AppColors.primaryPurpleColor
    }
}
