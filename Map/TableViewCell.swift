//
//  TableViewCell.swift
//  Map
//
//  Created by 123 on 2017/6/15.
//  Copyright © 2017年 123. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var coordinate: UILabel!
    @IBOutlet var bottomview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
