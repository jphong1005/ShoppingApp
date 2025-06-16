//
//  ViewModel.swift
//  Shopping-TableView-Binding
//
//  Created by 홍진표 on 6/16/25.
//

import Foundation
import Combine

// MARK: - ViewModel

final class ViewModel {
    
    typealias Input = InputEvent
    typealias Output = OutputEvent
    
    enum InputEvent {
        case viewDidLoad
        case onProductCellEvent(cellEvent: ProductTableViewCellEvent, product: Product)
        case onResetButtonTap
    }
    
    enum OutputEvent {
        case setProducts(products: [Product])
        case updateView(numberOfItemsInCart: Int, totalCost: Int, likedProductIds: Set<Int>, productQuantities: [Int: Int])
    }
    
    //  Model의 상태(데이터)가 변경되면 방출/구독을 통해 이를 감지
    //  -> View(UIView)에 변경 사항을 반영하기 위함
    @Published private var cart: [Product: Int] = [:]
    @Published private var likes: [Product: Bool] = [:]
    
    //  외부에게 데이터를 전달하기 위한 수단
    private let output = PassthroughSubject<Output, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var numberOfItemsInCart: Int {
        return cart.reduce(0) { $0 + $1.value }
    }
    
    private var totalCost: Int {
        return cart.reduce(0) { $0 + ($1.key.price * $1.value) }
    }
    
    private var likedProductIds: Set<Int> {
        return Set(likes.filter { $0.value == true }.map { $0.key.id })
    }
    
    private var productQuantities: [Int: Int] {
        var tempDict = [Int: Int]()
        cart.forEach { tempDict[$0.key.id] = $0.value }
        return tempDict
    }
    
    init() {
        observe()
    }
    
    //  Model 데이터 구독(관찰, Observation)
    private func observe() {
        $cart.dropFirst()
            .sink { dict in
                dict.forEach { print("\($0.key.name) - \($0.value)") }
                print("==================================================")
            }.store(in: &self.cancellables)
        
        $likes.dropFirst()
            .sink { dict in
                let productNames = dict
                    .filter { $0.value == true }
                    .map { $0.key.name }
                print("❤️ \(productNames)")
            }.store(in: &self.cancellables)
    }
    
    //  핵심: Input 이벤트 -> Output 이벤트
    func transform(inputEvent: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        inputEvent.sink { [unowned self] inputEvent in  //  [unowned self]: self는 nil일 수 없다.
            switch inputEvent {
            case .viewDidLoad:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                    output.send(.setProducts(products: Product.collection))
                    output.send(.updateView(numberOfItemsInCart: numberOfItemsInCart, totalCost: totalCost, likedProductIds: likedProductIds, productQuantities: productQuantities))
                }
                
            case .onProductCellEvent(let cellEvent, let product):
                switch cellEvent {
                case .quantityDidChange(let value):
                    cart[product] = value
                    output.send(.updateView(numberOfItemsInCart: numberOfItemsInCart,
                                            totalCost: totalCost,
                                            likedProductIds: likedProductIds,
                                            productQuantities: productQuantities))
                case .heartDidTap:
                    if let value = likes[product] {
                        likes[product] = !value
                    } else {
                        likes[product] = true
                    }
                    output.send(.updateView(numberOfItemsInCart: numberOfItemsInCart,
                                            totalCost: totalCost,
                                            likedProductIds: likedProductIds,
                                            productQuantities: productQuantities))
                }
                
            case .onResetButtonTap:
                cart.removeAll()
                likes.removeAll()
            }
        }.store(in: &self.cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
