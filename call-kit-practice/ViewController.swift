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

  private let statusLabel = UILabel()

  private let callingUUID = UUID()
  private static let nickname = "Charlotte"

  private let callController = CXCallController(queue: .main)
  private let provider: CXProvider = .init(configuration: { () -> CXProviderConfiguration in
    let providerConfiguration = CXProviderConfiguration(localizedName: nickname)
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

    title = "CallKit Practice"
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true

    provider.setDelegate(self, queue: DispatchQueue.main)

    view.backgroundColor = .white

    view.addSubview(statusLabel)
    statusLabel.easy.layout(
      Center()
    )

    statusLabel.text = "..."
    statusLabel.font = UIFont.boldSystemFont(ofSize: 20)
    statusLabel.textColor = .darkText

    let newIncomingCallButton = UIButton(type: .custom)
    newIncomingCallButton.setTitle("incoming", for: .normal)
    newIncomingCallButton.setTitleColor(.systemBlue, for: .normal)
    newIncomingCallButton.addTarget(self, action: #selector(incomingCall), for: .touchUpInside)

    let newOutgoingCallButton = UIButton(type: .custom)
    newOutgoingCallButton.setTitle("outgoing", for: .normal)
    newOutgoingCallButton.setTitleColor(.systemBlue, for: .normal)
    newOutgoingCallButton.addTarget(self, action: #selector(outgoingCall), for: .touchUpInside)

    let startCallButton = UIButton(type: .custom)
    startCallButton.setTitle("start", for: .normal)
    startCallButton.setTitleColor(.systemBlue, for: .normal)
    startCallButton.addTarget(self, action: #selector(startCall), for: .touchUpInside)

    let endCallButton = UIButton(type: .custom)
    endCallButton.setTitle("end", for: .normal)
    endCallButton.setTitleColor(.systemRed, for: .normal)
    endCallButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)

    let stackView = UIStackView(arrangedSubviews: [
      endCallButton,
      startCallButton,
      newIncomingCallButton,
      newOutgoingCallButton,
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

  @objc func incomingCall() {
    print("new incoming call")

    let bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

      self.statusLabel.text = "new incoming call"

      let callHandler = CXHandle(type: .generic, value: Self.nickname)
      let callUpdate = CXCallUpdate()
      callUpdate.remoteHandle = callHandler
      callUpdate.supportsHolding = true
      callUpdate.supportsDTMF = false
      callUpdate.supportsUngrouping = false
      callUpdate.supportsGrouping = false
      callUpdate.hasVideo = true

      self.provider.reportNewIncomingCall(with: self.callingUUID, update: callUpdate) { error in
        print("report new incoming call error", error)
      }
      UIApplication.shared.endBackgroundTask(bgTaskID)

    }
  }

  @objc func outgoingCall() {
    print("new outgoing call")

    statusLabel.text = "new outgoing call"

    let fromHandle = CXHandle(type: .generic, value: Self.nickname)
    let startCallAction = CXStartCallAction(call: UUID(), handle: fromHandle)
//    startCallAction.isVideo = true
    let startCallTransaction = CXTransaction(action: startCallAction)

    callController.request(startCallTransaction) { [weak self] (error) in

      if let error = error {
        print("report new outgoing call error", error)
      }

      guard let self = self else { return }

      self.provider.reportOutgoingCall(with: startCallAction.callUUID, startedConnectingAt: nil)

      let bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)

      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.provider.reportOutgoingCall(with: startCallAction.callUUID, connectedAt: nil)
        UIApplication.shared.endBackgroundTask(bgTaskID)
      }

    }

  }

  @objc func startCall() {
    print("start call")

    statusLabel.text = "start call"

    let handle = CXHandle(type: .generic, value: Self.nickname)
    let startCallAction = CXStartCallAction(call: callingUUID, handle: handle)
    let transaction = CXTransaction(action: startCallAction)

    let bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)

    callController.request(transaction) { [weak self] error in

      if let error = error {
        print("start call request error", error)
      }

      guard let self = self else {
        return
      }

      let update = CXCallUpdate()
      update.supportsDTMF = false
      update.supportsHolding = false
      update.supportsGrouping = false
      update.supportsUngrouping = false
      update.hasVideo = true
      self.provider.reportCall(with: self.callingUUID, updated: update)
      UIApplication.shared.endBackgroundTask(bgTaskID)
    }
  }

  @objc func endCall() {
    print("end call")

    statusLabel.text = "end call"

    provider.reportCall(with: callingUUID, endedAt: .init(), reason: .failed)
  }

}

extension ViewController: CXProviderDelegate {

  public func providerDidReset(_: CXProvider) {
    // Must clean up
  }

  public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {

    print("provider start")

    provider.reportOutgoingCall(with: callingUUID, startedConnectingAt: .init())

//    let result = delegate.handleStartCall()

//    switch result {
//    case .success:

      action.fulfill(withDateStarted: .init())
      provider.reportOutgoingCall(with: callingUUID, connectedAt: .init())
//    case .failure:
//
//      action.fail()
//      provider.reportCall(with: callingUUID, endedAt: .init(), reason: .failed)
//    }

  }

  public func provider(_: CXProvider, perform action: CXEndCallAction) {

    print("provider end")

//    let result = delegate.handleEndCall()
//
//    switch result {
//    case .success:

      action.fulfill(withDateEnded: .init())
//    case .failure:
//
//      action.fail()
//    }

  }

  public func provider(_: CXProvider, perform action: CXSetMutedCallAction) {

    //    delegate.handleMute(muted: action.isMuted)
    action.fulfill()
  }
}

