//
//  GameScene.swift
//  Teste1_SpriteKit
//
//  Created by Patricia de Abreu on 04/05/15.
//  Copyright (c) 2015 Patricia de Abreu. All rights reserved.
//

import SpriteKit
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let SuperDente   : UInt32 = 0b10       // 2
    static let Dinheiro    : UInt32 = 0b11    //3
    static let DentePodre  : UInt32 = 0b110   //4
    static let Moeda: UInt32 = 0b1      // 1
}

/////////////////////////////////

//implementar o delegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //    Adicionando um Sprite
    // 1 - declara um sprite (player) privado e constante
    let player = SKSpriteNode(imageNamed: "fadinha")
    
    
    var superDenteDestroyed = 0
    var dinheiroDestroyed = 0
    var dentePodreDestroyed = 0
    var score = 0
    var background: SKSpriteNode!
    let labelScore = SKLabelNode(fontNamed: "score")
    
    override func didMoveToView(view: SKView) {
        
        background = SKSpriteNode(imageNamed: "background")
        background.name = "background"
        background.size = scene!.size
        background.position = CGPointMake(scene!.size.width/2, scene!.size.height/2)
        scene!.addChild(background)
        
        
        //label score
        
        labelScore.text = "0"
        labelScore.fontSize = 80
        labelScore.fontColor = SKColor.whiteColor()
        labelScore.position = CGPoint(x: size.width/3, y: 700)
        addChild(labelScore)
        
        //label Text score
        let labelTextScore = SKLabelNode(fontNamed: "score")
        labelTextScore.text = "Score"
        labelTextScore.fontSize = 80
        labelTextScore.fontColor = SKColor.whiteColor()
        labelTextScore.position = CGPoint(x: size.width/6, y: 700)
        addChild(labelTextScore)
        // musica do app
        playBackgroundMusic("background-music-aac.caf")
        
        // 2 - seta a cor do background da view
        backgroundColor = SKColor.whiteColor()
        // 3 - posiciona o sprite na cena
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4 - adiciona como um "filho" da cena para fazer aparecer na tela
        addChild(player)

        // seta que não tem gravidade
        physicsWorld.gravity = CGVectorMake(0, 0)
        // seta o delegate
        physicsWorld.contactDelegate = self

        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addSuperDente),
                SKAction.waitForDuration(10.0)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addDente),
                SKAction.waitForDuration(2.0)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addDentePodre),
                SKAction.waitForDuration(6.0)
                ])
            ))
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addSuperDente() {
        
        // Cria um sprite
        let superDente = SKSpriteNode(imageNamed: "superDente")
        
        // Delimita o minimo e o maximo da "criacao" do monstro
        let actualSuperDenteY = random(min: superDente.size.height/2, max: size.height - superDente.size.height/2)
        
        //o monstro é criado fora da tela na area delimitada acima
        superDente.position = CGPoint(x: size.width + superDente.size.width/2, y: actualSuperDenteY)
        
        // Adiciona monstro e banana na cena
        addChild(superDente)
        
        // 1 - cria um physicsBody
        superDente.physicsBody = SKPhysicsBody(rectangleOfSize: superDente.size)
        
        // 2 - a sprit é dinamic, isto é, o movimento não é controlado
        superDente.physicsBody?.dynamic = true
        
        // 3 - define a categoria
        superDente.physicsBody?.categoryBitMask = PhysicsCategory.SuperDente
        
        // 4 - define a categoria que será notificado o contato
        superDente.physicsBody?.contactTestBitMask = PhysicsCategory.Moeda
        
        // 5 - indica a categoria que haverá colisao
        superDente.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determina a velocidade do monstro e da banana
        let actualSuperDenteDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Cria as ações
        let actionMove = SKAction.moveTo(CGPoint(x: -superDente.size.width/2, y: actualSuperDenteY), duration: NSTimeInterval(actualSuperDenteDuration))
        let actionMoveDone = SKAction.removeFromParent()
        //ação de mover o monstro
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            
            // ação de quando perde o jogo
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        superDente.runAction(SKAction.sequence([actionMove, actionMoveDone]))

    }
    
    
    func addDente() {
        
        
        // Cria uma banana
        let dinheiro = SKSpriteNode (imageNamed: "dente")
        
        // Delimita o minimo e o maximo da "criacao" do monstro
        let actualDinheiroY = random(min: dinheiro.size.height/2, max: size.height - dinheiro.size.height/2)
        
        // a banana é criada fora da tela na area delimitada no actualY
        dinheiro.position = CGPoint(x: size.width + dinheiro.size.width, y: actualDinheiroY)
        
        // Adiciona monstro e banana na cena
        addChild(dinheiro)
        
        // 1 - cria um physicsBody
        dinheiro.physicsBody = SKPhysicsBody(rectangleOfSize: dinheiro.size)
        
        // 2 - a sprit é dinamic, isto é, o movimento não é controlado
        dinheiro.physicsBody?.dynamic = true
        
        // 3 - define a categoria
        dinheiro.physicsBody?.categoryBitMask = PhysicsCategory.Dinheiro
        
        // 4 - define a categoria que será notificado o contato
        dinheiro.physicsBody?.contactTestBitMask = PhysicsCategory.Moeda
        
        // 5 - indica a categoria que haverá colisao
        dinheiro.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determina a velocidade do monstro e da banana
        let actualDinheiroDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Cria as ações
        let actionMove = SKAction.moveTo(CGPoint(x: -dinheiro.size.width/2, y: actualDinheiroY), duration: NSTimeInterval(actualDinheiroDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        //ação de mover o monstro
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            
            // ação de quando perde o jogo
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        dinheiro.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }

    func addDentePodre() {
        
        
        // Cria uma dente Podre
        let dentePodre = SKSpriteNode (imageNamed: "dentePodre")
        
        // Delimita o minimo e o maximo da "criacao" do monstro
        let actualDentePodreY = random(min: dentePodre.size.height/2, max: size.height - dentePodre.size.height/2)
        
        // a banana é criada fora da tela na area delimitada no actualY
        dentePodre.position = CGPoint(x: size.width + dentePodre.size.width, y: actualDentePodreY)
        
        // Adiciona monstro e banana na cena
        addChild(dentePodre)
        
        // 1 - cria um physicsBody
        dentePodre.physicsBody = SKPhysicsBody(rectangleOfSize: dentePodre.size)
        
        // 2 - a sprit é dinamic, isto é, o movimento não é controlado
        dentePodre.physicsBody?.dynamic = true
        
        // 3 - define a categoria
        dentePodre.physicsBody?.categoryBitMask = PhysicsCategory.DentePodre
        
        // 4 - define a categoria que será notificado o contato
        dentePodre.physicsBody?.contactTestBitMask = PhysicsCategory.Moeda
        
        // 5 - indica a categoria que haverá colisao
        dentePodre.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determina a velocidade do monstro e da banana
        let actualDentePodreDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Cria as ações
        let actionMove = SKAction.moveTo(CGPoint(x: -dentePodre.size.width/2, y: actualDentePodreY), duration: NSTimeInterval(actualDentePodreDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        //ação de mover o monstro
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            
            // ação de quando perde o jogo
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        dentePodre.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }

    func animarMoeda(moeda: SKSpriteNode, imagens: Array<SKTexture>){
        moeda.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(imagens, timePerFrame: 0.01, resize: false, restore: true)), withKey: "animarMoeda")
        
    }
    

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // musica do app
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - pega o primeiro toque na tela
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - seta a posicao inicial da moeda
        
        var numImages = 10;
        var moedaAnimatedAtlas: SKTextureAtlas = SKTextureAtlas(named: "moeda")
        var imagensMoedaGirando: Array<SKTexture> = []
        
        for ( var i=0; i < numImages; i++){
            var textureName: String = String(format: "moeda%d", arguments: [i])
            var temp: SKTexture = moedaAnimatedAtlas.textureNamed(textureName)
            imagensMoedaGirando.append(temp)
        }
        
        
        var temp: SKTexture = imagensMoedaGirando[0]
        let moeda = SKSpriteNode(texture: temp)
        moeda.position = player.position
       
        moeda.xScale = 1
        moeda.yScale = 1

        animarMoeda(moeda, imagens: imagensMoedaGirando)

        moeda.physicsBody = SKPhysicsBody(circleOfRadius: moeda.size.width/2)
        moeda.physicsBody?.dynamic = true
        moeda.physicsBody?.categoryBitMask = PhysicsCategory.Moeda
        moeda.physicsBody?.contactTestBitMask = PhysicsCategory.SuperDente
        moeda.physicsBody?.contactTestBitMask = PhysicsCategory.Dinheiro
        moeda.physicsBody?.contactTestBitMask = PhysicsCategory.DentePodre
        moeda.physicsBody?.collisionBitMask = PhysicsCategory.None
        moeda.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - determina a distancia do moeda ao toque
        let offset = touchLocation - moeda.position
        
        // 4 - Determina que a bala do moeda só "vai pra frente"
        if (offset.x < 0) { return }
        
        // 5 - adiciona um "filho"
        addChild(moeda)
        
        // 6 - seta a direçao do moeda
        let direction = offset.normalized()
        
        // 7 - seta a distancia do moeda
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + moeda.position
        
        // 9 - cria as ações
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        moeda.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func moedaDidCollideWithSuperDente(moeda:SKSpriteNode, superDente:SKSpriteNode) {
        println("SD")
        moeda.removeFromParent()
        score = score + 5
        labelScore.text = "\(score)"
        if score >= 30 {
            let actionLabel = SKAction.scaleBy(2.5, duration: 1)
            labelScore.runAction(actionLabel, completion: { () -> Void in
                let reveal = SKTransition.flipHorizontalWithDuration(0.01)
                let gameOverScene = GameOverScene(size: self.size, won: true)
                self.view?.presentScene(gameOverScene, transition: reveal)
            })
            
        }
        superDente.removeAllActions()
        let action = SKAction.scaleBy(2.5, duration: 0.2)
        let action2 = SKAction.scaleBy(0.1, duration: 0.3)
        let action3 = SKAction.moveTo(labelScore.position, duration: 0.5)
        superDente.runAction(action, completion: { () -> Void in
            superDente.runAction(action3, completion: { () -> Void in
                superDente.runAction(action2, completion: { () -> Void in
                    superDente.removeFromParent()
                })
            })
        })
    }
    
    func moedaDidCollideWithDinheiro(moeda: SKSpriteNode, dinheiro: SKSpriteNode){
        println("D")
        moeda.removeFromParent()
        dinheiro.removeFromParent()
        score++
        labelScore.text = "\(score)"
        if score >= 30 {
            let reveal = SKTransition.flipHorizontalWithDuration(0.01)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    func moedaDidCollideWithDentePodre(moeda:SKSpriteNode, dentePodre:SKSpriteNode) {
        println("DP")
        moeda.removeFromParent()
        dentePodre.removeFromParent()

        dentePodreDestroyed++
        if dentePodreDestroyed >= 1 {
            let reveal = SKTransition.flipHorizontalWithDuration(0.01)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1 seta os dois corpos que sofrerão contato
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2 Analisa os nós que se chocaram e chama o método da colisão
        if (firstBody.categoryBitMask == PhysicsCategory.Moeda && secondBody.categoryBitMask == PhysicsCategory.SuperDente) {
            //metodo de contato moeda-monstro
            self.moedaDidCollideWithSuperDente(firstBody.node as! SKSpriteNode, superDente: secondBody.node as! SKSpriteNode)
        }
        if (firstBody.categoryBitMask == PhysicsCategory.Moeda && secondBody.categoryBitMask == PhysicsCategory.Dinheiro){
            //metodo pra contato com banana
            self.moedaDidCollideWithDinheiro(firstBody.node as! SKSpriteNode, dinheiro: secondBody.node as! SKSpriteNode)
        }
        if (firstBody.categoryBitMask == PhysicsCategory.Moeda && secondBody.categoryBitMask == PhysicsCategory.DentePodre){
            //metodo pra contato com dente podre
            self.moedaDidCollideWithDentePodre(firstBody.node as! SKSpriteNode, dentePodre: secondBody.node as! SKSpriteNode)
        }
    }
}
