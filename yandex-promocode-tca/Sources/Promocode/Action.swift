//
//  Action.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 05.03.2025.
//

enum PromocodeAction {
    enum InternalAction {
        case getPromocodes
        case promocodesChanged([Promocode])
        case selectPromocode(Promocode)
    }
    
    enum ViewAction {
        enum Direction {
            case left
            case right
        }
        
        case changePromocode(Direction)
        case sharePromocode(Promocode)
    }
    
    case internalAction(InternalAction)
    case viewAction(ViewAction)
}
