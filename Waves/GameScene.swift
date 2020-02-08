//
//  GameScene.swift
//  Waves
//
//  Created by Joshua Homann on 2/7/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Wave {
  var offset: CGFloat
  var amplitude: CGFloat
  var frequency: CGFloat
  var phase: CGFloat
  static func makeRandom() -> Wave {
    .init(
      offset: CGFloat.random(in: -3...3),
      amplitude: CGFloat.random(in: -5...5),
      frequency: CGFloat.random(in: 0...0.1),
      phase: CGFloat.random(in: -4...0)
    )
  }
}

struct Spring {
  enum Constant {
    static let resitution: CGFloat = -0.0005
    static let dampening: CGFloat = 0.99
  }
  var velocity: CGFloat  = 0
  var offset: CGFloat  = 0
}

class GameScene: SKScene {
  var nodes: [SKNode] = []
  var springs: [Spring] = Array(0..<300).map { _ in Spring() }
  var waves: [Wave] = (0..<7).map { _ in Wave.makeRandom() }
  override func sceneDidLoad() {
    super.sceneDidLoad()
    size = .init(width: 640, height: 480)
    backgroundColor = .white
    let delta = 1.0 / CGFloat(300)
    nodes = (0..<300).map { index in
      let node = SKShapeNode(circleOfRadius: 2)
      node.fillColor = .blue
      node.position.x = delta * CGFloat(index) * size.width - size.width / 2
      node.position.y = 0
      print(delta * CGFloat(index) * size.width)
      addChild(node)
      return node
    }
    scaleMode = .aspectFit
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
  }

  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    (0..<12).forEach { _ in
      springs.indices.forEach { offset in
        let left = Spring.Constant.resitution * (springs[safe: offset-1]?.offset ?? springs[offset].offset - springs[offset].offset)
        let right = Spring.Constant.resitution * (springs[safe: offset+1]?.offset ?? springs[offset].offset - springs[offset].offset)
        let accelleration = Spring.Constant.resitution * (springs[offset].offset) - (left + right) * 0.25
        springs[offset].velocity = accelleration + springs[offset].velocity * 0.999
        springs[offset].offset += springs[offset].velocity
      }
    }
    zip(nodes, springs).forEach { node, spring in
      node.position.y = spring.offset + waves.reduce(0) {(total, wave) -> CGFloat in
        total +
        wave.offset +
        wave.amplitude * sin(wave.frequency*node.position.x + wave.phase * CGFloat(currentTime))
      }
    }

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    guard let touchUp = event?.allTouches?.first?.location(in: self) else {
      return
    }
    createSplash(at: touchUp, magnitude: 0.5, radius: 32)
  }

  func createSplash(at point: CGPoint, magnitude: CGFloat, radius: CGFloat) {
    let proportion = (point.x + size.width / 2) / size.width

    let mid = Int(proportion * CGFloat(nodes.count))
    let lower = max(mid - Int(radius), 0)
    let upper = min(mid + Int(radius), nodes.count - 1)

    for index in (lower...upper) {
      springs[index].velocity = -magnitude * sin(CGFloat(index - lower)/(radius * 2) * .pi)
    }
  }
}


extension Array {
  public subscript(safe index: Index) -> Element? { indices ~= index ? self[index] : nil }
}
