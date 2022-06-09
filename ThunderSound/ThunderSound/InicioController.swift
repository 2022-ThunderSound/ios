//
//  InicioController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class InicioController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet var inicioCollectionView: UICollectionView!
               
    override func viewDidLoad()
    {
        super.viewDidLoad()
        inicioCollectionView.delegate = self
        inicioCollectionView.dataSource = self
        let shared = UserDefaults.standard
        peticionPerfil(id: shared.integer(forKey: "id"))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let ancho : Int = Int(self.inicioCollectionView.frame.size.width)
        let alto = 255
        let tam = CGSize(width: ancho, height: alto)
        return tam
    }
    
    var posts: [[String: Any]] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inicioCell", for: indexPath) as! InicioCollectionViewCell
        let url = NSURL(string: posts[indexPath.row]["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.perfilIV.image = UIImage(data: data! as Data)
        }
        cell.userNameLB.text = (posts[indexPath.row]["nick"] as! String)
        cell.phraseLB.text = (posts[indexPath.row]["texto"] as! String)
        let numComent = (posts[indexPath.row]["nunmero_comentarios"])!
        cell.comentariosTotalesBT.setTitle("\(numComent)", for: .normal)
        let dataC = (posts[indexPath.row ]["cancion"] as! [String : Any])
        let songID = dataC["spotify_id"] as! String
        cell.InicioWebView.loadHTMLString("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Document</title></head><body style = \"background-color:#FC9025\"><iframe style=\"border-radius:12px\" src=\"https://open.spotify.com/embed/track/\(songID)?utm_source=generator\" width=\"100%\" height=\"90px\" frameBorder=\"0\" allowfullscreen=\"\" allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\"></iframe></body></html>", baseURL: nil)
        cell.InicioWebView.scrollView.isScrollEnabled = false
        cell.todoView.layer.cornerRadius = 15
        cell.todoView.clipsToBounds = true
        cell.perfilIV.layer.cornerRadius = 20
        cell.perfilIV.clipsToBounds = true
        cell.comentariosTotalesBT.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
        cell.comentariosTotalesBT.tag = posts[indexPath.row]["id"] as! Int
        return cell
    }
    
    var datos1: [String: Any] = [:]
    func peticionPerfil(id: Int)
    {
        let shared = UserDefaults.standard
        let id = shared.integer(forKey: "id")
        let urlString = "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)/siguiendo"
        guard let serviceUrl = URL(string: urlString) else { return }
        var request = URLRequest(url: serviceUrl)
        let token = (shared.string(forKey: "token")as! String)
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
                    print(self.datos1)
                    let dataG = self.datos1["data"] as! [String: Any]
                    if dataG["Error"] as? String == nil
                    {
                        self.posts = dataG["data"] as! [[String : Any]]
                    } else
                    {
                        let alert = UIAlertController(title: "No sigue a ningun usuario.", message: self.datos1["message"] as? String, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                    DispatchQueue.main.async
                    {
                        self.inicioCollectionView.reloadData()
                    }
                } else
                {
                    let alert = UIAlertController(title: "No ha sido posible cargar el perfil", message: self.datos1["message"] as? String, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "SearchUserid") as! SearchController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } catch let jsonError { print(jsonError) }
        }.resume()
    }
    
    @objc func onClick(sender: UIButton)
    {
            let id = sender.tag
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "VerPostid") as! VerPostViewController
            vc.modalPresentationStyle = .fullScreen
            vc.post_id = id
            self.present(vc, animated: true, completion: nil)
    }
}
