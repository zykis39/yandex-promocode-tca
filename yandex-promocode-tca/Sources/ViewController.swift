//
//  ViewController.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 04.03.2025.
//

import UIKit
import PinLayout

class PromocodesViewController: UIViewController {
    var props: Props = .empty {
        didSet {
            render(props)
            view.setNeedsLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: move service outside
        Task { [weak self] in
            let service = PromocodeServiceMock()
            let promocodes = try await service.getPromocodes()
            
            let props: Props = .init(promocodes: promocodes.map { $0.promocode },
                                     selectedPromocode: promocodes.first?.promocode ?? "",
                                     leftButtonIconSystemName: "chevron.left.circle.fill",
                                     rightButtonIconSystemName: "chevron.right.circle.fill",
                                     shareButtonTitle: "Поделиться",
                                     sharePromocode: { _ in },
                                     changePromocode: { [weak self] right in
                guard let self else { return }
                let props = self.props
                guard props.promocodes.count > 0 else { return }
                var promocode = ""
                if right {
                    guard let currentIndex = props.promocodes.firstIndex(of: props.selectedPromocode) else { return }
                    if props.promocodes.count - 1 == currentIndex {
                        promocode = props.promocodes[0]
                    } else {
                        promocode = props.promocodes[currentIndex + 1]
                    }
                } else {
                    guard let currentIndex = props.promocodes.firstIndex(of: props.selectedPromocode) else { return }
                    if currentIndex == 0 {
                        if let last = props.promocodes.last {
                            promocode = last
                        }
                    } else {
                        promocode = props.promocodes[currentIndex - 1]
                    }
                }
                
                self.props.selectedPromocode = promocode
                // FIXME: forcing to re-render
                self.render(self.props)
            })
            self?.props = props
        }
        
        [promocodeLabel, leftButton, rightButton, shareButton].forEach { view.addSubview($0) }
        render(props)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
 
    
    // MARK: Private
    private var promocodeLabel = UILabel()
    private var leftButton = UIButton()
    private var rightButton = UIButton()
    private var shareButton = UIButton(type: .roundedRect)
    
    private func render(_ props: Props) {
        let s = props.style
        
        view.backgroundColor = s.backgroundColor
        promocodeLabel.text = props.selectedPromocode
        
        leftButton.setImage(.init(systemName: props.leftButtonIconSystemName), for: .normal)
        leftButton.contentVerticalAlignment = .fill
        leftButton.contentHorizontalAlignment = .fill
        leftButton.tintColor = s.sideButtonTintColor
        leftButton.addTarget(self, action: #selector(onLeftTapped), for: .touchUpInside)
        
        rightButton.setImage(.init(systemName: props.rightButtonIconSystemName), for: .normal)
        rightButton.contentVerticalAlignment = .fill
        rightButton.contentHorizontalAlignment = .fill
        rightButton.tintColor = s.sideButtonTintColor
        rightButton.addTarget(self, action: #selector(onRightTapped), for: .touchUpInside)
        
        shareButton.setTitle(props.shareButtonTitle, for: .normal)
        shareButton.setTitleColor(s.shareButtonTitleColor, for: .normal)
        shareButton.backgroundColor = s.shareButtonBackgroundColor
        shareButton.addTarget(self, action: #selector(onShareTapped), for: .touchUpInside)
    }
    
    private func layout() {
        let m = props.metrics
        
        promocodeLabel.pin
            .hCenter()
            .vCenter()
            .sizeToFit()
        leftButton.pin
            .vCenter()
            .left(m.margins)
            .size(m.sideButtonSize)
        rightButton.pin
            .vCenter()
            .right(m.margins)
            .size(m.sideButtonSize)
        shareButton.pin
            .bottom(m.margins)
            .horizontally(m.margins)
            .sizeToFit(.width)
        
        shareButton.layer.cornerRadius = m.shareButtonCornerRadius
    }
    
    @objc private func onLeftTapped() {
        props.changePromocode(false)
    }
    
    @objc private func onRightTapped() {
        props.changePromocode(true)
    }
    
    @objc private func onShareTapped() {
        props.sharePromocode(props.selectedPromocode)
    }
}


extension PromocodesViewController {
    struct Props {
        let promocodes: [String]
        var selectedPromocode: String
        let leftButtonIconSystemName: String
        let rightButtonIconSystemName: String
        let shareButtonTitle: String
        
        let sharePromocode: (String) -> Void
        let changePromocode: (Bool) -> Void
        
        let style: Style
        let metrics: Metrics
        
        init(promocodes: [String], selectedPromocode: String, leftButtonIconSystemName: String, rightButtonIconSystemName: String, shareButtonTitle: String, sharePromocode: @escaping (String) -> Void, changePromocode: @escaping (Bool) -> Void, style: Style = .default, metrics: Metrics = .default) {
            self.promocodes = promocodes
            self.selectedPromocode = selectedPromocode
            self.leftButtonIconSystemName = leftButtonIconSystemName
            self.rightButtonIconSystemName = rightButtonIconSystemName
            self.shareButtonTitle = shareButtonTitle
            self.sharePromocode = sharePromocode
            self.changePromocode = changePromocode
            self.style = style
            self.metrics = metrics
        }
        
        struct Metrics: Equatable {
            let margins: CGFloat
            let shareButtonCornerRadius: CGFloat
            let sideButtonSize: CGFloat
            
            static let `default`: Self = .init(margins: 16,
                                               shareButtonCornerRadius: 4,
                                               sideButtonSize: 32)
        }
        struct Style: Equatable {
            let backgroundColor: UIColor
            let shareButtonTitleColor: UIColor
            let shareButtonBackgroundColor: UIColor
            let sideButtonTintColor: UIColor
            
            static let `default`: Self = .init(backgroundColor: .white,
                                               shareButtonTitleColor: .black,
                                               shareButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
                                               sideButtonTintColor: .lightGray)
        }
        
        static let empty: Self = .init(promocodes: [],
                                       selectedPromocode: "",
                                       leftButtonIconSystemName: "",
                                       rightButtonIconSystemName: "",
                                       shareButtonTitle: "",
                                       sharePromocode: { _ in },
                                       changePromocode: { _ in }
        )
    }
}
