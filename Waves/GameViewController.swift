//
//  GameViewController.swift
//  Waves
//
//  Created by Joshua Homann on 2/7/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()


    if let view = self.view as! SKView? {
      view.presentScene(GameScene(size: .init(width: 640, height: 480)))

      view.ignoresSiblingOrder = true

      view.showsFPS = true
      view.showsNodeCount = true
    }

  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
