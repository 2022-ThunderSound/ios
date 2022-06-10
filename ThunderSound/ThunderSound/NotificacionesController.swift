//
//  NotificacionesController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class NotificacionesController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //  Variables
    var myNotif: [String: Any] = [:]                                                            //  Almacenamos los datos de la peticion
    var notificaciones: [[String: Any]] = []
    @IBOutlet var notificationTV: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        notificationTV.delegate = self
        notificationTV.dataSource = self
        let shared = UserDefaults.standard
        let id = shared.integer(forKey: "id")                                                   //  Sacamos el shared para meter mi id a la peticion
        peticionGetNotif(id: id)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        notificaciones.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat    // Damos altura fija a la celda para que se ajusten al tamaño del diseño
    {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell      //  Colocamos los datos en las variables
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifCell", for: indexPath) as! NotifTableViewCell
        let url = NSURL(string: notificaciones[indexPath.row]["foto_emisor"] as! String)
        let data = NSData(contentsOf: url! as URL)
        if data != nil                                                                                  //  Obtenemos la imagen de nuevo
        {
            cell.userNotifIMG.image = UIImage(data: data! as Data)
        }
        cell.textoNotifTV.text = (notificaciones[indexPath.row]["tipo"] as! String)
        if (notificaciones[indexPath.row]["tipo"] as! String) == "COMENTARIO"                           //  Diferenciamos entre los dos tipos de notificaciones
        {
            cell.textoNotifTV.text = "Has recibido un comentario de \((notificaciones[indexPath.row]["nick_emisor"] as! String))."
            cell.iconNotifIMG.image = UIImage(named: "ComentarioPostIcono")
        } else
        {
            cell.textoNotifTV.text = "\((notificaciones[indexPath.row]["nick_emisor"] as! String)) ha comenzado a seguirte."
            cell.iconNotifIMG.image = UIImage(named: "NotificacionIcono")
        }
        return cell
    }

    func peticionGetNotif(id: Int)                                                                      //  Peticion por GET, añadiendo el token por url 
    {
        let shared = UserDefaults.standard
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)/notificaciones")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.setValue("Bearer \(shared.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response{print(response)}
            if let data = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    self.myNotif = json as! [String: Any]
                    if self.myNotif["error"] as? String == nil
                    {
                        let dataG = self.myNotif["data"] as! [String: Any]
                        if dataG["Error"] as? String == nil
                        {
                            self.notificaciones = dataG["data"] as! [[String : Any]]
                            DispatchQueue.main.async
                            {
                                self.notificationTV.reloadData()                                            //  Si todo va bien recargamos la tabla, sino
                            }                                                                               //  muestra un Alert
                        } else
                        {
                            let alert = UIAlertController(title: "No ha recibido ninguna notificación.", message: self.myNotif["message"] as? String, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true)
                        }
                    } else
                    {
                        let alert = UIAlertController(title: "No ha recibido ninguna notificación.", message: self.myNotif["message"] as? String, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                } catch
                {
                    print(error)
                }
            }
        }.resume()
    }
}
