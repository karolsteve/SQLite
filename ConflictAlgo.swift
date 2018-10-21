//
//  ConflictAlgo.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 17/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation

enum ConflictAlgo : String {
    case NONE = " "
    case ROLLBACK = " OR ROLLBACK "
    case ABORT = " OR ABORT "
    case FAIL = " OR FAIL "
    case IGNORE = " OR IGNORE "
    case REPLACE = " OR REPLACE "
}
