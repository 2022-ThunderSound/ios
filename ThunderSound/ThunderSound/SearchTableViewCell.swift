//
//  SearchTableViewCell.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class SearchTableViewCell: UITableViewCell
{
    //  Variables
    @IBOutlet var nameLB: UILabel!
    @IBOutlet var nickLB: UILabel!
    @IBOutlet var perfilIMG: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()                                        //  Redondeamos la imagen de perfil
        self.perfilIMG.layer.cornerRadius = 40
        self.perfilIMG.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
