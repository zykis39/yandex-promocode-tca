//
//  State.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 05.03.2025.
//

struct PromocodeState: Equatable {
    var promocodes: [Promocode]
    var selectedPromocode: Promocode?
}
