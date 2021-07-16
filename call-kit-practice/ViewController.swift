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

  let statusLabel = UILabel()

  private let callingUUID = UUID()

  private let callController = CXCallController(queue: .main)
  private let provider: CXProvider = .init(configuration: { () -> CXProviderConfiguration in
    let providerConfiguration = CXProviderConfiguration(localizedName: "ふうたろう")
    providerConfiguration.supportsVideo = true
    providerConfiguration.maximumCallGroups = 1
    providerConfiguration.maximumCallsPerCallGroup = 1
    providerConfiguration.supportedHandleTypes = [.generic]
    providerConfiguration.includesCallsInRecents = false
//    providerConfiguration.iconTemplateImageData = wrapperConfig.iconTemplateImage.pngData()
    return providerConfiguration
  }())

  override func viewDidLoad() {

    super.viewDidLoad()

//    provider.setDelegate(self, queue: DispatchQueue.main)

    view.backgroundColor = .white

    view.addSubview(statusLabel)
    statusLabel.easy.layout(
      Center()
    )

    statusLabel.text = "..."
    statusLabel.font = UIFont.boldSystemFont(ofSize: 20)
    statusLabel.textColor = .darkText

    let newIncomingCallButton = UIButton(type: .custom)
    newIncomingCallButton.setTitle("new incoming", for: .normal)
    newIncomingCallButton.setTitleColor(.systemBlue, for: .normal)
    newIncomingCallButton.addTarget(self, action: #selector(newIncomingCall), for: .touchUpInside)
//    newIncomingCallButton.easy.layout(Size(.init(width: 40, height: 40)))

    let startCallButton = UIButton(type: .custom)
    startCallButton.setTitle("start", for: .normal)
    startCallButton.setTitleColor(.systemBlue, for: .normal)
    startCallButton.addTarget(self, action: #selector(startCall), for: .touchUpInside)
//    startCallButton.easy.layout(Size(.init(width: 40, height: 40)))

    let endCallButton = UIButton(type: .custom)
    endCallButton.setTitle("end", for: .normal)
    endCallButton.setTitleColor(.systemRed, for: .normal)
    endCallButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
//    endCallButton.easy.layout(Size(.init(width: 40, height: 40)))

    let stackView = UIStackView(arrangedSubviews: [
      endCallButton,
      startCallButton,
      newIncomingCallButton,
    ])
    stackView.spacing = 16

    view.addSubview(stackView)
    stackView.easy.layout(
      Left(>=24),
      Right(<=24),
      CenterX(),
      Bottom(24).to(view.safeAreaLayoutGuide, .bottom)
    )

  }

  @objc func newIncomingCall() {
    print("new incomingCall call")

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

      self.statusLabel.text = "new incomingCall call"

      let callHandler = CXHandle(type: .generic, value: "XXX")
      let callUpdate = CXCallUpdate()
      callUpdate.remoteHandle = callHandler
      callUpdate.supportsHolding = true
      callUpdate.supportsDTMF = false
      callUpdate.supportsUngrouping = false
      callUpdate.supportsGrouping = false
      callUpdate.hasVideo = false

      self.provider.reportNewIncomingCall(with: self.callingUUID, update: callUpdate) { error in
        print("report new incoming call error", error)
      }

    }
  }

  @objc func startCall() {
    print("start call")

    statusLabel.text = "start call"

    let handle = CXHandle(type: .generic, value: "ふうたろう")
    let startCallAction = CXStartCallAction(call: callingUUID, handle: handle)
    let transaction = CXTransaction(action: startCallAction)

    callController.request(transaction) { [weak self] error in

      if let error = error {
        print("start call request error", error)
      }

      guard let self = self else {
        return
      }

      disableKeyPad: do {
        let update = CXCallUpdate()
        update.supportsDTMF = false
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.hasVideo = true
        self.provider.reportCall(with: self.callingUUID, updated: update)
      }
    }
  }

  @objc func endCall() {
    print("end call")

    statusLabel.text = "end call"

    provider.reportCall(with: callingUUID, endedAt: .init(), reason: .remoteEnded)
  }

}

//extension ViewController: CXProviderDelegate {
//
//  public func providerDidReset(_: CXProvider) {
//    // Must clean up
//  }
//
//  public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
//
//    print("provider start")
//
//    provider.reportOutgoingCall(with: callingUUID, startedConnectingAt: .init())
//
////    let result = delegate.handleStartCall()
//
////    switch result {
////    case .success:
//
//      action.fulfill(withDateStarted: .init())
//      provider.reportOutgoingCall(with: callingUUID, connectedAt: .init())
////    case .failure:
////
////      action.fail()
////      provider.reportCall(with: callingUUID, endedAt: .init(), reason: .failed)
////    }
//
//  }
//
//  public func provider(_: CXProvider, perform action: CXEndCallAction) {
//
//    print("provider end")
//
////    let result = delegate.handleEndCall()
////
////    switch result {
////    case .success:
//
//      action.fulfill(withDateEnded: .init())
////    case .failure:
////
////      action.fail()
////    }
//  }
//
//  public func provider(_: CXProvider, perform action: CXSetMutedCallAction) {
//
//    //    delegate.handleMute(muted: action.isMuted)
//    action.fulfill()
//  }
//}
//
