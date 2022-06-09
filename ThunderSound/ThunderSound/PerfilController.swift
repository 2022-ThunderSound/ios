//
//  PerfilController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class PerfilController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    //  Variables
    var posts: [[String: Any]] = []                                                                 //  Almacena los posts
    var datos1: [String: Any] = [:]                                                                 //  Almacena el primer data
    @IBOutlet var userNameLBp: UILabel!             
    @IBOutlet var myProfileIVp: UIImageView!
    @IBOutlet var followersLBp: UILabel!
    @IBOutlet var followLBp: UILabel!
    @IBOutlet var postLBp: UILabel!
    @IBOutlet var descriptionLBp: UILabel!
    @IBOutlet var postCV: UICollectionView!
    @IBAction func editeBTp(_ sender: Any)                                                          //  Nos manda a la pantalla editar
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Editid") as! EditProfileController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func logoutBTp(_ sender: Any)                                                         //  Limpia el shared y me manda al login
    {
        let shared = UserDefaults.standard
        shared.setValue("", forKey: "userTF")
        shared.setValue("", forKey: "passwordTF")
        shared.setValue("", forKey: "token")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Loginid") as! LoginController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad()                                                                     //  Manda la peticion al entrar en el controller
    {
        super.viewDidLoad()   
        postCV.dataSource = self
        postCV.delegate = self
        let shared = UserDefaults.standard
        peticionPerfil(id: shared.integer(forKey: "id"))                                            //  Redondea la imagen de perfil
        self.myProfileIVp.layer.cornerRadius = 45
        self.myProfileIVp.clipsToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {                                                                                               //  Saco la anchura y alto de cada celda
        let ancho : Int = Int(self.postCV.frame.size.width)/3
        let alto = 155
        let tam = CGSize(width: ancho, height: alto)
        return tam
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {                                                                                               //  Al seleccionar una celda nos lleva a ña vista detallada
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VerPostid") as! VerPostViewController
        vc.modalPresentationStyle = .fullScreen
        vc.post_id = posts[indexPath.row]["id"] as! Int
        self.present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {                                                                                               //  Coloco los datos en las variables
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postsCell", for: indexPath) as! PerfilCollectionViewCell
        let cancion: [String : Any] = posts[indexPath.row]["cancion"] as! [String : Any]
        let url = NSURL(string: cancion["url_portada"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.postIMG.image = UIImage(data: data! as Data)                                       //  Transformo la imagen a data
        }
        cell.postNameLB.text = (cancion["titulo"] as! String)
        return cell
    }
    
    func peticionPerfil(id: Int)                
    {                                                                                               //  Peticion por GET y token por url
        let shared = UserDefaults.standard
        let urlString = "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)/canciones"
        guard let serviceUrl = URL(string: urlString) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        let token = (shared.string(forKey: "token")!)
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
                if self.datos1["error"] as? String == nil
                {
                    let dataG = self.datos1["data"] as! [String: Any]                                       //  Almacena segundo data
                    self.posts = dataG["posts"] as! [[String : Any]]                                        //  Almacena el tercer data (posts)
                    DispatchQueue.main.async                                                                //  Introducimos los datos y recargamos el
                    {                                                                                       //  collectionView
                        self.rellenarDatos()
                        let nick = (dataG["nick"] as! String)
                        shared.setValue(nick, forKey: "nick")
                        let descripcion = (dataG["descripcion"] as! String)
                        shared.setValue(descripcion, forKey: "descripcion")
                        self.postCV.reloadData()
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
    
    func rellenarDatos()                                                                                     //  Rellenamos las variables con el data
    {
        let dataG = self.datos1["data"] as! [String: Any]
        let url = NSURL(string: dataG["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            myProfileIVp.image = UIImage(data: data! as Data)
        } 
        userNameLBp.text = (dataG["nick"] as! String)
        followersLBp.text = String(dataG["numeroseguidores"] as! Int)
        followLBp.text = String(dataG["numeroseguidos"] as! Int)
        postLBp.text = String(dataG["numeroposts"] as! Int)
        descriptionLBp.text = String(dataG["descripcion"] as! String)
    }
}
