//
//  SummaryCell.swift
//  Speedy
//
//  Created by Edward Chiou on 3/10/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class SummaryCell: UITableViewCell{
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}