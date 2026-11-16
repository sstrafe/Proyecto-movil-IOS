import UIKit
import CoreData

class VentaViewController: UIViewController,
                           UITableViewDelegate,
                           UITableViewDataSource {

    @IBOutlet weak var tablaVentas: UITableView!
    
    @IBOutlet weak var imgRegresar: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext

    var ventas: [Venta] = []

    // MARK: - CICLO DE VIDA
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaVentas.delegate = self
        tablaVentas.dataSource = self
        
        imgRegresar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irRegresar))
        imgRegresar.addGestureRecognizer(tap)
    }

    @objc func irRegresar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Home")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func exportarPDF(_ sender: UIButton) {
        generarPDFVentas()
    }
    func generarPDFVentas() {

        let pageWidth: CGFloat = 595.2   // A4
        let pageHeight: CGFloat = 841.8

        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("Ventas.pdf")

        do {
            try pdfRenderer.writePDF(to: fileURL) { context in

                var y: CGFloat = 20

                context.beginPage()

                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22)
                ]

                "REPORTE DE VENTAS"
                    .draw(at: CGPoint(x: 20, y: y), withAttributes: titleAttributes)

                y += 40

                for venta in ventas {

                    if y > pageHeight - 200 {
                        context.beginPage()
                        y = 20
                    }

                    y = modeloVentaPDF(venta, y: y)
                    y += 20
                }
            }

            mostrarPDF(fileURL)

        } catch {
            print("Error al generar PDF:", error)
        }
    }

    func modeloVentaPDF(_ venta: Venta, y: CGFloat) -> CGFloat {

        var currentY = y

        let bold: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]

        let normal: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12)
        ]

        // FECHA
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let fecha = formatter.string(from: venta.fecha ?? Date())

        "Fecha: \(fecha)"
            .draw(at: CGPoint(x: 20, y: currentY), withAttributes: bold)
        currentY += 18

        // EMPLEADO
        let emp = venta.empleado
        "Empleado: \(emp?.nombre ?? "") \(emp?.apellido ?? "") - Rol: \(emp?.rol ?? "")"
            .draw(at: CGPoint(x: 20, y: currentY), withAttributes: normal)
        currentY += 15

        // CLIENTE
        let cli = venta.cliente
        "Cliente: \(cli?.nombre ?? "") \(cli?.apellido ?? "") - Tel: \(cli?.telefono ?? "")"
            .draw(at: CGPoint(x: 20, y: currentY), withAttributes: normal)
        currentY += 15

        // PRODUCTOS
        "Productos:"
            .draw(at: CGPoint(x: 20, y: currentY), withAttributes: bold)
        currentY += 15

        let request: NSFetchRequest<DetalleVenta> = DetalleVenta.fetchRequest()
        request.predicate = NSPredicate(format: "venta == %@", venta)

        let detalles = (try? context.fetch(request)) ?? []

        for d in detalles {
            let texto =
            "• \(d.producto?.nombre ?? "") | Cant: \(d.cantidad) | Precio: $\(d.precio)"

            texto.draw(at: CGPoint(x: 30, y: currentY), withAttributes: normal)
            currentY += 14
        }

        // TOTAL
        "TOTAL: $\(venta.total)"
            .draw(at: CGPoint(x: 20, y: currentY), withAttributes: bold)

        currentY += 20

        return currentY
    }
    
    func mostrarPDF(_ url: URL) {

        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        present(activityVC, animated: true)
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarVentas()
    }
    

    

    // MARK: - BOTÓN NUEVA VENTA
    @IBAction func nuevaVenta(_ sender: UIButton) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let registroVC = storyBoard
            .instantiateViewController(identifier: "agregarVenta")
            as! NuevoVentasViewController

        registroVC.ventaEditar = nil 
        registroVC.modalPresentationStyle = .fullScreen
        present(registroVC, animated: true)
    }

    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return ventas.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "celdaVenta",
            for: indexPath
        )

        let venta = ventas[indexPath.row]

        let empleado = venta.empleado?.nombre ?? "—"
        let cliente = venta.cliente?.nombre ?? "—"

        // TEXTO PRINCIPAL
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text =
        """
        Empleado: \(empleado)
        Cliente: \(cliente)
        Total: $\(venta.total)
        """

        // LISTADO DE PRODUCTOS
        var productosTexto = "Productos:\n"

        if let detalles = venta.detalles as? Set<DetalleVenta> {
            for d in detalles {
                let nombre = d.producto?.nombre ?? ""
                let cantidad = d.cantidad
                productosTexto += "• \(nombre) x\(cantidad)\n"
            }
        }

        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = productosTexto

        return cell
    }


    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        IraEditar(ventas[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let venta = ventas[indexPath.row]

            if let detalles = venta.detalles as? Set<DetalleVenta> {
                detalles.forEach { context.delete($0) }
            }

            context.delete(venta)

            do {
                try context.save()
                ventas.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error al eliminar venta:", error)
            }
        }
    }

    // MARK: - EDITAR VENTA
    func IraEditar(_ venta: Venta) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let regEditVC = storyBoard
            .instantiateViewController(identifier: "agregarVenta")
            as! NuevoVentasViewController

        regEditVC.ventaEditar = venta   // PASAMOS LA VENTA
        regEditVC.modalPresentationStyle = .fullScreen
        present(regEditVC, animated: true)
    }

    // MARK: - CARGAR DATOS
    func cargarVentas() {

        let request: NSFetchRequest<Venta> = Venta.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "fecha", ascending: false)
        ]

        do {
            ventas = try context.fetch(request)
            tablaVentas.reloadData()
        } catch {
            print("Error al cargar ventas:", error)
        }
    }
}

