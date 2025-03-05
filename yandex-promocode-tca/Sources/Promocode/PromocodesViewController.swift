//
//  PromocodesViewController.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 04.03.2025.
//

import Combine
import UIKit
import ComposableArchitecture
import PinLayout

class PromocodesViewController: UIViewController {
    // MARK: DI
    private let state = PromocodeState(promocodes: [], selectedPromocode: nil)
    private let environment = Environment(getPromocodes: PromocodeServiceMock().getPromocodes)
    private lazy var reducer = PromocodeReducer(env: environment)
    private lazy var store: Store<PromocodeState, PromocodeAction> = Store(initialState: state, reducer: { reducer })
    
    // MARK: Internal
    var props: Props = .empty
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: Public
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleLabel, promocodeLabel, leftButton, rightButton, shareButton].forEach { view.addSubview($0) }
        render(props)
        store.send(.internalAction(.getPromocodes))
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private let titleLabel = UILabel()
    private let promocodeLabel = UILabel()
    private let leftButton = UIButton()
    private let rightButton = UIButton()
    private let shareButton = UIButton(type: .roundedRect)
    
    private func commonInit() {
        let cancellable = store.publisher.receive(on: DispatchQueue.main)
            .map {
                let promocodes = $0.promocodes
                let props: Props = .init(title: "Поделись промокодом с другом!",
                                         promocodes: promocodes.map { $0.promocode },
                                         selectedPromocode: $0.selectedPromocode?.promocode,
                                         leftButtonIconSystemName: "chevron.left.circle.fill",
                                         rightButtonIconSystemName: "chevron.right.circle.fill",
                                         shareButtonTitle: "Поделиться")
                return props
            }
            .removeDuplicates()
            .sink { [weak self] props in
                self?.render(props)
            }
        cancellables.insert(cancellable)
    }
    
    private func render(_ props: Props) {
        defer { self.props = props }
        let s = props.style
        
        view.backgroundColor = s.backgroundColor
        promocodeLabel.text = props.selectedPromocode
        
        titleLabel.text = props.title
        titleLabel.textAlignment = s.titleTextAligment
        
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
        
        view.setNeedsLayout()
    }
    
    private func layout() {
        let m = props.metrics
        
        titleLabel.pin
            .top(m.titleVMargin)
            .horizontally(m.margins)
            .sizeToFit(.width)
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
        store.send(.viewAction(.changePromocode(.left)))
    }
    
    @objc private func onRightTapped() {
        store.send(.viewAction(.changePromocode(.right)))
    }
    
    @objc private func onShareTapped() {
        guard let selectedPromocode = props.selectedPromocode else { return }
        let items = [selectedPromocode]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(controller, animated: true)
    }
}


extension PromocodesViewController {
    struct Props: Equatable {
        let title: String
        let promocodes: [String]
        var selectedPromocode: String?
        let leftButtonIconSystemName: String
        let rightButtonIconSystemName: String
        let shareButtonTitle: String
        
        let style: Style
        let metrics: Metrics
        
        init(title: String, promocodes: [String], selectedPromocode: String?, leftButtonIconSystemName: String, rightButtonIconSystemName: String, shareButtonTitle: String, style: Style = .default, metrics: Metrics = .default) {
            self.title = title
            self.promocodes = promocodes
            self.selectedPromocode = selectedPromocode
            self.leftButtonIconSystemName = leftButtonIconSystemName
            self.rightButtonIconSystemName = rightButtonIconSystemName
            self.shareButtonTitle = shareButtonTitle
            self.style = style
            self.metrics = metrics
        }
        
        struct Metrics: Equatable {
            let margins: CGFloat
            let titleVMargin: CGFloat
            let shareButtonCornerRadius: CGFloat
            let sideButtonSize: CGFloat
            
            static let `default`: Self = .init(margins: 16,
                                               titleVMargin: 48,
                                               shareButtonCornerRadius: 4,
                                               sideButtonSize: 32)
        }
        
        struct Style: Equatable {
            let titleTextAligment: NSTextAlignment
            let backgroundColor: UIColor
            let shareButtonTitleColor: UIColor
            let shareButtonBackgroundColor: UIColor
            let sideButtonTintColor: UIColor
            
            static let `default`: Self = .init(titleTextAligment: .center,
                                               backgroundColor: .white,
                                               shareButtonTitleColor: .black,
                                               shareButtonBackgroundColor: UIColor(white: 0.95, alpha: 1.0),
                                               sideButtonTintColor: .lightGray)
        }
        
        static let empty: Self = .init(title: "",
                                       promocodes: [],
                                       selectedPromocode: "",
                                       leftButtonIconSystemName: "",
                                       rightButtonIconSystemName: "",
                                       shareButtonTitle: "")
    }
}
