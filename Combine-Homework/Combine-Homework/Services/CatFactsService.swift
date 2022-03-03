//
//  CatFactsService.swift
//  Combine-Homework
//
//  Created by Олег Романов on 02.03.2022.
//

import Foundation
import Combine


final class CatFactsService {

    // MARK: - Instance properties

    @Published var counter: Int = 0

    var publisher: AnyPublisher<CatFacts, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<CatFacts, Never>()

    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private var cancellable: AnyCancellable?

    private var url: URL {
        guard let url = URL(string: "https://catfact.ninja/fact") else {
            fatalError("URL is not correct")
        }

        return url
    }

    // MARK: - Instance methods

    func fetchData() {
        cancellable = session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CatFacts?.self, decoder: decoder)
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { [weak self] in
                self?.counter += 1
                self?.subject.send($0)
            }
    }

    func resetCounter() {
        counter = 0
    }
}
