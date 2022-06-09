//
//  SeguirController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit
import WebKit

class SeguirController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBAction func atrasBT(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var userNameLBf: UILabel!
    @IBOutlet var profileIVf: UIImageView!
    @IBOutlet var followersLBf: UILabel!
    @IBOutlet var followLBf: UILabel!
    @IBOutlet var postLBf: UILabel!
    @IBOutlet var descriptionLBf: UILabel!
    @IBOutlet var postsCV: UICollectionView!
    @IBAction func followBTf(_ sender: Any)
    {
//        peticionSeguir()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        postsCV.delegate = self
        postsCV.dataSource = self
        self.profileIVf.layer.cornerRadius = 45
        self.profileIVf.clipsToBounds = true
        let shared = UserDefaults.standard
        let id = shared.integer(forKey: "id")
        peticionPerfil(id: id)
    }
    
    var posts: [[String : Any]] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VerPostid") as! VerPostViewController
        vc.modalPresentationStyle = .fullScreen
        vc.post_id = posts[indexPath.row]["id"] as! Int
        self.present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "perfilCell", for: indexPath) as! SeguirCollectionViewCell
        let cancion: [String : Any] = posts[indexPath.row]["cancion"] as! [String : Any]
        let url = NSURL(string: cancion["url_portada"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.postIMG.image = UIImage(data: data! as Data)
        }
        cell.postNameLB.text = (cancion["titulo"] as! String)
        return cell
    }
    
    var datos1: [String: Any] = [:]
    func peticionPerfil(id: Int)
    {
        let shared = UserDefaults.standard
        let urlString = "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)/canciones"
        guard let serviceUrl = URL(string: urlString) else { return }
        var request = URLRequest(url: serviceUrl)
        let token = (shared.string(forKey: "token")!)
        print(token)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            if response != nil
            {
                print(response ?? "No se han obtenido respuesta")
            }
            guard let data = data else { return }
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String:Any]
                self.datos1 = json
                print(json)
                if self.datos1["error"] as? String == nil
                {
                    let dataG = self.datos1["data"] as! [String: Any]
                    self.posts = dataG["posts"] as! [[String : Any]]
                    DispatchQueue.main.async
                    {
                        self.rellenarDatos()
                        self.postsCV.reloadData()
                    }
                } else
                {
                    let alert = UIAlertController(title: "No ha sido posible cargar el perfil", message: self.datos1["message"] as? String, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            } catch let jsonError { print(jsonError) }
        }.resume()
    }
    
    func rellenarDatos()
    {
        let dataG = self.datos1["data"] as! [String: Any]
        let url = NSURL(string: dataG["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            profileIVf.image = UIImage(data: data! as Data)
        }
        userNameLBf.text = (dataG["nick"] as! String)
        followersLBf.text = String(dataG["numeroseguidores"] as! Int)
        followLBf.text = String(dataG["numeroseguidos"] as! Int)
        postLBf.text = String(dataG["numeroposts"] as! Int)
        descriptionLBf.text = String(dataG["descripcion"] as! String)
    }
    
//    func peticionSeguir()
//    {
//        let dataG = self.datos1["data"] as! [String: Any]
//
//        let shared = UserDefaults.standard
//        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/siguiendo")
//        guard let serviceUrl = URL(string: Url) else { return }
//        var request = URLRequest(url: serviceUrl)
//        request.httpMethod = "POST"
//        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        let bodyData = "emisor_id=\(shared.integer(forKey: "id"))&receptor_id=\(dataG["id"])"
//        request.httpBody = bodyData.data(using: String.Encoding.utf8);
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            if let response = response{print(response)}
//            if let data = data
//            {
//                do
//                {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    DispatchQueue.main.async
//                    { [self] in
//                        self.posts = json as! [[String : Any]]
//                        print(json)
//                        if self.posts["error"] != nil
//                        {
//                            //esto seria para ir a la pantalla de que ahora si le sigo
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = storyboard.instantiateViewController(withIdentifier: "SeguirProfileYES") as! SeguirControllerYES
//                            vc.modalPresentationStyle = .fullScreen
//                            self.present(vc, animated: true, completion: nil)
//                        }
//                    }
//                } catch
//                {
//                    print(error)
//                }
//            }
//        }.resume()
//    }
}
