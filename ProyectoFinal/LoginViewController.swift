import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var usuarioTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    // Vista de carga
    var overlayView: UIView!
    var spinner: UIActivityIndicatorView!
    var lblCargando: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTF.isSecureTextEntry = true
        configurarLoading()
    }

    // MARK: - Configurar Loading
    func configurarLoading() {

        // Fondo oscuro
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.isHidden = true

        // Caja blanca
        let caja = UIView()
        caja.backgroundColor = .white
        caja.layer.cornerRadius = 12
        caja.translatesAutoresizingMaskIntoConstraints = false

        // Spinner grande
        spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .blue
        spinner.startAnimating()

        // Texto
        lblCargando = UILabel()
        lblCargando.text = "Validando datos..."
        lblCargando.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lblCargando.textAlignment = .center

        // Stack
        let stack = UIStackView(arrangedSubviews: [spinner, lblCargando])
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .center

        caja.addSubview(stack)
        overlayView.addSubview(caja)
        view.addSubview(overlayView)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            caja.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            caja.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            caja.widthAnchor.constraint(equalToConstant: 220),
            caja.heightAnchor.constraint(equalToConstant: 150),

            stack.centerXAnchor.constraint(equalTo: caja.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: caja.centerYAnchor)
        ])
    }

    func mostrarLoading() {
        overlayView.isHidden = false
        view.isUserInteractionEnabled = false
    }

    func ocultarLoading() {
        overlayView.isHidden = true
        view.isUserInteractionEnabled = true
    }

    // MARK: - Ingresar
    @IBAction func ingresarBtn(_ sender: UIButton) {

        let email = usuarioTF.text ?? ""
        let password = passwordTF.text ?? ""

        if email.isEmpty || password.isEmpty {
            Alerta("No dejes campos vacíos")
            return
        }

        mostrarLoading()

        // Simular validación
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

            let usuarios = UserDefaults.standard.dictionary(forKey: "usuariosRegistrados") as? [String:String] ?? [:]

            if usuarios[email] == password {

                UserDefaults.standard.set(true, forKey: "estaLogueado")
                UserDefaults.standard.set(email, forKey: "usuarioLogueado")

                self.ocultarLoading()
                self.IrPantallaHome()

            } else {
                self.ocultarLoading()
                self.Alerta("Usuario o contraseña incorrectos")
                self.passwordTF.text = ""
            }
        }
    }

    // MARK: - Home
    func IrPantallaHome() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "Home")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Alertas
    func Alerta(_ mensaje: String) {
        let alerta = UIAlertController(title: "Login", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alerta, animated: true)
    }

    // MARK: - Registro
    @IBAction func Registrar(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "Registro")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
