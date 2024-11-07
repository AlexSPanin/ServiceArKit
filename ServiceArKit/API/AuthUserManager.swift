//
//  AuthUserManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging

/// Перечисление ошибок для работы с сетью
enum NetworkError: Error {
    case error(String)
    case errorLogin, errorPassword, errorEmail, errorAccaunt, errorAuth, errorDelete
    
    var label: String {
        switch self {
        case .error(let string): return "Ошибка:\nКод ошибки \(string)"
        case .errorLogin: return "Ошибка авторизации:\nЛогин не существует"
        case .errorPassword: return "Ошибка авторизации:\nНе корректный пароль"
        case .errorEmail: return "Ошибка ввода email:\nНеправильный почтовый адрес"
        case .errorAccaunt: return "Ошибка регистрации:\nАккаунт уже существует."
        case .errorAuth: return "Ошибка аутентификации.\nНеверный логин или пароль."
        case .errorDelete: return "Ошибка при удалении."
        }
    }
}

class AuthUserManager: ObservableObject {
    static let shared = AuthUserManager()
    private let isPrint: Bool = false
    private init() {}

    /// Запрос на получение токена  устройства для сообщений
    /// - Parameter completion: опциональный токен
    func currentToken(completion: @escaping (String?) -> Void) {
        printMessage("Начало получения токена FCM для пользователя", isPrint: self.isPrint)
        Messaging.messaging().token { token, error in
            guard let error = error else { return completion(token) }
            printMessage("Ошибка получения токена \(error.localizedDescription)")
            completion(nil)
        }
    }

    /// Проверка наличия авторизации пользователя, при отсутствии анонимная авторизация
    /// - Parameter completion: id текущего пользователя
    func updateUserSession(completion: @escaping (String?) -> Void) {
        if  let id = Auth.auth().currentUser?.uid {
            completion(id)
        } else {
            self.registerAnon { id in completion(id) }
        }
    }
    
    /// Анонимная регистрация для не зарегистрированных пользователей
    func registerAnon(completion: @escaping (String?) -> Void) {
        Auth.auth().signInAnonymously { result, error in completion(result?.user.uid)  }
    }
    
    /// Получение uuid текущего пользователя
    /// - Returns: uuid текущего пользователя
    func currentUserID() -> String? { Auth.auth().currentUser?.uid }
    
    /// Получение email текущего пользователя
    /// - Returns: email текущего пользователя
    func currentUserEmail() -> String? { Auth.auth().currentUser?.email }
    
    /// Регистрация пользователя по паролю
    /// - Parameters:
    ///   - email: email
    ///   - password: пароль
    ///   - completion: id пользователя (либо ошибка), признак ошибки
    func registrationPassword(email: String, password: String, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        printMessage("AuthUserViewModel: Регистрация по паролю \(email)", isPrint: self.isPrint)
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let error = error else { return  completion(.success(result?.user.uid)) }
            switch error._code {
            case 17007: completion(.failure(.errorAccaunt))
            default: completion(.failure(.error(String(error._code))))
            }
        }
    }
    
    /// Вход по паролю
    /// - Parameters:
    ///   - email: email
    ///   - password: пароль
    ///   - completion: Текст ошибки, признак ошибки
    func login(email: String, password: String, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        printMessage("AuthUserViewModel: Вход по паролю", isPrint: self.isPrint)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard let error = error else { return completion(.success(result?.user.uid)) }
            switch error._code {
            case 17008: completion(.failure(.errorEmail))
            case 17009: completion(.failure(.errorPassword))
            case 17011: completion(.failure(.errorLogin))
            default: completion(.failure(.error(String(error._code))))
            }
        }
    }

    /// Отправка ссылки на восстановление пароля
    /// - Parameters:
    ///   - email: email
    ///   - completion: Текст ошибки, признак ошибки
    func sendLinkForPasswordReset(with email: String, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        printMessage("AuthUserViewModel: Отправка ссылки на восстановление", isPrint: self.isPrint)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard let error = error else { return completion(.success("Проверьте свой почтовый ящик.")) }
            completion(.failure(.error(String(error._code))))
        }
    }
    
    /// выход из учетной записи
    /// - Parameter completion: Текст ошибки, признак ошибки
    func exitingUser(completion: @escaping(String?) -> Void) {
        printMessage("AuthUserViewModel: Выход из учетной записи", isPrint: self.isPrint)
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion("Ошибка выхода из системы")
        }
    }
    
    /// удаление пользователя по подтверждению пароля и логина
    /// - Parameters:
    ///   - email: email
    ///   - password: пароль
    ///   - completion: Текст ошибки, признак ошибки
    func deleteUser(email: String, password: String, completion: @escaping (Result<String?, NetworkError>) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential) { _, reAuth in
            if let reAuth = reAuth {
                switch reAuth._code {
                case 17009: completion(.failure(.errorPassword))
                case 17024: completion(.failure(.errorAuth))
                default: completion(.failure(.error(String(reAuth._code))))
                }
            } else {
                user?.delete { error in
                    if error != nil { completion(.failure(.errorDelete)) }
                    completion(.success(nil))
                }
            }
        }
    }
}
    


