//
//  ViewController.swift
//  Shopping-TableView-Binding
//
//  Created by 홍진표 on 6/15/25.
//

import UIKit
import Combine

// MARK: - Controller

final class ProductTableViewController: UITableViewController {

    //  Controller(UIViewController)는 Model에 대한 데이터를 갖고 있으면서,
    private let products = Product.collection
    
    //  Model의 상태(데이터)가 변경되면 방출/구독을 통해 이를 감지
    //  -> View(UIView)에 변경 사항을 반영하기 위함
    @Published private var cart: [Product: Int] = [:]
    @Published private var likes: [Product: Bool] = [:]
    
    private var numberOfItemsInCart: Int {
        return cart.reduce(0) { partialResult, dict in
            partialResult + dict.value
        }
    }
    
    private var totalCost: Int {
        return cart.reduce(0) { partialResult, dict in
            partialResult + (dict.key.price * dict.value)
        }
    }
    
    //  Controller의 구독을 저장하고 관리하기 위한 역할
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        observe()
    }
    
    @objc func resetButtonTapped() {
        cart.removeAll()
        likes.removeAll()
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
    
    //  Model의 데이터 감지
    private func observe() {
        //  구독을 통해 데이터를 감지하고
        $cart.dropFirst()
            .sink { [unowned self] dict in  //  [unowned self]: self는 nil일 수 없다.
                dict.forEach { key, value in
                    print("\(key.name) - \(value)")
                }
                print("==================================================")
                //  데이터 변경사항이 발생 후, View를 갱신
                tableView.reloadData()
            }.store(in: &self.cancellables)
        
        $likes.dropFirst()
            .sink { [unowned self] dict in
                let productNames = dict
                    .filter { $0.value == true }
                    .map { $0.key.name }
                print("❤️ \(products)")
                tableView.reloadData()
            }.store(in: &self.cancellables)
    }
    
    //  Cell에서 전달된 이벤트에 따라 수량 또는 좋아요 상태 갱신
    func handleCellEvent(product: Product, indexPath: IndexPath, event: ProductTableViewCellEvent) {
        switch event {
        case .quantityDidChange(let value):
            cart[product] = value
        case .heartDidTapped:
            if let value = likes[product] {
                likes[product] = !value
            } else {
                likes[product] = true
            }
        }
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
                        quantity: cart[product] ?? 0,
                        isLiked: likes[product] ?? false)
        cell.eventReceiver
            .sink { [weak self] cellEvent in    //  [weak self]: self는 nil일 수도 있다.
            self?.handleCellEvent(product: product, indexPath: indexPath, event: cellEvent)
        }
        .store(in: &cell.cancellables)  //  Cell별로 구독 관리, 재사용에 유리
        //  .store(in: &cancellables)     //  뷰컨트롤러 전체에서 유지 (재사용 문제 발생 가능)
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

//#if DEBUG
//import SwiftUI
//
//#Preview(body: {
//    UINavigationController(rootViewController: ProductTableViewController())
//})
//#endif

