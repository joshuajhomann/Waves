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
    static let dampening: CGFloat = 0.999
  }
  var velocity: CGFloat  = 0
  var offset: CGFloat  = 0
}

class GameScene: SKScene {
  enum Constant {
    static let nodeCount = 200
  }
  var waterNode = SKShapeNode()
  var nodes: [SKNode] = []
  var droppingNode: SKNode?
  var force: CGFloat? = nil
  var springs: [Spring] = Array(0..<Constant.nodeCount).map { _ in Spring() }
  var waves: [Wave] = (0..<7).map { _ in Wave.makeRandom() }
  override func sceneDidLoad() {
    super.sceneDidLoad()
    size = .init(width: 640, height: 480)
    backgroundColor = .white
    let delta = 1.0 / CGFloat(Constant.nodeCount)
    nodes = (0..<Constant.nodeCount).map { index in
      let node = SKShapeNode(circleOfRadius: 2)
      node.fillColor = .blue
      node.position.x = delta * CGFloat(index) * size.width - size.width / 2
      node.position.y = 0
      addChild(node)
      return node
    }
    addChild(waterNode)
    scaleMode = .aspectFit
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
  }

  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    (0..<4).forEach { _ in
      springs.indices.forEach { offset in
        let left = Spring.Constant.resitution * (springs[safe: offset-1]?.offset ?? 0)
        let right = Spring.Constant.resitution * (springs[safe: offset+1]?.offset ?? 0)
        let accelleration = Spring.Constant.resitution * (springs[offset].offset) + (left + right) * 0.25
        springs[offset].velocity = accelleration + springs[offset].velocity * Spring.Constant.dampening
        springs[offset].offset += springs[offset].velocity
      }
    }

    let allPoints = zip(nodes, springs).map { node, spring -> CGPoint in
      CGPoint(
        x: node.position.x,
        y: spring.offset + waves.reduce(0) {(total, wave) -> CGFloat in
          total +
            wave.offset +
            wave.amplitude * sin(wave.frequency*node.position.x + wave.phase * CGFloat(currentTime))
        }
      )
    }

    zip(nodes, allPoints).forEach { $0.position = $1}
    let path = CGMutablePath()
    path.addLines(between: [CGPoint(x: -320, y: -240)] + allPoints + [CGPoint(x: 320, y: -240)])
    waterNode.path = path
    waterNode.fillColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.5)

    if let droppingNode = droppingNode,
      let force = force {
      if droppingNode.position.y < 0 {
        createSplash(at: droppingNode.position, magnitude: force, radius: 32)
        self.force = nil
      }
    }

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    guard let touchUp = event?.allTouches?.first?.location(in: self) else {
      return
    }
    let droppingNode = SKShapeNode(circleOfRadius: 32)
    droppingNode.fillColor = .brown
    droppingNode.strokeColor = .darkGray
    droppingNode.position = touchUp
    self.insertChild(droppingNode, at: 0)
    droppingNode.run(SKAction.sequence([
      .moveBy(x: 0, y: -480, duration: 1.5),
      .removeFromParent()
    ]))
    force = touchUp.y * (1.0/150.0)
    self.droppingNode = droppingNode
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
