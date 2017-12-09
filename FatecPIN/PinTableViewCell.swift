//
//  PinTableViewCell2.swift
//  FatecPIN
//
//  Created by Lucas Caires on 09/12/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {

    @IBOutlet weak var PinDescription: UILabel!
    @IBOutlet weak var PinAuthor: UILabel!
    @IBOutlet weak var PinDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
