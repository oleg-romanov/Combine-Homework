//
//  ContentView.swift
//  Combine-Homework
//
//  Created by Олег Романов on 02.03.2022.
//

import UIKit

class ContentView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let borderWight: CGFloat = 1
        static let textLabelFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let textLabelInsets = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
    }

    // MARK: - Properties

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textLabelFont
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.baselineAdjustment = .alignCenters

        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupStyle()
        setupSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance methods

    func configure(with text: String) {
        textLabel.text = text
        imageView.image = nil
    }

    func configure(with image: UIImage) {
        imageView.image = image
        textLabel.text = nil
    }

    // MARK: - Private methods

    private func setupStyle() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWight
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true
    }

    private func setupSubviews() {
        addSubview(imageView)
        addSubview(textLabel)
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.textLabelInsets)
        }
    }
}
