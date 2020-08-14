//
//  File.swift
//  
//
//  Created by Tate on 2020-08-14.
//

import Foundation

/**
 Weak object wrapper.
 - Used to avoid retain cycles in enum associated values.
 */
struct Weak<T: AnyObject> {
    weak var value: T?
    init(_ value: T?) { self.value = value }
}
