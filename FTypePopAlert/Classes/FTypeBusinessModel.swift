//
//  FTypeBusinessModel.swift
//  FTypePopAlert
//
//  Created by pulei yu on 2023/10/31.
//

import Foundation
import SwiftyJSON

open class FTypeBusinessModel {
    open var tag: String

    open var icon: String

    open var title: String

    open var html: String

    open var webview: String

    open var buttons: [FTypeButtonModel] { [] }

    public init(json: JSON) {
        tag = json["popup_tag"].stringValue
        title = json["popup_title"].stringValue
        icon = json["popup_icon"].stringValue
        html = json["popup_html"].stringValue
        webview = json["popup_webview"].stringValue
    }
}

open class FTypeButtonModel {
    public var title: String = ""
    public var color: UIColor?
}
