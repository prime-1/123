//
//  CaptionTableCell.swift
//  ModelApp
//
//  Created by Chan* on 2016/12/01.
//  Copyright © 2016年 chancp3. All rights reserved.
//

import Foundation
import UIKit

class CaptionTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var captionView: UIImageView!
    @IBOutlet weak var PlaceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
