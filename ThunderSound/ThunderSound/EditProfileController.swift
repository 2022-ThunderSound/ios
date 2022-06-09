//
//  EditProfileController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class EditProfileController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBAction func atrasBT(_ sender: Any) {dismiss(animated: true, completion: nil)}
    @IBOutlet var userTF: UITextField!
    @IBOutlet var passTF: UITextField!
    @IBOutlet var passx2TF: UITextField!
    @IBOutlet var descripcionTF: UITextField!
    @IBOutlet var editarIMG: UIImageView!
    @IBAction func addIMG(_ sender: Any)
    {
        let ac = UIAlertController(title: "Seleccionar Imagen", message: "Seleccione una imagen", preferredStyle: .actionSheet)
        let cameraBT = UIAlertAction(title: "Camara", style: .default)
        { (_) in
            self.showImagePicker(selectedSource: .camera)
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
    @IBAction func guardarBT(_ sender: Any)
    {
        var bodyData = ""
        let shared = UserDefaults.standard
        let imgString = editarIMG.image?.pngData()?.base64EncodedString()
        if passTF.text == passx2TF.text || userTF.text != nil || descripcionTF.text != nil || imgString?.isEmpty == false
        {
            
            if userTF.text != nil
            {
                bodyData = "nick=\(userTF.text!)"
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
        super.viewDidLoad()
        self.editarIMG.layer.cornerRadius = 55
        self.editarIMG.clipsToBounds = true
        self.descripcionTF.layer.cornerRadius = 10
        self.descripcionTF.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func comprobarDatos()
    {
        
    }
    
    var myDictionary: [String: Any] = [:]
    func peticionEditarPerfil(id: Int, bodyData: String)
    {
        let imgString = editarIMG.image?.pngData()?.base64EncodedString()
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/usuarios/\(id)")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.addValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT/PATCH" //EDITAR

        
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
                        
                        if self.myDictionary["error"] as? String == nil
                        {
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Profileid") as! PerfilController
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                            
                        } else
                        {
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

    func showImagePicker(selectedSource: UIImagePickerController.SourceType)
    {
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else
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
