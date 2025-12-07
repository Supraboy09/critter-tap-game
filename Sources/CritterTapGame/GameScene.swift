import SpriteKit

class GameScene: SKScene {

    private var scoreLabel: SKLabelNode!
    private var score: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        spawnCritter()
    }

    func spawnCritter() {
        let critter = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 80))
        critter.position = CGPoint(
            x: CGFloat.random(in: 50...(size.width - 50)),
            y: CGFloat.random(in: 50...(size.height - 150))
        )
        critter.name = "critter"
        addChild(critter)

        let wait = SKAction.wait(forDuration: 1.5)
        let remove = SKAction.removeFromParent()
        critter.run(SKAction.sequence([wait, remove])) { [weak self] in
            self?.spawnCritter()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesTapped = nodes(at: location)

        for node in nodesTapped {
            if node.name == "critter" {
                node.removeFromParent()
                score += 1
                scoreLabel.text = "Score: \(score)"
                spawnCritter()
            }
        }
    }
}
