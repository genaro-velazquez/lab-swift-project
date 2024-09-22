//
//  ApiClient.swift
//  Architecture_MVVM
//
//  Created by Genaro Velazquez on 23/06/24.
//

// PASO I

import Foundation

enum BackendError: String, Error{
    case invalidEmail = "Compruebe el Email"
    case invalidPassword = "Comprueba tu Password"
}

final class ApiClient{
    func login(withEmail email: String, password: String) async throws -> User{  //<- throws = lanzamos errores
        // Simular peticion HTTP y esperar 2 segundos
        // esperar 2 segundos
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        
        return try simulatorBackendLogic(email: email, password: password)
        
    }
}

func simulatorBackendLogic(email: String, password: String) throws -> User{
    guard email == "swiftbeta.blog@gmail.com" else
    {
        print("El user no es SwiftBeta")
        throw BackendError.invalidEmail
    }
    
    guard password == "1234567890" else
    {
        print("La password no es 1234567890")
        throw BackendError.invalidPassword
    }
    
    print("Success")
    
    return .init(name: "SwiftBeta", token: "token_1234567890", sessionStart: .now)
    
}

