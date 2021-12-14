//
//  AppDelegate.swift
//  call-kit-practice
//
//  Created by jinsei_shima on 2021/02/04.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let session = AVAudioSession.sharedInstance()
    try! session.setActive(true, options: .notifyOthersOnDeactivation)

    let center = NotificationCenter.default

    // MARK: AVAudioSession

    center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: nil) { notification in
      guard
        let userInfo = notification.userInfo,
        let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
        let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
          return
        }

      if type == .began {
        // interruptionが開始した時(電話がかかってきたなど)
        print("### handle interruption: began")
      }
      else if type == .ended {
        // interruptionが終了した時の処理
        if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
          let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
          if options.contains(.shouldResume) {
            // Interruption Ended - playback should resume
            print("### ended should resume")
          } else {
            // Interruption Ended - playback should NOT resume
            print("### ended should not resume")
          }
        }
      }
    }
    center.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: nil) { notification in
      guard
        let userInfo = notification.userInfo,
        let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
        let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
          return
        }

      print("### routeChangeNotification:", reason)

      // イヤホンのポート一覧（有線、Bluetooth、...）
      let outputPorts: [AVAudioSession.Port] = [
        .headphones,
        .bluetoothA2DP,
        .bluetoothLE,
        .bluetoothHFP,
      ]

      switch reason {
      case .newDeviceAvailable:
        print("### newDeviceAvailable")
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        print("current inputs:", currentRoute.inputs, "current outputs:", currentRoute.outputs)
        for output in currentRoute.outputs where outputPorts.contains(output.portType) {
          // ヘッドフォンがつながった
          print("### available\n\(output.portType)\n\(output.portName)")
          break
        }
      case .oldDeviceUnavailable:
        if let previousRoute =
            userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
          print("### oldDeviceUnavailable")
          print("pre inputs:", previousRoute.inputs, "pre outputs:", previousRoute.outputs)
          for output in previousRoute.outputs where outputPorts.contains(output.portType) {
            // ヘッドフォンが外れた
            print("### unavailable\n\(output.portType)\n\(output.portName)")
            break
          }
        }
      case .unknown:
        print("### unknown")
      case .categoryChange:
        print("### categoryChanged")
      case .override:
        print("### override")
      case .wakeFromSleep:
        print("### wakeFromSleep")
      case .noSuitableRouteForCategory:
        print("### noSuitableRouteForCategory")
      case .routeConfigurationChange:
        print("### routeConfigurationChanged")
      @unknown default:
        break
      }
    }

    center.addObserver(forName: AVAudioSession.mediaServicesWereLostNotification, object: nil, queue: nil) { notification in
      print("### AVAudioSession.mediaServicesWereLostNotification:", notification)
    }
    center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: nil) { notification in
      print("### AVAudioSession.mediaServicesWereResetNotification:", notification)
    }

    // 他のアプリで音楽が再生されているかどうか
    print("### AVAudioSession isOtherAudioPlaying:", AVAudioSession.sharedInstance().isOtherAudioPlaying)

    center.addObserver(forName: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil, queue: nil) { notification in
      guard
        let userInfo = notification.userInfo,
        let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
        let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
          return
        }
      switch type {
      case .begin:
        print("### silenceSecondaryAudioHintNotification: began")
      case .end:
        print("### silenceSecondaryAudioHintNotification: end")
      @unknown default:
        fatalError()
      }
    }

    if #available(iOS 15.0, *) {
      center.addObserver(forName: AVAudioSession.spatialPlaybackCapabilitiesChangedNotification, object: nil, queue: nil) { notification in
        print("### AVAudioSession.spatialPlaybackCapabilitiesChangedNotification:", notification)
      }
    } else {
      // Fallback on earlier versions
    }

    // パーミッション周り

    print("### AVAudioSession recordPermission:", AVAudioSession.sharedInstance().recordPermission.rawValue)
    print("### AVCaptureDevice authorization status audio", AVCaptureDevice.authorizationStatus(for: .audio).rawValue)
    print("### AVCaptureDevice authorization status video", AVCaptureDevice.authorizationStatus(for: .video).rawValue)
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

