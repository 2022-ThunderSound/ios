//
//  AlertController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit
import WebKit

class AlertController: UIViewController
{
    //  Variables
    let shared = UserDefaults.standard
    var myResponse: [String: Any] = [:]                                                                         //  Almacenamos el data de la peticion
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var nameUserLB: UILabel!
    @IBOutlet var alertView: UIView!
    @IBOutlet var publicarBT: UIButton!
    @IBAction func publicarBT(_ sender: Any)
    {
        peticionCrearPost()                                                                                     //  Boton para lanzar la peticion, no hacemos
    }                                                                                                           //  validacion porque el texto puede ser nil
    @IBOutlet var comentarioTF: UITextField!
    @IBOutlet var spotifyWebView: WKWebView!
    @IBAction func cerrarNewPostBT(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)                                                                //  Volver a la pantalla anterior
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "FondoThunderSound.png")!)           //  Pasamos imagen de fondo a una vista y  
        self.imgUser.layer.cornerRadius = 20                                                                  //  redondeamos IMG, View, TextField y BT
        self.imgUser.clipsToBounds = true                                                                     //  tambien introducimos el codigo HTML a
        self.alertView.layer.cornerRadius = 22                                                                //  nuestro WebView
        self.alertView.clipsToBounds = true
        self.comentarioTF.layer.cornerRadius = 15
        self.comentarioTF.clipsToBounds = true
        self.publicarBT.layer.cornerRadius = 8
        self.publicarBT.clipsToBounds = true
        let shared = UserDefaults.standard
        spotifyWebView.loadHTMLString("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Document</title></head><body><iframe style=\"border-radius:12px\" src=\"https://open.spotify.com/embed/track/\(shared.string(forKey: "songid")!)?utm_source=generator\" width=\"100%\" height=\"90%\" frameBorder=\"0\" allowfullscreen=\"\" allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\"></iframe></body></html>"
                                       , baseURL: nil)
    }
    
    func peticionCrearPost()                                                                        //  Peticion por POST y token por url
    {                                                                                               //  pasamos los parametros por body
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/posts")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(shared.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        let bodyData = "texto=\(comentarioTF.text!)&usuario_id=\(shared.string(forKey: "id")!)&spotify_id=\(shared.string(forKey: "songid")!)"
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
                        self.myResponse = json as! [String: Any]
                        print(json)
                        if self.myResponse["error"] as? String == nil                               //  Si todo es correcto nos lleva a nuestro perfil
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Profileid") as! PerfilController
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
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
