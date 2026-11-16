import UIKit
import CoreData

class ListadoProductosViewController: UIViewController,
                                      UITableViewDelegate,
                                      UITableViewDataSource,
                                      UISearchBarDelegate {

    @IBOutlet weak var tablaProductos: UITableView!
    @IBOutlet weak var buscador: UISearchBar!
    @IBOutlet weak var imgRegresar: UIImageView!

    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    var productos: [Producto] = []
    var filtrados: [Producto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tablaProductos.delegate = self
        tablaProductos.dataSource = self
        buscador.delegate = self
        configurarRegresar()
        cargarProductos()
    }

    func configurarRegresar() {
        imgRegresar.isUserInteractionEnabled = true
        imgRegresar.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(irRegresar))
        )
    }

    @objc func irRegresar() {
        dismiss(animated: true)
    }

    func cargarProductos() {
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()
        productos = (try? context.fetch(request)) ?? []
        filtrados = productos
        tablaProductos.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        filtrados.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "celdaProducto",
            for: indexPath
        )

        let p = filtrados[indexPath.row]

        cell.textLabel?.text = p.nombre
        cell.detailTextLabel?.text = """
        \(p.descripcion ?? "")
        Precio Unitario: $\(String(format: "%.2f", p.precio))
        """
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }

    // MARK: - BUSCADOR
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange text: String) {
        filtrados = text.isEmpty
            ? productos
            : productos.filter {
                ($0.nombre ?? "")
                    .lowercased()
                    .contains(text.lowercased())
            }
        tablaProductos.reloadData()
    }
}

