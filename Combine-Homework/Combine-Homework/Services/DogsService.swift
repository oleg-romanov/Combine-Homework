//
//  DogsService.swift
//  Combine-Homework
//
//  Created by Олег Романов on 02.03.2022.
//

import Foundation
import Combine
import UIKit

final class DogsService {

    // MARK: - Instance properties

    @Published var counter: Int = 0

    var publisher: AnyPublisher<Data, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<Data, Never>()

    private let decoder = JSONDecoder()
    private let session = URLSession.shared
    private var loadDogImageDataCancellable: AnyCancellable?
    private var fetchDogResponseCancellable: AnyCancellable?

    private var url: URL {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            fatalError("Base url is not configured")
        }

        return url
    }

    // MARK: - Instance methods

    func fetchDogImage() {
        fetchDogResponseCancellable = fetchDogResponse()
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { [weak self] url in
                    guard let self = self else { return }

                    self.loadDogImageDataCancellable = self.session.dataTaskPublisher(for: url)
                        .map(\.data)
                        .replaceError(with: Data())
                        .sink { data in
                            self.counter += 1
                            self.subject.send(data)
                        }
                }
            )
    }

    func resetCounter() {
        counter = 0
    }

    private func fetchDogResponse() -> AnyPublisher<URL, Error> {
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DogsResponse.self, decoder: decoder)
            .compactMap {
                URL(string: $0.message)
            }
            .eraseToAnyPublisher()
    }
}
