//
//  ViewController.swift
//  Combine-Homework
//
//  Created by Олег Романов on 02.03.2022.
//

import UIKit
import Combine
import SnapKit

class ViewController: UIViewController {

    // MARK: - Appearance

    private enum Appearance {
        static let contentViewTopOffset: CGFloat = 40
        static let contentViewHorizontalInset: CGFloat = 18
        static let contentViewHeight: CGFloat = 205
        static let segmentedControlTopOffset: CGFloat = 27
        static let segmentedControlHeight: CGFloat = 32
        static let segmentedControlHorizontalInset: CGFloat = 90
        static let segmentedControlItems: [String] = ["Cats", "Dogs"]
        static let segmentedControlBackgroundColor = UIColor(
            red: 118.0 / 255.0,
            green: 118.0 / 255.0,
            blue: 128.0 / 255.0,
            alpha: 0.12
        )
        static let moreButtonTopOffset: CGFloat = 13
        static let moreButtonHeight: CGFloat = 40
        static let moreButtonWidth: CGFloat = 144
        static let moreButtonCornerRadius: CGFloat = 20
        static let moreButtonTitle = "more"
        static let moreButtonBackgroundColor = UIColor(
            red: 255.0 / 255.0,
            green: 155.0 / 255.0,
            blue: 138.0 / 255.0,
            alpha: 1
        )
        static let scoreLabelTopOffset: CGFloat = 35
        static let navBarTitle = "Cats and dogs"
        static let navBarShadowOffset = CGSize(width: 0, height: 0.5)
        static let navBarShadowOpacity: Float = 0.3
        static let resetButtonTitle = "Reset"
    }

    private enum SegmentedControlIndex: Int {
        case cat = 0
        case dog = 1
    }

    // MARK: - Properties

    private var cancellables: [AnyCancellable] = []

    private let scoreLabel: ScoreLabel = ScoreLabel()

    private let contentView: ContentView = ContentView()

    private let catService = CatFactsService()
    private let dogService = DogsService()

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Appearance.segmentedControlItems)
        control.backgroundColor = Appearance.segmentedControlBackgroundColor
        control.selectedSegmentIndex = SegmentedControlIndex.cat.rawValue

        return control
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Appearance.moreButtonCornerRadius
        button.layer.backgroundColor = Appearance.moreButtonBackgroundColor.cgColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle(Appearance.moreButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(moreButtonOnTap), for: .touchUpInside)

        return button
    }()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationBar()
        setupSubviews()
        makeConstraints()
        setupSubscriptions()
    }

    private func setupNavigationBar() {
        title = Appearance.navBarTitle

        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = Appearance.navBarShadowOffset
        navigationController?.navigationBar.layer.shadowRadius = .zero
        navigationController?.navigationBar.layer.shadowOpacity = Appearance.navBarShadowOpacity

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Appearance.resetButtonTitle,
            style: .plain,
            target: self,
            action: #selector(resetButtonOnTap)
        )
    }

    private func setupSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(contentView)
        view.addSubview(moreButton)
        view.addSubview(scoreLabel)
    }

    private func makeConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Appearance.segmentedControlTopOffset)
            make.leading.trailing.equalToSuperview().inset(Appearance.segmentedControlHorizontalInset)
            make.height.equalTo(Appearance.segmentedControlHeight)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(Appearance.contentViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Appearance.contentViewHorizontalInset)
            make.height.equalTo(Appearance.contentViewHeight)
        }

        moreButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(Appearance.moreButtonTopOffset)
            make.height.equalTo(Appearance.moreButtonHeight)
            make.width.equalTo(Appearance.moreButtonWidth)
            make.centerX.equalToSuperview()
        }

        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(moreButton.snp.bottom).offset(Appearance.scoreLabelTopOffset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupSubscriptions() {
        catService.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] catFact in
                self?.contentView.configure(with: catFact.fact)
            }
            .store(in: &cancellables)

        dogService.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let image = UIImage(data: data) else { return }
                self?.contentView.configure(with: image)
            }
            .store(in: &cancellables)


        Publishers.CombineLatest(
            catService.$counter,
            dogService.$counter
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.scoreLabel.configure(cats: count.0, dogs: count.1)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private methods

    @objc private func moreButtonOnTap() {
        switch segmentedControl.selectedSegmentIndex {
        case SegmentedControlIndex.cat.rawValue:
            catService.fetchData()

        case SegmentedControlIndex.dog.rawValue:
            dogService.fetchDogImage()

        default:
            break
        }
    }

    @objc private func resetButtonOnTap() {
        catService.resetCounter()
        dogService.resetCounter()
    }
}

