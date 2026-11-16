import UIKit
import CoreData

class AlmacenViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var tablaAlmacen: UITableView!
    @IBOutlet weak var imgRegresar: UIImageView!

    // MARK: - Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    // MARK: - Data
    var lotes: [Lote] = []
    var campoFechaActivo: UITextField?

    lazy var mostrarFecha: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaAlmacen.delegate = self
        tablaAlmacen.dataSource = self
        configurarRegresar()
        cargarLotes()
    }

    // MARK: - Regresar
    func configurarRegresar() {
        imgRegresar.isUserInteractionEnabled = true
        imgRegresar.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(irRegresar)
            )
        )
    }

    @objc func irRegresar() {
        dismiss(animated: true)
    }

    // MARK: - Cargar Lotes
    func cargarLotes() {
        let request: NSFetchRequest<Lote> = Lote.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "fechaFabricacion", ascending: false)
        ]

        lotes = (try? context.fetch(request)) ?? []
        tablaAlmacen.reloadData()
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        lotes.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "celdaAlmacen",
            for: indexPath
        )

        let l = lotes[indexPath.row]

        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        cell.textLabel?.text = """
        Lote: \(l.codigo ?? "")
        Producto: \(l.producto?.nombre ?? "")
        Cantidad: \(l.cantidad)
        """

        cell.detailTextLabel?.text = """
        Fabricación: \(mostrarFecha.string(from: l.fechaFabricacion ?? Date()))
        Caducidad: \(mostrarFecha.string(from: l.fechaCaducidad ?? Date()))
        Precio Unitario: $\(String(format: "%.2f", l.precioUnitario))
        Precio Total: $\(String(format: "%.2f", l.precioTotal))
        """

        return cell
    }

    // MARK: - Seleccionar (Editar)
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editarLote(lotes[indexPath.row])
    }

    // MARK: - Eliminar
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            context.delete(lotes[indexPath.row])
            try? context.save()
            cargarLotes()
        }
    }

    // MARK: - Agregar Lote
    @IBAction func agregarLote(_ sender: UIButton) {

        let alert = UIAlertController(
            title: "Nuevo Lote",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { $0.placeholder = "Nombre producto" }
        alert.addTextField { $0.placeholder = "Descripción" }

        alert.addTextField {
            $0.text = self.generarCodigoLote()
            $0.isEnabled = false
        }

        alert.addTextField {
            $0.placeholder = "Cantidad"
            $0.keyboardType = .numberPad
        }

        alert.addTextField {
            $0.placeholder = "Precio total"
            $0.keyboardType = .decimalPad
        }

        alert.addTextField {
            $0.placeholder = "Fecha fabricación"
            self.configurarDatePicker(para: $0)
        }

        alert.addTextField {
            $0.placeholder = "Fecha caducidad"
            self.configurarDatePicker(para: $0)
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in

            let nombre = alert.textFields![0].text ?? ""
            let descripcion = alert.textFields![1].text ?? ""
            let codigo = alert.textFields![2].text ?? ""
            let cantidad = Int32(alert.textFields![3].text ?? "") ?? 0
            let total = Double(alert.textFields![4].text ?? "") ?? 0

            guard cantidad > 0 else { return }

            let fechaFab = (alert.textFields![5].inputView as? UIDatePicker)?.date ?? Date()
            let fechaCad = (alert.textFields![6].inputView as? UIDatePicker)?.date ?? Date()

            let unitario = total / Double(cantidad)

            let producto = Producto(context: self.context)
            producto.nombre = nombre
            producto.descripcion = descripcion
            producto.precio = unitario

            let lote = Lote(context: self.context)
            lote.codigo = codigo
            lote.cantidad = cantidad
            lote.precioTotal = total
            lote.precioUnitario = unitario
            lote.fechaFabricacion = fechaFab
            lote.fechaCaducidad = fechaCad
            lote.producto = producto

            try? self.context.save()
            self.cargarLotes()
        })

        present(alert, animated: true)
    }

    // MARK: - Editar Lote
    func editarLote(_ lote: Lote) {

        let alert = UIAlertController(
            title: "Editar Lote",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { $0.text = lote.producto?.nombre }
        alert.addTextField { $0.text = lote.producto?.descripcion }

        alert.addTextField {
            $0.text = lote.codigo
            $0.isEnabled = false
            $0.textColor = .secondaryLabel
        }

        alert.addTextField {
            $0.text = "\(lote.cantidad)"
            $0.keyboardType = .numberPad
        }

        alert.addTextField {
            $0.text = "\(lote.precioTotal)"
            $0.keyboardType = .decimalPad
        }

        alert.addTextField {
            $0.placeholder = "Fecha fabricación"
            $0.text = self.mostrarFecha.string(from: lote.fechaFabricacion ?? Date())
            self.configurarDatePicker(para: $0)
            ($0.inputView as? UIDatePicker)?.date = lote.fechaFabricacion ?? Date()
        }

        alert.addTextField {
            $0.placeholder = "Fecha caducidad"
            $0.text = self.mostrarFecha.string(from: lote.fechaCaducidad ?? Date())
            self.configurarDatePicker(para: $0)
            ($0.inputView as? UIDatePicker)?.date = lote.fechaCaducidad ?? Date()
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in

            let cantidad = Int32(alert.textFields![3].text ?? "") ?? 0
            let total = Double(alert.textFields![4].text ?? "") ?? 0

            guard cantidad > 0 else { return }

            lote.producto?.nombre = alert.textFields![0].text
            lote.producto?.descripcion = alert.textFields![1].text

            lote.cantidad = cantidad
            lote.precioTotal = total
            lote.precioUnitario = total / Double(cantidad)

            lote.fechaFabricacion =
                (alert.textFields![5].inputView as? UIDatePicker)?.date
            lote.fechaCaducidad =
                (alert.textFields![6].inputView as? UIDatePicker)?.date

            try? self.context.save()
            self.cargarLotes()
        })

        present(alert, animated: true)
    }

    // MARK: - DatePicker
    func configurarDatePicker(para textField: UITextField) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        textField.inputView = picker

        picker.addTarget(self,
                         action: #selector(fechaCambiada(_:)),
                         for: .valueChanged)
    }

    @objc func fechaCambiada(_ sender: UIDatePicker) {
        campoFechaActivo?.text = mostrarFecha.string(from: sender.date)
    }

    // MARK: - Código automático
    func generarCodigoLote() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let rnd = String((0..<3).map { _ in chars.randomElement()! })
        return "LOT-\(rnd)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarLotes()
    }

}

