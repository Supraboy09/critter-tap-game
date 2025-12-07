import SpriteKit

class GameScene: SKScene {

    private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var score = 0
    private let critterSize = CGSize(width: 80, height: 80)

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupScoreLabel()
        spawnCritter()
    }

    private func setupScoreLabel() {
        scoreLabel.fontSize = 40
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }

    private func spawnCritter() {
        // Only spawn one at a time
        if childNode(withName: "critter") != nil { return }

        let critter = SKSpriteNode(color: .green, size: critterSize)
        critter.name = "critter"

        let safeInsets: CGFloat = 60
        critter.position = CGPoint(
            x: CGFloat.random(in: safeInsets...(size.width - safeInsets)),
            y: CGFloat.random(in: safeInsets...(size.height - 150))
        )

        addChild(critter)

        let wait = SKAction.wait(forDuration: 1.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, remove])

        critter.run(sequence) { [weak self] in
            self?.spawnCritter()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }

        for node in nodes(at: touchLocation) where node.name == "critter" {
            node.removeFromParent()
            score += 1
            scoreLabel.text = "Score: \(score)"
            spawnCritter()
        }
    }
}
