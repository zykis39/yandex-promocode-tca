//
//  Environment.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 05.03.2025.
//

struct Environment {
    let getPromocodes: () async throws -> [Promocode]
}
