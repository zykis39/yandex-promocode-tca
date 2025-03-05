//
//  PromocodeService.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 04.03.2025.
//
import Foundation

struct Promocode: Decodable, Equatable {
    let promocode: String
}

protocol PromocodeService {
    func getPromocodes() async throws -> [Promocode]
}

class PromocodeServiceImplementation: PromocodeService {
    enum PromocodeErrors: Error {
        case badURL
    }
    
    func getPromocodes() async throws -> [Promocode] {
        guard let url = URL(string: "https://yandex.ru/promocodes") else { throw PromocodeErrors.badURL }
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let promocodes = try JSONDecoder().decode([Promocode].self, from: data)
        return promocodes
    }
}

class PromocodeServiceMock: PromocodeService {
    func getPromocodes() async throws -> [Promocode] {
        let promocodes: [Promocode] = [
            .init(promocode: "XCPASDJPD"),
            .init(promocode: "LDJYGMXLW"),
            .init(promocode: "S2lUFKSWD")
        ]
        
        return promocodes
    }
}
