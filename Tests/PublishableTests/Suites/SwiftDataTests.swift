//
//  SwiftDataTests.swift
//  Publishable
//
//  Created by Kamil Strzelecki on 15/05/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@testable import Publishable
import Foundation
import SwiftData
import Testing

internal struct SwiftDataTests {

    @Test
    func testStoredPropertyPublisher() {
        var person: Person? = .init()
        var publishableQueue = [String]()
        nonisolated(unsafe) var observationsQueue: [Void] = []

        var completion: Subscribers.Completion<Never>?
        let cancellable = person?.publisher.name.sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { publishableQueue.append($0) }
        )

        func observe() {
            withObservationTracking {
                _ = person?.name
            } onChange: {
                observationsQueue.append(())
            }
        }

        observe()
        #expect(publishableQueue.popFirst() == "John")
        #expect(observationsQueue.popFirst() == nil)

        person?.surname = "Strzelecki"
        #expect(publishableQueue.popFirst() == nil)
        #expect(observationsQueue.popFirst() == nil)

        person?.name = "Kamil"
        #expect(publishableQueue.popFirst() == "Kamil")
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person = nil
        #expect(publishableQueue.isEmpty)
        #expect(observationsQueue.isEmpty)
        #expect(completion == .finished)
        cancellable?.cancel()
    }

    @Test
    func testComputedPropertyPublisher() {
        var person: Person? = .init()
        var publishableQueue = [String]()
        nonisolated(unsafe) var observationsQueue: [Void] = []

        var completion: Subscribers.Completion<Never>?
        let cancellable = person?.publisher.fullName.sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { publishableQueue.append($0) }
        )

        func observe() {
            withObservationTracking {
                _ = person?.fullName
            } onChange: {
                observationsQueue.append(())
            }
        }

        observe()
        #expect(publishableQueue.popFirst() == "John Doe")
        #expect(observationsQueue.popFirst() == nil)

        person?.surname = "Strzelecki"
        #expect(publishableQueue.popFirst() == "John Strzelecki")
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person?.age += 1
        #expect(publishableQueue.popFirst() == nil)
        #expect(observationsQueue.popFirst() == nil)

        person?.name = "Kamil"
        #expect(publishableQueue.popFirst() == "Kamil Strzelecki")
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person = nil
        #expect(publishableQueue.isEmpty)
        #expect(observationsQueue.isEmpty)
        #expect(completion == .finished)
        cancellable?.cancel()
    }
}

extension SwiftDataTests {

    @Test
    func testWillChangePublisher() {
        var person: Person? = .init()
        var publishableQueue = [Person]()
        nonisolated(unsafe) var observationsQueue: [Void] = []

        var completion: Subscribers.Completion<Never>?
        let cancellable = person?.publisher.willChange.sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { publishableQueue.append($0) }
        )

        func observe() {
            withObservationTracking {
                _ = person?.age
                _ = person?.name
                _ = person?.surname
                _ = person?.fullName
            } onChange: {
                observationsQueue.append(())
            }
        }

        observe()
        #expect(publishableQueue.popFirst() == nil)
        #expect(observationsQueue.popFirst() == nil)

        person?.surname = "Strzelecki"
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person?.age += 1
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person?.name = "Kamil"
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person = nil
        #expect(publishableQueue.isEmpty)
        #expect(observationsQueue.isEmpty)
        #expect(completion == .finished)
        cancellable?.cancel()
    }

    @Test
    func testDidChangePublisher() {
        var person: Person? = .init()
        var publishableQueue = [Person]()
        nonisolated(unsafe) var observationsQueue: [Void] = []

        var completion: Subscribers.Completion<Never>?
        let cancellable = person?.publisher.didChange.sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { publishableQueue.append($0) }
        )

        func observe() {
            withObservationTracking {
                _ = person?.age
                _ = person?.name
                _ = person?.surname
                _ = person?.fullName
            } onChange: {
                observationsQueue.append(())
            }
        }

        observe()
        #expect(publishableQueue.popFirst() == nil)
        #expect(observationsQueue.popFirst() == nil)

        person?.surname = "Strzelecki"
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person?.age += 1
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person?.name = "Kamil"
        #expect(publishableQueue.popFirst() === person)
        #expect(observationsQueue.popFirst() != nil)
        observe()

        person = nil
        #expect(publishableQueue.isEmpty)
        #expect(observationsQueue.isEmpty)
        #expect(completion == .finished)
        cancellable?.cancel()
    }
}

extension SwiftDataTests {

    @Publishable @Model
    public final class Person {

        var age: Int
        fileprivate(set) var name: String
        public var surname: String

        internal var fullName: String {
            "\(name) \(surname)"
        }

        package var initials: String {
            get { "\(name.prefix(1))\(surname.prefix(1))" }
            set { _ = newValue }
        }

        init(
            age: Int = 25,
            name: String = "John",
            surname: String = "Doe"
        ) {
            self.age = age
            self.name = name
            self.surname = surname
        }
    }
}
