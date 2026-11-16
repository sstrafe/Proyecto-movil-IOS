import UIKit
import CoreData

class ClientesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listaClienteTV: UITableView!
    @IBOutlet weak var imgRegresar: UIImageView!
    
    var clientes: [Cliente] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listaClienteTV.delegate = self
        listaClienteTV.dataSource = self
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarDataClientes()
    }
    
    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Home")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func cargarDataClientes() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "nombre", ascending: true)
        ]
        
        do {
            clientes = try context.fetch(request)
            listaClienteTV.reloadData()
        } catch {
            print("Error al cargar datos de clientes")
        }
    }
    
    // MARK: TableView - Número de filas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientes.count
    }
    
    // MARK: TableView - Celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! ClienteCelda
        
        let cliente = clientes[indexPath.row]
        celda.lblNombre.text =
        "\(cliente.nombre ?? "") \(cliente.apellido ?? "")"
        celda.lblCodigo.text = cliente.codigo
        celda.lblTelefono.text = cliente.telefono
        
        return celda
    }
    
    // MARK: TableView - Selección
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cliente = clientes[indexPath.row]
        IraEditar(cliente)
    }
    
    // MARK: Botón para nuevo cliente
    @IBAction func nuevoCliente(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let registroVC = storyBoard.instantiateViewController(identifier: "agregarCliente")
        registroVC.modalPresentationStyle = .fullScreen
        present(registroVC, animated: true)
    }
    
    // MARK: Ir a editar cliente
    func IraEditar(_ cliente: Cliente) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let regEditVC = storyBoard.instantiateViewController(identifier: "agregarCliente") as! NuevoClienteViewController
        
        regEditVC.clienteEditar = cliente
        regEditVC.modalPresentationStyle = .fullScreen
        present(regEditVC, animated: true)
    }
    
    // MARK: Eliminar cliente
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(clientes[indexPath.row])
            
            do {
                try context.save()
                clientes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error al eliminar cliente")
            }
        }
    }
}


