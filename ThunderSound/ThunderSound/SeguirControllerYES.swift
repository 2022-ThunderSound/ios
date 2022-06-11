//
//  SeguirControllerYES.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit
import WebKit

class SeguirControllerYES: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    //  Variables
    var posts: [[String : Any]] = []                                                                          //  Almacenamos los posts
    var datos1: [String : Any] = [:]                                                                          //  Almacenamos los datos recogidos de la aplicacion
    @IBAction func atrasBT(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Inicioid") as! InicioController        //  Volver a la pantalla anterior
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBOutlet var userNameLB: UILabel!
    @IBOutlet var profileIV: UIImageView!
    @IBOutlet var followersLB: UILabel!
    @IBOutlet var followLB: UILabel!
    @IBOutlet var postLB: UILabel!
    @IBOutlet var descriptionLB: UILabel!
    @IBOutlet var postsCV: UICollectionView!
    @IBAction func unfollowBT(_ sender: Any)
    {
        peticionDejarSeguir()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()                                                                                   //  Redondeamos la imagen de perfil y lanzamos la peticion
        postsCV.delegate = self
        postsCV.dataSource = self
        self.profileIV.layer.cornerRadius = 45
        self.profileIV.clipsToBounds = true
        let shared = UserDefaults.standard
        let id = shared.integer(forKey: "perfilBid")
        let miID = shared.integer(forKey: "id")
        peticionPerfil(id: id, miID: miID)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "perfilCell", for: indexPath) as! SeguirCollectionViewCell
        let cancion: [String : Any] = posts[indexPath.row]["cancion"] as! [String : Any]                     //  Colocamos los datos en las variables 
        let url = NSURL(string: cancion["url_portada"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.postIMG.image = UIImage(data: data! as Data)
        }
        cell.postNameLB.text = (cancion["titulo"] as! String)
        return cell
    }
    
    func peticionPerfil(id: Int, miID: Int)
    {                                                                                                       //  Peticion por GET con token por url
        let shared = UserDefaults.standard
        let urlString = "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)/canciones?mi_id=\(miID)"
        guard let serviceUrl = URL(string: urlString) else { return }
        var request = URLRequest(url: serviceUrl)
        let token = (shared.string(forKey: "token")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            if response != nil
            {
                print(response ?? "No se ha obtenido respuesta")
            }
            guard let data = data else { return }
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String:Any]
                self.datos1 = json
                if self.datos1["error"] as? String == nil
                {                                                                                           //  Si todo va bien...
                    let dataG = self.datos1["data"] as! [String: Any]                                       //  Almacenamos el primer data
                    self.posts = dataG["posts"] as! [[String : Any]]                                        //  Almacenamos el segundo data (pots)
                    DispatchQueue.main.async                                                                //  rellenamos los datos y recargamos la tabla
                    {
                        self.rellenarDatos()
                        self.postsCV.reloadData()
                    }
                } else                                                                                      //  Sino salta un alert de error
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
    {                                                                                                       //  Recogemos las variables y colocamos los datos
        let dataG = self.datos1["data"] as! [String: Any]
        let url = NSURL(string: dataG["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            profileIV.image = UIImage(data: data! as Data)
        }
        userNameLB.text = (dataG["nick"] as! String)
        followersLB.text = String(dataG["numeroseguidores"] as! Int)
        followLB.text = String(dataG["numeroseguidos"] as! Int)
        postLB.text = String(dataG["numeroposts"] as! Int)
        descriptionLB.text = String(dataG["descripcion"] as! String)
    }
    
    func peticionDejarSeguir()
    {                                                                                                               //  Peticion por POST con token por url y datos por body
        let shared = UserDefaults.standard
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/dejardeseguir")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyData = "emisor_id=\(shared.integer(forKey: "id"))&receptor_id=\(shared.integer(forKey: "perfilBid"))"
        request.setValue("Bearer \(shared.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response{print(response)}
            if let data = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async
                    { [self] in
                        let myResponse = json as! [String : Any]
                        
                        print(json)
                        if myResponse["error"] == nil
                        {                                                                                           //  Si todo va bien nos lleva a la pantala Seguir
                            DispatchQueue.main.async
                            {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "suPerfilid") as! SeguirController
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        } else                                                                                     //  Sino muestra un alert de error
                        {
                            let alert = UIAlertController(title: "No ha sido posible seguir a este perfil", message: self.datos1["message"] as? String, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true)
                        }
                    }
                } catch
                {
                    print(error)
                }
            }
        }.resume()
    }   
}
