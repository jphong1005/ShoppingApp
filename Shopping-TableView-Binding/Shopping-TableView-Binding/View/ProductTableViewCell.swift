//
//  ProductTableViewCell.swift
//  Shopping-TableView-Binding
//
//  Created by 홍진표 on 6/15/25.
//

import UIKit
import Combine

/// `User actions (Group)`
//  Cell 내부에서 발생하는 이벤트를 외부(ViewController)로 전달하기 위한 그룹핑
enum ProductTableViewCellEvent {
    case quantityDidChange(value: Int)  //  수량 변경 이벤트
    case heartDidTap                 //  좋아요 버튼 클릭 이벤트
}

// MARK: - View

final class ProductTableViewCell: UITableViewCell {

    static let identifier = "ProductTableViewCell"
    
    //  Cell에서 발생한 이벤트를 외부로 전달 (eventSubject)
    private let eventEmitter = PassthroughSubject<ProductTableViewCellEvent, Never>()
    
    //  외부에 노출되는 퍼블리셔, 구독을 통해 이벤트 처리 (eventPublisher)
    var eventReceiver: AnyPublisher<ProductTableViewCellEvent, Never> {
        return eventEmitter.eraseToAnyPublisher()
    }
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var outterHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.contentMode = .scaleToFill
        return stackView
    }()
    
    lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.textColor = .label
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = .darkGray
        return label
    }()
    
    lazy var innerHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.contentMode = .scaleToFill
        return stackView
    }()
    
    lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Item Name"
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var stepperWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.value = 0
        stepper.minimumValue = 0
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(stepperDidChange), for: .valueChanged)
        return stepper
    }()
    
    lazy var heartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(heartButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables = Set<AnyCancellable>()
    }
    
    @objc func stepperDidChange(stepper: UIStepper) {
        //  User action (to Controller)
        //  수량 변경 이벤트 발행
        let value = Int(stepper.value)
        eventEmitter.send(.quantityDidChange(value: value))
    }
    
    @objc func heartButtonDidTap() {
        //  User action (to Controller)
        //  좋아요 버튼 클릭 이벤트 발행
        eventEmitter.send(.heartDidTap)
    }

}

extension ProductTableViewCell {
    private func setupViews() {
        contentView.addSubview(outterHStack)
        
        outterHStack.addArrangedSubview(quantityLabel)
        outterHStack.addArrangedSubview(innerHStack)
        
        innerHStack.addArrangedSubview(productImageView)
        innerHStack.addArrangedSubview(nameLabel)
        innerHStack.addArrangedSubview(stepperWrapper)
        innerHStack.addArrangedSubview(heartButton)
        
        stepperWrapper.addSubview(stepper)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            outterHStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            outterHStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            outterHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            quantityLabel.widthAnchor.constraint(equalToConstant: 30),
            quantityLabel.heightAnchor.constraint(equalToConstant: 30),
            
            productImageView.widthAnchor.constraint(equalToConstant: 30),
            
            stepperWrapper.widthAnchor.constraint(equalToConstant: 100),
            
            stepper.centerXAnchor.constraint(equalTo: stepperWrapper.centerXAnchor),
            stepper.centerYAnchor.constraint(equalTo: stepperWrapper.centerYAnchor),
            
            heartButton.widthAnchor.constraint(equalToConstant: 30),
        ])

    }
    
    public func setProduct(product: Product, quantity: Int, isLiked: Bool) {
        quantityLabel.text = String(quantity)
        productImageView.image = UIImage(systemName: product.imageName)
        nameLabel.text = product.name + " -$\(product.price)"
        stepper.value = Double(quantity)
        
        let image = isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        heartButton.setImage(image, for: .normal)
    }
}
