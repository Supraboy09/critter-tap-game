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
        // weighted rarity: golden owl is harder to get
        let normalCritters: [CritterType] = [.bunny, .fox, .bear, .raccoon]
        let rareChance = Int.random(in: 1...15)

        if rareChance == 1 { return .goldenOwl }
        return normalCritters.randomElement()!
    }
}

class GameScene: SKScene {

    private var scoreLabel: SKLabelNode!
    private var score: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        spawnCritter()
    }

    func spawnCritter() {
        let critterType = CritterType.randomCritter()
        let texture = SKTexture(imageNamed: critterType.imageName)

        let critter = SKSpriteNode(texture: texture)
        critter.size = CGSize(width: 120, height: 120)
        critter.position = CGPoint(
            x: CGFloat.random(in: 60...(size.width - 60)),
            y: CGFloat.random(in: 60...(size.height - 160))
        )
        critter.name = critterType.imageName
        critter.userData = ["points": critterType.pointValue]

        addChild(critter)

        let wait = SKAction.wait(forDuration: 1.6)
        let remove = SKAction.removeFromParent()
        critter.run(SKAction.sequence([wait, remove])) { [weak self] in
            self?.spawnCritter()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
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
