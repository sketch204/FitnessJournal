//
//  Bundle+Versions.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-08.
//

import Foundation

public extension Bundle {
    var versionString: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumberString: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    var buildNumber: Int? {
        buildNumberString.flatMap(Int.init)
    }
}
