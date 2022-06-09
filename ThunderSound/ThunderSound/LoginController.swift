//
//  LoginController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class LoginController: UIViewController
{
    // Variables
    var myResponse: [String: Any] = [:]                                                             //  Aqui almacenamos la respuesta de la peticion
    @IBOutlet var userTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var rememberLB: UILabel!
    @IBAction func showPass(_ sender: Any)                                                          //  Boton para visualizar y ocultar la contraseña
    {
        passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
    }
    @IBAction func registerBT(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Registerid") as! RegisterController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func loginBT(_ sender: Any)
    {
        if userTF.text != nil || passwordTF.text != nil                                             //  Comprobar si estan vacios los campos
        {                                                                                           //  de ser asi saltaria un Alert
            peticionLogin(userTF: userTF.text!, passwordTF: passwordTF.text!)                       
        } else
        {
            let alert = UIAlertController(title: "Error", message: "No puedes dejar un campo sin rellenar", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let shared = UserDefaults.standard                                                         //   Estamos declarando el sharedPreference
        if let user = shared.string(forKey: "userTF")                                              //   comprobamos que el usuario ya se habia
        {                                                                                          //   logueado antes y le damos acceso sin
            if let pass = shared.string(forKey: "passwordTF")                                      //   tener que escribir de nuevo la contraseña
            {
                if user != "" && pass != ""
                {
                    peticionLogin(userTF: user, passwordTF: pass)
                }
            }
        }

        let tapOlvidar = UITapGestureRecognizer(target: self, action: #selector(self.tapRemember))          // Hacemos que se pueda hacer clic en  
        rememberLB.isUserInteractionEnabled = true
        rememberLB.addGestureRecognizer(tapOlvidar)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc                                                                                           //  Funcion recogida de objc para enviarnos a
    func tapRemember()                                                                              //  la pantalla de Olvidar Contraseña
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RememberPassid") as! RememberController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func peticionLogin(userTF: String, passwordTF: String)
    {
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/auth/login")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"                                                                 
        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyData = "nick=\(userTF)&password=\(passwordTF)"                                      //  Pasamos por body los datos para la peticion 
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
                        if self.myResponse["error"] as? String == "Unauthorized"
                        {
                            let alert = UIAlertController(title: "Error", message: "Algo salió mal con la autorización, intentelo de nuevo.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
                            alert.addAction(action)
                            present(alert, animated: true)
                        }
                        if self.myResponse["access_token"] != nil                                       //  Si recibimos data en el access_token...
                        {
                            let shared = UserDefaults.standard
                            shared.setValue(userTF, forKey: "userTF")                                   //  Guardamos en nuestro shared tanto el user como
                            shared.setValue(passwordTF, forKey: "passwordTF")                           //  el password, para posteriormente no tener que 
                            let id = self.myResponse["id"]                                              //  iniciar sesion de nuevo
                            let token = self.myResponse["access_token"]                                 //  Tambien se guarda mi id y mi token para usarlo
                            shared.set(token, forKey: "token")                                          //  en otras pantallas de mi aplicacion
                            shared.setValue(id, forKey: "id")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Inicioid") as! InicioController
                            vc.modalPresentationStyle = .fullScreen                                     //  Si todo ha ido bien nos manda a la pantalla de Inicio
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
