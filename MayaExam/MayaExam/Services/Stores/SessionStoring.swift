//
//  SessionStoring.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

protocol SessionStoring: AnyObject {
    var session: UserSession? { get set }
}

