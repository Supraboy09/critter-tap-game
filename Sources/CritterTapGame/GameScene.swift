import SpriteKit

enum CritterType: CaseIterable {
    case bunny
    case fox
    case bear
    case raccoon
    case goldenOwl

    var imageName: String {
        switch self {
        case .bunny: return "bunny"
        case .fox: return "fox"
        case .bear: return "bear"
        case .raccoon: return "raccoon"
        case .goldenOwl: return "goldenowl"
        }
    }

    var pointValue: Int {
        switch self {
        case .bunny: return 1
        case .fox: return 2
        case .bear: return 3
        case .raccoon: return 4
        case .goldenOwl: return 5
        }
    }

    static func randomCritter() -> CritterType {
        let basic: [CritterType] = [.bunny, .fox, .bear, .raccoon]
        let rareChance = Int.random(in: 1...15)
        return rareChance == 1 ? .goldenOwl : basic.randomElement()!
    }
}

class GameScene: SKScene {

    private var scoreLabel: SKLabelNode!
    private var score = 0

    override func didMove(to view: SKView) {

        // Background image
        let bg = SKSpriteNode(imageNamed: "background")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -1
        bg.size = size
        bg.alpha = 0.95       // slightly dimmed so critters pop more
        addChild(bg)

        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        addChild(scoreLabel)

        spawnCritter()
    }

    func spawnCritter() {
        let type = CritterType.randomCritter()
        let texture = SKTexture(imageNamed: type.imageName)

        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: 120, height: 120)
        sprite.position = CGPoint(
            x: CGFloat.random(in: 60...(size.width - 60)),
            y: CGFloat.random(in: 60...(size.height - 160))
        )
        sprite.userData = ["points": type.pointValue]

        addChild(sprite)

        sprite.run(.sequence([
            .wait(forDuration: 1.6),
            .removeFromParent()
        ])) { [weak self] in
            self?.spawnCritter()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)

        for node in nodes(at: pos) {
            if let sprite = node as? SKSpriteNode,
               let points = sprite.userData?["points"] as? Int {

                sprite.removeFromParent()
                score += points
                scoreLabel.text = "Score: \(score)"
                spawnCritter()
            }
        }
    }
}
