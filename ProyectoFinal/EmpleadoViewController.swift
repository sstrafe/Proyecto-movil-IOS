import UIKit
import CoreData

class EmpleadoViewController: UIViewController,
                              UITableViewDelegate,
                              UITableViewDataSource {

    @IBOutlet weak var listaEmpleadoTV: UITableView!

    @IBOutlet weak var imgRegresar: UIImageView!
    
    var empleados: [Empleado] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        listaEmpleadoTV.delegate = self
        listaEmpleadoTV.dataSource = self
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarDataEmpleados()
    }
    
    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Home")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func cargarDataEmpleados() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
                        .persistentContainer.viewContext

        let request: NSFetchRequest<Empleado> = Empleado.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "nombre", ascending: true)
        ]

        do {
            empleados = try context.fetch(request)
            listaEmpleadoTV.reloadData()
        } catch {
            print("Error al cargar empleados:", error)
        }
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return empleados.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let celda = tableView.dequeueReusableCell(
            withIdentifier: "celda",
            for: indexPath
        ) as! EmpleadoCelda

        let empleado = empleados[indexPath.row]

        celda.lblCodigo.text = empleado.codigo
        celda.lblNombre.text =
            "\(empleado.nombre ?? "") \(empleado.apellido ?? "")"
        celda.lblRol.text = empleado.rol

        return celda
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        IraEditar(empleados[indexPath.row])
    }

    @IBAction func nuevoEmpleado(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let registroVC = storyBoard
            .instantiateViewController(identifier: "agregarEmpleado")

        registroVC.modalPresentationStyle = .fullScreen
        present(registroVC, animated: true)
    }

    func IraEditar(_ empleado: Empleado) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let regEditVC = storyBoard
            .instantiateViewController(identifier: "agregarEmpleado")
            as! NuevoEmpleadoViewController

        regEditVC.empleadoEditar = empleado
        regEditVC.modalPresentationStyle = .fullScreen
        present(regEditVC, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let context = (UIApplication.shared.delegate as! AppDelegate)
                            .persistentContainer.viewContext

            context.delete(empleados[indexPath.row])

            do {
                try context.save()
                empleados.remove(at: indexPath.row)
                tableView.deleteRows(
                    at: [indexPath],
                    with: .fade
                )
            } catch {
                print("Error al eliminar empleado:", error)
            }
        }
    }
}
