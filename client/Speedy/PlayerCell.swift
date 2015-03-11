//
//  PlayerCell.swift
//  Speedy
//
//  Created by Edward Chiou on 3/9/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class PlayerCell: UITableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}