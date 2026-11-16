import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var lblBienvenida: UILabel!
    @IBOutlet weak var imgProductos: UIImageView!
    @IBOutlet weak var imgCerrarSesion: UIImageView!
    @IBOutlet weak var imgClientes: UIImageView!
    @IBOutlet weak var imgAlmacen: UIImageView!
    @IBOutlet weak var imgVentas: UIImageView!
    @IBOutlet weak var imgEmpleados: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        let usuario = UserDefaults.standard.string(forKey: "usuarioLogueado") ?? ""
        


        lblBienvenida.text = "Hola \(usuario)  Bienvenido al sistema de gestión"
        lblBienvenida.numberOfLines = 0
        lblBienvenida.lineBreakMode = .byWordWrapping


        
        imgProductos.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(irAProductos))
        imgProductos.addGestureRecognizer(tap)
        
        imgClientes.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(irAClientes))
        imgClientes.addGestureRecognizer(tap1)
        
        imgAlmacen.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(irAlmacen))
        imgAlmacen.addGestureRecognizer(tap2)
        
        imgEmpleados.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(irAEmpleados))
        imgEmpleados.addGestureRecognizer(tap3)
        
        imgVentas.isUserInteractionEnabled = true
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(irAVentas))
        imgVentas.addGestureRecognizer(tap4)
        
        imgCerrarSesion.isUserInteractionEnabled = true
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(cerrarSesion))
        imgCerrarSesion.addGestureRecognizer(tap5)
    
        
    }
    
    @objc func irAProductos() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "Listado")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
    }
    
    @objc func irAClientes() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "cliente")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
    }
    
    @objc func irAlmacen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateViewController(identifier: "Almacen")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
    }
    
    @objc func irAEmpleados() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "empleado")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
    }
    
    @objc func irAVentas() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "ventas")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
    }
                                          
                                          
    @objc func cerrarSesion() {
        let alerta = UIAlertController(
            title:"Cierre de sesión",
            message: "¿Seguro quieres salir?",
            preferredStyle: .alert
        )

        alerta.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alerta.addAction(UIAlertAction(title: "Sí", style: .destructive, handler: { _ in
            self.Salir()
        }))

        present(alerta, animated: true)
    }

    
    func Salir(){
        UserDefaults.standard.set(false, forKey: "estaLogueado")
        UserDefaults.standard.removeObject(forKey: "usuarioLogueado")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(identifier: "Login")

        viewController.modalPresentationStyle = .fullScreen

        present(viewController, animated: true)
    }
    
    

    
    
}
