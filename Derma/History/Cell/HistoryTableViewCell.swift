//
//  HistoryTableViewCell.swift
//  Derma
//
//  Created by ahmed gado on 10/03/2025.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var historyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
