//
//  RegisterController.swift
//  ThunderSound
//
//  Created by Juanjo
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBAction func atrasBT(_ sender: Any) {dismiss(animated: true, completion: nil)}
    @IBOutlet var emailTFr: UITextField!
    @IBOutlet var passTFr: UITextField!
    @IBOutlet var passx2TFr: UITextField!
    @IBOutlet var editarIMG: UIImageView!
    @IBAction func addImage(_ sender: Any)
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
    @IBOutlet var userTFr: UITextField!
    @IBOutlet var nameTFr: UITextField!
    @IBOutlet var subnameTFr: UITextField!
    @IBOutlet var descripcionTFr: UITextField!
    var myDictionary: [String: Any] = [:]
    
    @IBAction func registerBTr(_ sender: Any)
    {
        let imgString = editarIMG.image?.pngData()?.base64EncodedString()
        if emailTFr.text != nil && passTFr.text == passx2TFr.text && userTFr.text != nil && nameTFr.text != nil && subnameTFr.text != nil && descripcionTFr.text != nil
        {
            peticionRegister(emailTFr: emailTFr.text!, passTFr: passTFr.text!, passx2TFr: passx2TFr.text!, userTFr: userTFr.text!, nameTFr: nameTFr.text!, subnameTFr: subnameTFr.text!, descripcionTFr: descripcionTFr.text!, imgString: imgString!)// NO ESTOY SEGURO DE LA IMG si esta bien puesta
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
        self.editarIMG.layer.cornerRadius = 55
        self.editarIMG.clipsToBounds = true
        self.descripcionTFr.layer.cornerRadius = 10
        self.descripcionTFr.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
        
    func peticionRegister(emailTFr: String, passTFr: String, passx2TFr: String, userTFr: String, nameTFr: String, subnameTFr: String, descripcionTFr: String, imgString: String)
    {
        let imgString1 = editarIMG.image?.pngData()?.base64EncodedString()
        let imgString = "data:image/jpg;base64,\(String(describing: imgString1))"
        let Url = String(format: "http://35.181.160.138/proyectos/thunder22/public/api/usuarios")
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyData = "correo=\(emailTFr)&password=\(passTFr)&nick=\(userTFr)&nombre=\(nameTFr)&apellidos=\(subnameTFr)&descripcion=\(descripcionTFr)&foto_url=\(String(describing: imgString))"
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response
            {
                print(response)
            }
            if let data = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async
                    {
                        self.myDictionary = json as! [String: Any]
                        if self.myDictionary["error"] as? String == nil
                        {
//                            let alert = UIAlertController(title: "LLego el momento...", message: "Registro completado con éxito", preferredStyle: .alert)
//                            let action = UIAlertAction(title: "Entendido", style: .default, handler: nil)
//                            alert.addAction(action)
//                            self.present(alert, animated: true, completion: nil)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Loginid") as! LoginController
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
