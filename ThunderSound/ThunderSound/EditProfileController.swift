//
//  EditProfileController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class EditProfileController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //  Variables
    var myDictionary: [String: Any] = [:]                                                           //  Almacenamos el data de la peticion
    @IBAction func atrasBT(_ sender: Any) {dismiss(animated: true, completion: nil)}
    @IBOutlet var userTF: UITextField!
    @IBOutlet var passTF: UITextField!
    @IBOutlet var passx2TF: UITextField!
    @IBOutlet var descripcionTF: UITextField!
    @IBOutlet var editarIMG: UIImageView!
    @IBAction func addIMG(_ sender: Any)
    {                                                                                               //  Boton para elegir foto de perfil
        let ac = UIAlertController(title: "Seleccionar Imagen", message: "Seleccione una imagen", preferredStyle: .actionSheet)
        let cameraBT = UIAlertAction(title: "Camara", style: .default)                              //  Creamos un Alert para decidir de donde
        { (_) in                                                                                    //  sacaremos nuestra imagen de perfil y
            self.showImagePicker(selectedSource: .camera)                                           //  llamamos a la funcion correspondiente
        }
        let galeriaBT = UIAlertAction(title: "Galeria", style: .default)
        { (_) in
            self.showImagePicker(selectedSource: .photoLibrary)
        }
        let cancelBT = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cameraBT)
        ac.addAction(galeriaBT)
        ac.addAction(cancelBT)
        self.present(ac, animated: true, completion: nil)
    }
    @IBAction func guardarBT(_ sender: Any)                                                          //  Boton para enviar peticion de Editar Perfil
    {
        var bodyData = ""
        let shared = UserDefaults.standard
        let imgString = editarIMG.image?.pngData()?.base64EncodedString()
        if passTF.text == passx2TF.text || userTF.text != nil || descripcionTF.text != nil || imgString?.isEmpty == false
        {
            
            if userTF.text != nil
            {
                bodyData = "nick=\(userTF.text!)" // hay que probar a pasarlos por json en vez de body
            }
            print(bodyData)
            
            
            let id = shared.integer(forKey: "id")       
            peticionEditarPerfil(id: id, bodyData: bodyData)
        } else
        {
            let alert = UIAlertController(title: "Error", message: "No puedes dejar ningun campo sin rellenar", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()                                                                             //  Redondeamos la imagen de perfil y 
        self.editarIMG.layer.cornerRadius = 55                                                          //  el cuadro de descripcion
        self.editarIMG.clipsToBounds = true
        self.descripcionTF.layer.cornerRadius = 10
        self.descripcionTF.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))            //  Desactivar teclado al pulsar fuera
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func comprobarDatos()
    {
        
    }
    
    func peticionEditarPerfil(id: Int, bodyData: String)//Aqui vendria el jsonData
    {
        let imgString = editarIMG.image?.pngData()?.base64EncodedString()
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.addValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT" //EDITAR

        
//        let bodyData = "?password=\(passTF.text!)&nick=\(userTF.text!)&descripcion=\(descripcionTF.text!)&foto_url=\(String(describing: imgString))"
         // NO ESTOY SEGURO DEL .text! pero creo que esta bien
        print(bodyData)
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
                    {
                        self.myDictionary = json as! [String: Any]
                        print(json)
                        
                        if self.myDictionary["error"] as? String == nil                                                 //  Si no recibimos ningun error...
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Profileid") as! PerfilController
                            vc.modalPresentationStyle = .fullScreen                                                     //  Nos lleva a nuestro perfil 
                            self.present(vc, animated: true, completion: nil)
                        } else
                        {                                                                                               //  Sino salta un error con los posibles errores
                            let alert = UIAlertController(title: "Error != 200", message: self.myDictionary["message"] as? String, preferredStyle: .alert)
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

    func showImagePicker(selectedSource: UIImagePickerController.SourceType)                                    //  Estas tres funciones estan permitiendo
    {                                                                                                           //  que podamos coger una imagen de nuestra
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else                                //  galeria o camara del telefono
        {
            print("Recurso seleccionado no disponible.")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[.originalImage] as? UIImage
        {
            editarIMG.image = selectedImage
        } else
        {
            print("No se encuentra la imagen.")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
