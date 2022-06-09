//
//  VerPostViewController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit
import WebKit

class VerPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBAction func backBT(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var userPostIMG: UIImageView!
    @IBOutlet var nickLB: UILabel!
    @IBOutlet var textoLB: UILabel!
    @IBOutlet var spotifyWebView: WKWebView!
    @IBOutlet var comentariosTotalLB: UIButton!
    @IBOutlet var comentariosTV: UITableView!
    @IBOutlet var comentarioTF: UITextField!
    @IBOutlet var comentarioBT: UIButton!
    
    var post_id = 0
    var comentarios: [[String: Any]] = []
    var post: [String:Any] = [:]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        comentariosTV.delegate = self
        comentariosTV.dataSource = self
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        peticionVerPost()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 125
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        comentarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verPostCell", for: indexPath) as! VerPostTableViewCell
        let url = NSURL(string: comentarios[indexPath.row]["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.userIV.image = UIImage(data: data! as Data)
        }
        cell.nickLB.text = (comentarios[indexPath.row]["nick"] as! String)
        cell.comentarioLB.text = (comentarios[indexPath.row]["texto"] as! String)
        return cell
    }//ESTO DEBERIA DE ESTAR BIEN PUESTO, PERO DEBO DE MODIFICAR LAS CLAVES CAUNDO SEPA LA PETICION
    
    func rellenarDatos()
    {
            self.nickLB.text = String((post["nick"] as! String))
            self.textoLB.text = String((post["texto"] as! String))
            let spotifyId = String(post["spotify_id"] as! String)
            self.spotifyWebView.loadHTMLString("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Document</title></head><body style = \"background-color:#FC9025\"><iframe style=\"border-radius:12px\" src=\"https://open.spotify.com/embed/track/\(spotifyId)?utm_source=generator\" width=\"100%\" height=\"90px\" frameBorder=\"0\" allowfullscreen=\"\" allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\"></iframe></body></html>", baseURL: nil)
            self.comentariosTotalLB.titleLabel?.text = String(post["numero_comentarios"] as! Int)
            let url = NSURL(string: post["foto_url"] as! String)
            let data = NSData(contentsOf: url! as URL)
            if data != nil
            {
                self.userPostIMG.image = UIImage(data: data! as Data)
            }
    }

    func peticionVerPost()
    {
        let shared = UserDefaults.standard
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/posts/\(post_id)/comentarios?mi_id=\(shared.string(forKey: "id")!)")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Bearer \(shared.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
      
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response{print(response)}
            if let data = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async
                    {
                        let mySearch = json as! [String: Any]
                        print(json)
                        
                        if mySearch["error"] as? String == nil
                        {
                            self.post = mySearch["data"] as! [String: Any]
                            self.comentarios = self.post["comentarios"] as! [[String:Any]]
                            DispatchQueue.main.async
                            {
                                self.rellenarDatos()
                                self.comentariosTV.reloadData()
                            }
                        } else
                        {
                            let alert = UIAlertController(title: "Error != 200", message: mySearch["message"] as? String, preferredStyle: .alert)
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
    
    func peticionComentario(texto:String)
    {
        let shared = UserDefaults.standard
        let id = shared.integer(forKey: "id")
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/comentarios")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let bodyData = "texto=\(texto)&usuario_id=\(id)&post_id=\(self.post_id)"
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        request.setValue("Bearer \(shared.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response{print(response)}
            if let data = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async
                    {
                        let mySearch = json as! [String: Any]
                        print(json)

                        if mySearch["error"] as? String == nil
                        {
                            DispatchQueue.main.async
                            {
                                self.peticionVerPost()
                            }
                        } else
                        {
                            let alert = UIAlertController(title: "Error != 200", message: mySearch["message"] as? String, preferredStyle: .alert)
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

    @IBAction func enviarComentario(_ sender: Any)
    {
        let texto = self.comentarioTF.text
        self.comentarioTF.text = ""

        if !texto!.isEmpty
        {
            self.peticionComentario(texto: texto!)
        }
    }
}
