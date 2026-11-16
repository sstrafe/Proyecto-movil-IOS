import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var imgRegresar: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
        
    }
    
    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Login")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func registrarBtn(_ sender: UIButton) {

        let email = emailTF.text ?? ""
        let pass = passwordTF.text ?? ""
        let pass2 = confirmPasswordTF.text ?? ""

        // Validar campos vacíos
        if email.isEmpty || pass.isEmpty || pass2.isEmpty {
            mostrarAlerta("No dejes campos vacíos")
            return
        }

        // Validar contraseñas coincidan
        if pass != pass2 {
            mostrarAlerta("Las contraseñas no coinciden")
            return
        }

        // Obtener usuarios guardados
        var usuarios = UserDefaults.standard.dictionary(forKey: "usuariosRegistrados") as? [String:String] ?? [:]

        // Verificar si ya existe el usuario
        if usuarios[email] != nil {
            mostrarAlerta("Este usuario ya existe")
            return
        }

        // Guardar nuevo usuario
        usuarios[email] = pass
        UserDefaults.standard.set(usuarios, forKey: "usuariosRegistrados")

        // Mostrar alerta de éxito y regresar al Login
        mostrarAlerta("Registro exitoso. Ahora puedes iniciar sesión.", volverLogin: true)
    }

    // Función para mostrar alertas
    func mostrarAlerta(_ mensaje: String, volverLogin: Bool = false) {
        let alert = UIAlertController(title: "Registro", message: mensaje, preferredStyle: .alert)
        
        // Si volverLogin es true, al pulsar OK se cierra el RegisterVC
        if volverLogin {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true) // Regresa al Login
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        present(alert, animated: true)
    }
}
