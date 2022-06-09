//
//  CollectionViewCell.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit
import WebKit

class InicioCollectionViewCell: UICollectionViewCell
{
    //  Variables necesarias en InicioController
    @IBOutlet var todoView: UIView!
    @IBOutlet var perfilIV: UIImageView!
    @IBOutlet var userNameLB: UILabel!
    @IBOutlet var phraseLB: UILabel!
    @IBOutlet var comentariosTotalesBT: UIButton!
    @IBOutlet var InicioWebView: WKWebView!
}
