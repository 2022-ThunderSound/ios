//
//  VerPostTableViewCell.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class VerPostTableViewCell: UITableViewCell
{
    //  Variables
    @IBOutlet var userIV: UIImageView!
    @IBOutlet var nickLB: UILabel!
    @IBOutlet var comentarioLB: UILabel!
    @IBOutlet var comentarioView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
