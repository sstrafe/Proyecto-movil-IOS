import UIKit
import CoreData

struct ProductoVenta {
    var producto: Producto
    var cantidad: Int
}

class NuevoVentasViewController: UIViewController,
                                 UITableViewDelegate,
                                 UITableViewDataSource,
                                 UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var txtEmpleado: UITextField!
    @IBOutlet weak var txtCliente: UITextField!
    @IBOutlet weak var tablaProductos: UITableView!
    @IBOutlet weak var imgRegresar: UIImageView!
    
    // MARK: - Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    // MARK: - Variables
    var ventaEditar: Venta?
    var empleadoSeleccionado: Empleado?
    var clienteSeleccionado: Cliente?
    var productosVenta: [ProductoVenta] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tablaProductos.delegate = self
        tablaProductos.dataSource = self

        txtEmpleado.delegate = self
        txtCliente.delegate = self

        txtEmpleado.placeholder = "Seleccionar empleado"
        txtCliente.placeholder = "Seleccionar cliente"

        if let venta = ventaEditar {
            cargarVentaParaEditar(venta)
        }
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
    }
    
    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ventas")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    // MARK: - Cargar venta para editar
    func cargarVentaParaEditar(_ venta: Venta) {

        empleadoSeleccionado = venta.empleado
        clienteSeleccionado = venta.cliente

        txtEmpleado.text = venta.empleado?.nombre
        txtCliente.text = venta.cliente?.nombre

        productosVenta.removeAll()

        if let detalles = venta.detalles as? Set<DetalleVenta> {
            for d in detalles {
                if let producto = d.producto {
                    productosVenta.append(
                        ProductoVenta(
                            producto: producto,
                            cantidad: Int(d.cantidad)
                        )
                    )
                }
            }
        }

        tablaProductos.reloadData()
    }

    // MARK: - TextField tap
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == txtEmpleado {
            comboEmpleados { emp in
                self.empleadoSeleccionado = emp
                self.txtEmpleado.text = emp.nombre
            }
            return false
        }

        if textField == txtCliente {
            comboClientes { cli in
                self.clienteSeleccionado = cli
                self.txtCliente.text = cli.nombre
            }
            return false
        }

        return true
    }

    // MARK: - Agregar producto
    @IBAction func agregarProducto(_ sender: UIButton) {
        comboProductos { producto in
            self.pedirCantidad(producto: producto)
        }
    }

    func pedirCantidad(producto: Producto) {

        let alert = UIAlertController(
            title: producto.nombre,
            message: "Cantidad",
            preferredStyle: .alert
        )

        alert.addTextField {
            $0.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(title: "Agregar", style: .default) { _ in
            if let texto = alert.textFields?.first?.text,
               let cantidad = Int(texto),
               cantidad > 0 {

                self.productosVenta.append(
                    ProductoVenta(producto: producto, cantidad: cantidad)
                )
                self.tablaProductos.reloadData()
            }
        })

        present(alert, animated: true)
    }

    // MARK: - TableView Productos
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        productosVenta.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "celdaProductoVenta",
            for: indexPath
        )

        let item = productosVenta[indexPath.row]

        cell.textLabel?.text = item.producto.nombre
        cell.detailTextLabel?.text = "Cantidad: \(item.cantidad)"

        return cell
    }

    // Editar cantidad
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let item = productosVenta[indexPath.row]

        let alert = UIAlertController(
            title: item.producto.nombre,
            message: "Editar cantidad",
            preferredStyle: .alert
        )

        alert.addTextField {
            $0.keyboardType = .numberPad
            $0.text = "\(item.cantidad)"
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
            if let txt = alert.textFields?.first?.text,
               let cant = Int(txt),
               cant > 0 {

                self.productosVenta[indexPath.row].cantidad = cant
                self.tablaProductos.reloadData()
            }
        })

        present(alert, animated: true)
    }

    // Eliminar producto swipe
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            productosVenta.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Guardar venta
    @IBAction func guardarVenta(_ sender: UIButton) {

        guard let empleado = empleadoSeleccionado,
              let cliente = clienteSeleccionado,
              !productosVenta.isEmpty else { return }

        let venta = ventaEditar ?? Venta(context: context)

        venta.empleado = empleado
        venta.cliente = cliente
        venta.fecha = Date()

        
        if let detalles = venta.detalles as? Set<DetalleVenta> {
            detalles.forEach { context.delete($0) }
        }

        var total: Double = 0

        for item in productosVenta {

            let detalle = DetalleVenta(context: context)
            detalle.producto = item.producto
            detalle.cantidad = Int16(item.cantidad)
            detalle.precio = item.producto.precio
            detalle.venta = venta

            descontarStock(
                producto: item.producto,
                cantidadVendida: item.cantidad
            )

            total += item.producto.precio * Double(item.cantidad)
        }

        venta.total = total

        try? context.save()
        dismiss(animated: true)
    }

    // MARK: - Combos
    func comboEmpleados(completion: @escaping (Empleado) -> Void) {
        let empleados = try? context.fetch(Empleado.fetchRequest())
        let sheet = UIAlertController(title: "Empleados", message: nil, preferredStyle: .actionSheet)

        empleados?.forEach { e in
            sheet.addAction(UIAlertAction(title: e.nombre ?? "", style: .default) { _ in
                completion(e)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(sheet, animated: true)
    }

    func comboClientes(completion: @escaping (Cliente) -> Void) {
        let clientes = try? context.fetch(Cliente.fetchRequest())
        let sheet = UIAlertController(title: "Clientes", message: nil, preferredStyle: .actionSheet)

        clientes?.forEach { c in
            sheet.addAction(UIAlertAction(title: c.nombre ?? "", style: .default) { _ in
                completion(c)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(sheet, animated: true)
    }

    func comboProductos(completion: @escaping (Producto) -> Void) {
        let productos = try? context.fetch(Producto.fetchRequest())
        let sheet = UIAlertController(title: "Productos", message: nil, preferredStyle: .actionSheet)

        productos?.forEach { p in
            sheet.addAction(UIAlertAction(
                title: "\(p.nombre ?? "") - $\(p.precio)",
                style: .default) { _ in completion(p) }
            )
        }

        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(sheet, animated: true)
    }
    
    func descontarStock(producto: Producto, cantidadVendida: Int) {

        guard let lotes = producto.lotes as? Set<Lote>, !lotes.isEmpty else {
            print("Producto sin lotes")
            return
        }

        let lotesOrdenados = lotes.sorted {
            ($0.fechaFabricacion ?? Date()) < ($1.fechaFabricacion ?? Date())
        }

        var cantidadRestante = cantidadVendida

        for lote in lotesOrdenados {

            if cantidadRestante <= 0 { break }

            let disponible = Int(lote.cantidad)

            if disponible >= cantidadRestante {
                lote.cantidad -= Int32(cantidadRestante)
                cantidadRestante = 0
            } else {
                lote.cantidad = 0
                cantidadRestante -= disponible
            }
        }

        if cantidadRestante > 0 {
            print("Stock insuficiente para \(producto.nombre ?? "")")
        }

        do {
            try context.save()
        } catch {
            print("Error al guardar stock:", error)
        }
    }


}
