//
//  ViewController.swift
//  Architecture_MVVM
//
//  Created by Genaro Velazquez on 23/06/24.
//

// PASO III
// View si tiene referencia a View Model pero el ViewModel no tiene referencia a la View

import UIKit
import Combine

class LoginView: UIViewController {
    // Referencia a nuestro vieModel
    private let loginViewModel = LoginViewModel(apiClient: ApiClient())
    
    var cancellables = Set<AnyCancellable>()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add Email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true 
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Login"
        configuration.subtitle = "!Suscribete a SwiftBeta"
        configuration.image = UIImage(systemName: "play.circle.fill")
        configuration.imagePadding = 8
        
        let button = UIButton(type: .system, primaryAction: UIAction(handler:{ [weak self] action in
            self?.startLogin()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        return button
                              
    }()
    
    private let errorLabel:UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.textColor = .red
        label.font = .systemFont(ofSize: 20, weight: .regular, width: .condensed)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createBindingViewWithViewModel()
        
        [emailTextField, passwordTextField, loginButton, errorLabel].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordTextField.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }

    private func startLogin(){
        loginViewModel.userLogin(withEmail: emailTextField.text?.lowercased() ?? "",
                                 password: passwordTextField.text?.lowercased() ?? "")
    }

    func createBindingViewWithViewModel(){
        // conectar emailTextField con la propiedad email del viewmodel
        // Cuando trabajamos con Combina debemos guardar una referencia en un tipo llamado AnyCancellable
        emailTextField.textPublisher.assign(to: \LoginViewModel.email, on: loginViewModel).store(in: &cancellables)
        passwordTextField.textPublisher.assign(to: \LoginViewModel.password, on: loginViewModel).store(in: &cancellables)
            
        // LO queremos bindear con uIButton
        // Conectar isEnabled de login view model con la view login button con la propiedad isEnabled
        loginViewModel.$isEnabled.assign(to: \.isEnabled, on: loginButton).store(in: &cancellables)
        
        loginViewModel.$showLoading.assign(to: \.configuration!.showsActivityIndicator, on: loginButton).store(in: &cancellables)
        
        loginViewModel.$errorMessage.assign(to: \UILabel.text!, on: errorLabel)
            .store(in: &cancellables)
    }
}

// para poder detectar cambios cada vez que añadamos texto nuevo en el textfield
extension UITextField{
    // propiedad
    //nuestro nuevo publisher publicará un tipo string y que nunca retornará un error
    var textPublisher: AnyPublisher<String, Never>{
        // Para poder detectar cuando estamos añadiendo un uevo texto a un texfield utilizamos notification center
        return NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
        // cada vez que obtenemos un valor hacemos un map
            .map { notification in
                // return del texto que nos llega de esta notificacion y lo vamos a extraer
                return (notification.object as? UITextField)?.text ?? ""
            }
            .eraseToAnyPublisher() // Publica una notificación cada vez que se cambia el valor del uitextfleid
    }
}
