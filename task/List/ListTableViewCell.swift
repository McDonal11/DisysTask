//
//  ListTableViewCell.swift
//  task
//
//  Created by Gopal on 11/08/19.
//  Copyright © 2019 Gopal. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var glassyEffectVw: UIView!
    
    
    @IBOutlet weak var thumbNailImgVw: UIImageView!
    
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var descLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
