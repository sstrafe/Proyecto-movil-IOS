import UIKit

class NuevoClienteViewController: UIViewController {

    @IBOutlet weak var nombresTF: UITextField!
    @IBOutlet weak var codigoTF: UITextField!
    @IBOutlet weak var telefonoTF: UITextField!
    @IBOutlet weak var apellidosTF: UITextField!
    @IBOutlet weak var imgRegresar: UIImageView!
    @IBOutlet weak var tituloLBL: UILabel!
    @IBOutlet weak var guardarBtn: UIButton!

    var clienteEditar: Cliente?

    override func viewDidLoad() {
        super.viewDidLoad()

        if clienteEditar != nil {
            tituloLBL.text = "Editar Cliente"
            guardarBtn.setTitle("Actualizar", for: .normal)

            nombresTF.text = clienteEditar?.nombre
            apellidosTF.text = clienteEditar?.apellido
            telefonoTF.text = clienteEditar?.telefono
        }
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
        
    }

    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "cliente")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func guardarCliente(_ sender: UIButton) {
        
        guard let nombres = nombresTF.text, !nombres.isEmpty,
              let apellidos = apellidosTF.text, !apellidos.isEmpty,
              let telefono = telefonoTF.text, !telefono.isEmpty else {
            mostrarError("Completa todos los campos")
            return
        }


        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if let editar = clienteEditar {
            editar.nombre = nombres
            editar.apellido = apellidos
            editar.telefono = telefono
        } else {
            let cliente = Cliente(context: context)
            cliente.nombre = nombres
            cliente.apellido = apellidos
            cliente.codigo = generarCodigoCliente()
            cliente.telefono = telefono
        }

        do {
            try context.save()
            confirmacion()
        } catch {
            print("Error al guardar cliente")
        }
    }


    func generarCodigoCliente() -> String {
        return "CLI-\(UUID().uuidString.prefix(3))"
    }
    func confirmacion() {
        let alerta = UIAlertController(
            title: "Cliente registrado!!!!!",
            message: "Guardado correcto",
            preferredStyle: .alert
        )

        alerta.addAction(
            UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.IrAListaClientes()
            })
        )

        present(alerta, animated: true)
    }

    func IrAListaClientes() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let listadoVC = storyBoard.instantiateViewController(identifier: "cliente")
        listadoVC.modalPresentationStyle = .fullScreen
        present(listadoVC, animated: true)
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

