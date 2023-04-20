//
//  MenuCell.swift
//  CornerStore
//
//  Created by JK on 2023/04/20.
//

import UIKit

class MenuCell: UITableViewCell {
    static let height : CGFloat = 90
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
