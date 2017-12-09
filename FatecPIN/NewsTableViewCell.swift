//
//  NewsTableViewCell2.swift
//  FatecPIN
//
//  Created by Lucas Caires on 01/12/17.
//  Copyright © 2017 Lucas Caires. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NewsImage: UIImageView!
    @IBOutlet weak var NewsTitle: UILabel!
    @IBOutlet weak var NewsText: UILabel!
    @IBOutlet weak var NewsDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutMargins = UIEdgeInsetsMake(8, 0, 8, 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
