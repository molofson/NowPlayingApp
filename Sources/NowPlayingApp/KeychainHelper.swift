import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()

    func set(string: String?, forKey key: String) {
        if let string = string {
            let data = string.data(using: .utf8)!
            // delete existing
            let queryDelete: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
            SecItemDelete(queryDelete as CFDictionary)
            // add
            let add: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key,
                                     kSecValueData as String: data]
            SecItemAdd(add as CFDictionary, nil)
        } else {
            let queryDelete: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
            SecItemDelete(queryDelete as CFDictionary)
        }
    }

    func string(forKey key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data, let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }

    func delete(key: String) {
        let queryDelete: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
        SecItemDelete(queryDelete as CFDictionary)
    }
}
