//
//  PublisherDeclBuilder.swift
//  Publishable
//
//  Created by Kamil Strzelecki on 12/01/2025.
//  Copyright © 2025 Kamil Strzelecki. All rights reserved.
//

import PrincipleMacros

internal struct PublisherDeclBuilder: ClassDeclBuilder {

    let declaration: ClassDeclSyntax
    let properties: PropertiesList

    var settings: DeclBuilderSettings {
        .init(accessControlLevel: .init(inheritingDeclaration: .member))
    }

    func build() -> [DeclSyntax] {
        [
            """
            \(inheritedAccessControlLevel)private(set) lazy var publisher = PropertyPublisher(object: self)
            """
        ]
    }
}
