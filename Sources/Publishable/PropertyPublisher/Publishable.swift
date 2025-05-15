//
//  Publishable.swift
//  Publishable
//
//  Created by Kamil Strzelecki on 12/01/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

@attached(
    member,
    names: named(_publisher),
    named(publisher),
    named(PropertyPublisher),
    named(Observation)
)
@attached(
    extension,
    conformances: Publishable
)
public macro Publishable() = #externalMacro(
    module: "PublishableMacros",
    type: "PublishableMacro"
)

public protocol Publishable: AnyObject {

    associatedtype PropertyPublisher: AnyPropertyPublisher<Self>

    var publisher: PropertyPublisher { get }
}
