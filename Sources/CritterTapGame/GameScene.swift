import SpriteKit

class GameScene: SKScene {
    
    // Labels
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var starTexture: SKTexture!

    
    // Game state
    var score = 0
    var timeRemaining = 60
    var gameIsOver = false
    
    // Animal definition
    struct AnimalType {
        let name: String
        let points: Int
        let color: SKColor
        let lifeSpan: TimeInterval
    }
    
    override func didMove(to view: SKView) {
        addBackground()
        startFireflies()
        starTexture = makeStarTexture()
        spawnStars()
        setupLabels()
        startSpawningCritters()
        startTimer()
    }
    
    func makeStarTexture() -> SKTexture {
        let size = CGSize(width: 6, height: 6)

        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }

        return SKTexture(image: img)
    }

    
    // MARK: - UI
    
    func setupLabels() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: frame.minX + 20, y: frame.maxY - 20)
        addChild(scoreLabel)
        
        timeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timeLabel.fontSize = 32
        timeLabel.fontColor = .white
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.verticalAlignmentMode = .top
        timeLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 20)
        addChild(timeLabel)
        
        updateScoreLabel()
        updateTimeLabel()
    }
    
    func addBackground() {
        let bg = SKSpriteNode(imageNamed: "background")
        bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        bg.size = CGSize(width: self.size.width, height: self.size.height)
        bg.zPosition = -10
        addChild(bg)
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    func updateTimeLabel() {
        timeLabel.text = "Time: \(timeRemaining)"
    }
    
    // MARK: - Stars & Fireflies
    
    func spawnStars() {
        // 20 bright stars, all sprites, not shapes
        for _ in 1...20 {

            let star = SKSpriteNode(texture: starTexture)
            star.color = .white
            star.colorBlendFactor = 1.0

            // Random scale for variation (makes brightness difference too)
            let scale = CGFloat.random(in: 0.6 ... 1.4)
            star.setScale(scale)

            // Place stars more toward center, away from trees
            let x = CGFloat.random(in: frame.minX + 80 ... frame.maxX - 80)
            let y = CGFloat.random(in: frame.midY + 120 ... frame.maxY - 80)

            star.position = CGPoint(x: x, y: y)
            star.zPosition = -4
            addChild(star)

            // Bright pulse (easy to see)
            let fadeDown = SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1.5 ... 2.4))
            let fadeUp = SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1.5 ... 2.4))
            let pulse = SKAction.repeatForever(SKAction.sequence([fadeDown, fadeUp]))

            let delay = SKAction.wait(forDuration: Double.random(in: 0 ... 1))
            star.run(SKAction.sequence([delay, pulse]))
        }
    }

    
    func startFireflies() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnFirefly()
        }
        
        let wait = SKAction.wait(forDuration: 1.6, withRange: 0.8)
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence), withKey: "fireflies")
    }
    
    func spawnFirefly() {
        
        // TEXTURE-BASED FIREFLY (much cheaper than shape nodes)
        let radius = CGFloat.random(in: 2.0 ... 4.0)
        let firefly = SKSpriteNode(imageNamed: "glowDot")  // add this tiny dot to Assets
        firefly.colorBlendFactor = 1.0
        firefly.color = [
            SKColor(red: 1.0, green: 0.85, blue: 0.30, alpha: 1.0),
            SKColor(red: 1.0, green: 0.78, blue: 0.25, alpha: 1.0),
            SKColor(red: 1.0, green: 0.92, blue: 0.55, alpha: 1.0)
        ].randomElement()!
        
        firefly.setScale(radius / 3.0)     // scale down dot to match your old sizes
        firefly.zPosition = -5
        firefly.alpha = 0
        
        // START POSITION
        let startX = CGFloat.random(in: frame.minX + 40 ... frame.maxX - 40)
        let spawnChoice = Int.random(in: 1...10)
        
        let startY =
        (spawnChoice <= 7)
        ? CGFloat.random(in: frame.minY + 80 ... frame.midY + 40)
        : CGFloat.random(in: frame.midY + 80 ... frame.maxY - 120)
        
        firefly.position = CGPoint(x: startX, y: startY)
        addChild(firefly)
        
        // MOVEMENT
        let driftX = CGFloat.random(in: -120 ... 120)
        let driftY = CGFloat.random(in: -15 ... 30)
        let duration = TimeInterval.random(in: 3.0 ... 4.0)
        
        let move = SKAction.customAction(withDuration: duration) { node, time in
            let t = CGFloat(time / CGFloat(duration))
            let wobble = sin(t * 6.0) * 10
            node.position = CGPoint(
                x: startX + driftX * t + wobble,
                y: startY + driftY * t
            )
        }
        
        // FADING
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.7)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let fadeDelay = SKAction.wait(forDuration: duration * 0.55)
        let fading = SKAction.sequence([fadeIn, fadeDelay, fadeOut])
        
        // SOFT GLOW PULSE
        let pulseUp = SKAction.scale(to: 1.12, duration: 1.0)
        let pulseDown = SKAction.scale(to: 0.92, duration: 1.0)
        let pulse = SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown]))
        firefly.run(pulse)
        
        // SPARK TRAIL — clean, tiny, built-in texture
        let spark = SKEmitterNode()
        spark.particleTexture = SKTexture(imageNamed: "spark")   // tiny built-in texture
        spark.particleBirthRate = 12
        spark.particleLifetime = 0.25
        spark.particleLifetimeRange = 0.1
        spark.particleSpeed = 10
        spark.particleSpeedRange = 6
        spark.particleScale = 0.04
        spark.particleScaleRange = 0.02
        spark.particleAlpha = 0.5
        spark.particleAlphaSpeed = -2.0
        spark.particleColor = firefly.color
        spark.particleColorBlendFactor = 1
        spark.zPosition = -6
        spark.targetNode = self
        firefly.addChild(spark)


        // RUN EVERYTHING
        firefly.run(move)
        firefly.run(fading)
        firefly.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Critters
    
    func startSpawningCritters() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnCritter()
        }
        
        let spawnBase = 1.4   // you liked this speed
        let spawnRate = max(0.9, spawnBase - (Double(score) * 0.003))
        let wait = SKAction.wait(forDuration: spawnRate, withRange: spawnRate * 0.25)
        let sequence = SKAction.sequence([spawn, wait])
        
        run(SKAction.repeatForever(sequence), withKey: "spawnCritters")
    }
    
    func randomAnimal() -> AnimalType {
        let animals = [
            AnimalType(name: "bunny",     points: 1,  color: .systemPink,   lifeSpan: 1.8),
            AnimalType(name: "raccoon",   points: 2,  color: .systemGray,   lifeSpan: 1.7),
            AnimalType(name: "fox",       points: 3,  color: .systemOrange, lifeSpan: 1.6),
            AnimalType(name: "bear",      points: 5,  color: .brown,        lifeSpan: 1.4),
            AnimalType(name: "goldenowl", points: 10, color: .systemYellow, lifeSpan: 1.2)
        ]
        
        var bag = animals + animals + animals
        bag.append(animals.last!)
        
        return bag.randomElement()!
    }
    
    func currentLifeSpan(base: TimeInterval) -> TimeInterval {
        let multiplier = max(0.6, 1.0 - (Double(score) * 0.003))
        return base * multiplier
    }
    
    func spawnCritter() {
        if gameIsOver { return }
        
        let animal = randomAnimal()
        
        let critter = SKSpriteNode(imageNamed: animal.name)
        critter.name = "critter"
        critter.userData = NSMutableDictionary(dictionary: ["points": animal.points])
        critter.size = CGSize(width: 90, height: 90)
        
        let margin: CGFloat = 100
        let minX = frame.minX + margin
        let maxX = frame.maxX - margin
        let minY = frame.minY + margin
        let maxY = frame.maxY - margin
        
        critter.position = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
        
        critter.setScale(0)
        addChild(critter)
        critter.run(SKAction.scale(to: 1.0, duration: 0.2))
        
        let wait = SKAction.wait(forDuration: currentLifeSpan(base: animal.lifeSpan))
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        critter.run(SKAction.sequence([wait, fade, remove]))
    }
    
    // MARK: - Timer / Game Over
    
    func startTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let tick = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.gameIsOver { return }
            
            self.timeRemaining -= 1
            self.updateTimeLabel()
            
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
        
        let sequence = SKAction.sequence([wait, tick])
        run(SKAction.repeatForever(sequence), withKey: "timer")
    }
    
    func endGame() {
        if gameIsOver { return }
        gameIsOver = true
        
        removeAction(forKey: "spawnCritters")
        
        enumerateChildNodes(withName: "critter") { node, _ in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
        
        showGameOver()
    }
    
    func showGameOver() {
        let overlay = SKSpriteNode(color: SKColor(white: 0, alpha: 0.5), size: self.size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        overlay.name = "overlay"
        addChild(overlay)
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Time Up"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 40)
        overlay.addChild(gameOverLabel)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        finalScoreLabel.text = "Score: \(score)"
        finalScoreLabel.fontSize = 32
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: 0, y: 0)
        overlay.addChild(finalScoreLabel)
        
        let playAgainLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 32
        playAgainLabel.fontColor = .systemYellow
        playAgainLabel.position = CGPoint(x: 0, y: -60)
        playAgainLabel.name = "playAgainButton"
        overlay.addChild(playAgainLabel)
    }
    
    func restartGame() {
        gameIsOver = false
        score = 0
        timeRemaining = 60
        
        updateScoreLabel()
        updateTimeLabel()
        
        childNode(withName: "overlay")?.removeFromParent()
        
        removeAction(forKey: "timer")
        startTimer()
        startSpawningCritters()
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let node = atPoint(location) as? SKLabelNode, node.name == "playAgainButton" {
            restartGame()
            return
        }
        
        let nodesHere = nodes(at: location)
        for node in nodesHere {
            if node.name == "critter" {
                catchCritter(node: node)
                return
            }
        }
    }
    
    func catchCritter(node: SKNode) {
        if gameIsOver { return }
        
        let points = node.userData?["points"] as? Int ?? 1
        score += points
        updateScoreLabel()
        
        let pop = SKAction.scale(to: 1.2, duration: 0.1)
        let fade = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        node.run(SKAction.sequence([pop, fade, remove]))
    }
}
