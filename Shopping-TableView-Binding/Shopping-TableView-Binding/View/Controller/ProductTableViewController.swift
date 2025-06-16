//
//  ViewController.swift
//  Shopping-TableView-Binding
//
//  Created by 홍진표 on 6/15/25.
//

import UIKit
import Combine

// MARK: - View(Controller)
//  MVVM의 모든 입력(input)은 View가 담당하며, Controler까지 View로 취급

final class ProductTableViewController: UITableViewController {

    private var numberOfItemsInCart = 0
    private var totalCost = 0
    private var likedProductIds: Set<Int> = []
    private var productQuantities: [Int: Int] = [:]
    
    //  UIKit+Combine에서는 자동으로 UI와 바인딩하는 기능이 없어, Model을 가지고 있어야함
    private var products: [Product] = []
    
    private let viewModel = ViewModel()
    
    //  ViewModel에게 입력을 알리기 위한 역할
    private let output = PassthroughSubject<ViewModel.Input, Never>()
    
    //  View(Controller)의 구독을 저장하고 관리하기 위한 역할
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        bindUI()
        
        //  ViewModel에게 input 상태를 알림
        //  🗣️: "ViewModel님! Input Event가 들어왔습니다."
        output.send(.viewDidLoad)
    }
    
    @objc func resetButtonTapped() {
        output.send(.onResetButtonTap)
    }


}

extension ProductTableViewController {
    
    //  View 구성
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Shopping App"
        
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: ProductTableViewCell.identifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetButtonTapped))
    }
    
    //  UI 바인딩
    private func bindUI() {
        viewModel.transform(inputEvent: output.eraseToAnyPublisher())
            .sink { [unowned self] outputEvent in
                switch outputEvent {
                case .setProducts(let products):
                    self.products = products
                case let .updateView(numberOfItemsInCart, totalCost, likedProductIds, productQuantities):
                    self.numberOfItemsInCart = numberOfItemsInCart
                    self.totalCost = totalCost
                    self.likedProductIds = likedProductIds
                    self.productQuantities = productQuantities
                    
                    self.tableView.reloadData()
                }
            }.store(in: &self.cancellables)
    }
}

// MARK: - UITableViewDataSource
extension ProductTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        let product = products[indexPath.row]
        
        cell.setProduct(product: product,
                        quantity: productQuantities[product.id] ?? 0,
                        isLiked: likedProductIds.contains(product.id))
        
        cell.eventReceiver.sink { [weak self] event in  //  [weak self]: self는 nil일 수도 있다.
            self?.output.send(.onProductCellEvent(cellEvent: event, product: product))
        }.store(in: &cell.cancellables)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(format: "Number of items: %d", numberOfItemsInCart)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return String(format: "Total Cost: %d", totalCost)
    }
}

// MARK: - UITableViewDelegate
extension ProductTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

#if DEBUG
import SwiftUI

#Preview(body: {
    UINavigationController(rootViewController: ProductTableViewController())
})
#endif

