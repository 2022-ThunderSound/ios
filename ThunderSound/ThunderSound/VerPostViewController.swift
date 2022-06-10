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
    //  Variables
    var post_id = 0
    var comentarios: [[String: Any]] = []
    var post: [String:Any] = [:]                                                                         //  Almaceno el primer data de la peticion
    @IBAction func backBT(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)            //  Volver al Inicio
        let vc = storyboard.instantiateViewController(withIdentifier: "Inicioid") as! InicioController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBOutlet var userPostIMG: UIImageView!
    @IBOutlet var nickLB: UILabel!
    @IBOutlet var textoLB: UILabel!
    @IBOutlet var spotifyWebView: WKWebView!
    @IBOutlet var comentariosTotalLB: UIButton!
    @IBOutlet var comentariosTV: UITableView!
    @IBOutlet var comentarioTF: UITextField!
    @IBOutlet var comentarioBT: UIButton!
    @IBOutlet var perfilIMG: UIImageView!
    @IBAction func enviarComentario(_ sender: Any)
    {
        let texto = self.comentarioTF.text                                                              //  Comprobamos que no esta vacio y enviamos la peticion
        self.comentarioTF.text = ""
        if !texto!.isEmpty
        {
            self.peticionComentario(texto: texto!)
        }
    }
    
    override func viewDidLoad()                                                                          //  Al iniciarse se ejecuta la peticion
    {
        super.viewDidLoad()
        comentariosTV.delegate = self
        comentariosTV.dataSource = self
        userPostIMG.layer.cornerRadius = 15
        userPostIMG.clipsToBounds = true
        perfilIMG.layer.cornerRadius = 15
        perfilIMG.clipsToBounds = true
        
        spotifyWebView.scrollView.isScrollEnabled = false
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))             //  Pulsar fuera quita el teclado
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        peticionVerPost()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat             //  Tamaño fijo para cada comentario
    {
        return 125
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        comentarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell        //  Colocamos los datos en las variables
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verPostCell", for: indexPath) as! VerPostTableViewCell
        let url = NSURL(string: comentarios[indexPath.row]["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            cell.userIV.image = UIImage(data: data! as Data)                                              //  Transformamos la imagen a data
        }
        cell.userIV.layer.cornerRadius = 20                                                               //  Redondeamos la imagen de perfil y la View
        cell.userIV.clipsToBounds = true
        cell.comentarioView.layer.cornerRadius = 10                                                               //  Redondeamos la imagen de perfil y la View
        cell.nickLB.text = (comentarios[indexPath.row]["nick"] as! String)
        cell.comentarioLB.text = (comentarios[indexPath.row]["texto"] as! String)
        return cell
    }
    
    func rellenarDatos()                                                                                   //  Funcion para rellenar los datos del Post
    {                                                                                                      //  e introducir el codigo HTML en el WebView
        self.nickLB.text = String((post["nick"] as! String))
        self.textoLB.text = String((post["texto"] as! String))
        let spotifyId = String(post["spotify_id"] as! String)
        self.spotifyWebView.loadHTMLString("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Document</title></head><body style = \"background-color:#FC9025\"><iframe style=\"border-radius:12px\" src=\"https://open.spotify.com/embed/track/\(spotifyId)?utm_source=generator\" width=\"100%\" height=\"90px\" frameBorder=\"0\" allowfullscreen=\"\" allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\"></iframe></body></html>", baseURL: nil)
        self.comentariosTotalLB.titleLabel?.text = String(post["numero_comentarios"] as! Int)         //  Otra manera de poner los comentarios totales al Button
        let url = NSURL(string: post["foto_url"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil
        {
            self.userPostIMG.image = UIImage(data: data! as Data)
        }
        self.userPostIMG.layer.cornerRadius = 20
        self.userPostIMG.clipsToBounds = true
    }

    func peticionVerPost()                                                                                 //  Peticion por GET con token por url
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
                        if mySearch["error"] as? String == nil                                            //  Si todo va bien recogemos el data, rellenamos los  
                        {                                                                                 //  datos y recargamos el tableView, sida error salta un Alert
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
    
    func peticionComentario(texto:String)                                                               //  Peticion por POST con token por url y params por body
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
                        if mySearch["error"] as? String == nil
                        {
                            DispatchQueue.main.async
                            {
                                self.peticionVerPost()                                                  //  Si va bien mandamos la peticion a ver post y sube el comentario
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
}
