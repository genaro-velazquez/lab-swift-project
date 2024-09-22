//
//  LoginViewModel.swift
//  Architecture_MVVM
//
//  Created by Genaro Velazquez on 23/06/24.
//

// PASO II

// Se crean una serie de propiedades en el viewmodel y desde la view crearemos el binding
// de esta manera conectaremos propiedades de viewmodel a la view y de la view al view model

import Foundation
import Combine // framework apple para crear programación reactiva. Crea el binding desde la view, de esta manera podemos escuchar cambios que ocurran en las propiedades de tipo @publish

class LoginViewModel{
    // deade la view tendremos el binding a estas propuedades y aqui podemos aplicar la logica
    @Published var email = ""
    @Published var password = ""
    @Published var isEnabled = false
    @Published var showLoading = false
    @Published var errorMessage = ""

    // Propiedad para poder guardar la referencia cuando nos suscribamos a los valores de estas 2 propiedades
    var cancelabllables = Set<AnyCancellable>()

    let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
        formValidation()
    }
    
    // Susscribir cada vez que haya cambios en las propiedades sink
    func formValidation(){
        
        Publishers.CombineLatest($email, $password)
            .filter { email, password in
                return email.count > 5 && password.count > 5
            }
            .sink { value in
                self.isEnabled = true
        }.store(in: &cancelabllables)
        
        
        /*
        // Implementación propiedad email
        $email
            .filter{ $0.count > 5 }
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.isEnabled = true 
            //print("email:\(value)")
        }.store(in: &cancelabllables)
        // Implementación propiedad email
        $password.sink { value in
            print("password:\(value)")
        }.store(in: &cancelabllables)
        // Cada cambio que hagamos en la view se verá reflejado en el viewmodel
         */
    }
    
    // Para que lo retorne en el hilo principal
    @MainActor
    func userLogin(withEmail email:String, password: String){
        errorMessage = ""
        showLoading = true
        Task{
            do{
                let userModel = try await apiClient.login(withEmail: email, password: password)
            }
            catch let error  as BackendError{
                print(error.localizedDescription)
                errorMessage = error.rawValue
            }
            showLoading = false 
        }
    }
}
