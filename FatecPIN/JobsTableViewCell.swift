//
//  JobsTableViewCell.swift
//  FatecPIN
//
//  Created by Lucas Caires on 08/12/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit
import SafariServices

class JobsTableViewCell: UITableViewCell {

    @IBOutlet weak var JobTitle: UILabel!
    @IBOutlet weak var JobDate: UILabel!
    @IBOutlet weak var JobDescription: UILabel!
    @IBOutlet weak var JobCompany: UILabel!
    


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    
}
