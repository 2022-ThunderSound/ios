//
//  NotifTableViewCell.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class NotifTableViewCell: UITableViewCell
{
    //  Variables
    @IBOutlet var textoNotifTV: UILabel!
    @IBOutlet var iconNotifIMG: UIImageView!
    @IBOutlet var userNotifIMG: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()                            //  Redondear la imagen de usuario
        self.userNotifIMG.layer.cornerRadius = 46
        self.userNotifIMG.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
