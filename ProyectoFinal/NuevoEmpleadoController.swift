import UIKit
import CoreData

class NuevoEmpleadoViewController: UIViewController {

    @IBOutlet weak var nombresTF: UITextField!
    @IBOutlet weak var apellidoTF: UITextField!
    @IBOutlet weak var rolTF: UITextField!
    @IBOutlet weak var imgRegresar: UIImageView!
    @IBOutlet weak var tituloLBL: UILabel!
    @IBOutlet weak var guardarBtn: UIButton!

    var empleadoEditar: Empleado?

    let roles = ["Administrador", "Supervisor", "Empleado"]

    override func viewDidLoad() {
        super.viewDidLoad()

        configurarRolDialogo()

        if let emp = empleadoEditar {
            tituloLBL.text = "Editar Empleado"
            guardarBtn.setTitle("Actualizar", for: .normal)

            nombresTF.text = emp.nombre
            apellidoTF.text = emp.apellido
            rolTF.text = emp.rol
        }
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
    }

    
    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "empleado")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: Configurar diálogo para Rol
    func configurarRolDialogo() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(mostrarRolOpciones))
        rolTF.addGestureRecognizer(tapGesture)
        rolTF.isUserInteractionEnabled = true
        rolTF.tintColor = .clear      // oculta cursor
        rolTF.inputView = UIView()    // evita teclado
    }

    
    
    
    // MARK: ActionSheet
    @objc func mostrarRolOpciones() {
        let actionSheet = UIAlertController(
            title: "Selecciona un Rol",
            message: nil,
            preferredStyle: .actionSheet
        )

        for rol in roles {
            actionSheet.addAction(
                UIAlertAction(title: rol, style: .default) { _ in
                    self.rolTF.text = rol
                }
            )
        }

        actionSheet.addAction(
            UIAlertAction(title: "Cancelar", style: .cancel)
        )

        present(actionSheet, animated: true)
    }

    // MARK: Guardar
    @IBAction func guardarEmpleado(_ sender: UIButton) {

        guard let nombre = nombresTF.text, !nombre.isEmpty,
              let apellido = apellidoTF.text, !apellido.isEmpty,
              let rol = rolTF.text, !rol.isEmpty else {
            mostrarError("Completa todos los campos")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate)
                        .persistentContainer.viewContext

        if let editar = empleadoEditar {
            editar.nombre = nombre
            editar.apellido = apellido
            editar.rol = rol
        } else {
            let empleado = Empleado(context: context)
            empleado.codigo = generarCodigoEmpleado()
            empleado.nombre = nombre
            empleado.apellido = apellido
            empleado.rol = rol
        }

        do {
            try context.save()
            confirmacion()
        } catch {
            print("Error al guardar empleado:", error)
        }
    }

    func generarCodigoEmpleado() -> String {
        return "EMP-\(UUID().uuidString.prefix(3))"
    }

    // MARK: Alertas
    func confirmacion() {
        let alerta = UIAlertController(
            title: "Empleado",
            message: "Guardado correctamente",
            preferredStyle: .alert
        )

        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })

        present(alerta, animated: true)
    }

    func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(
            title: "Error",
            message: mensaje,
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }
}
