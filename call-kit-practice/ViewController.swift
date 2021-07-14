//
//  ViewController.swift
//  call-kit-practice
//
//  Created by jinsei_shima on 2021/02/04.
//

import UIKit
import EasyPeasy
import CallKit

final class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    do {
      let addButton = UIButton(type: .contactAdd)
      view.addSubview(addButton)
      addButton.easy.layout(Left(48), Bottom(80))
      addButton.addTarget(self, action: #selector(startCall), for: .touchUpInside)
    }

    do {
      let addButton = UIButton(type: .close)
      view.addSubview(addButton)
      addButton.easy.layout(Right(48), Bottom(80))
      addButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
    }
  }

  @objc func startCall() {

  }

  @objc func endCall() {

  }

}


