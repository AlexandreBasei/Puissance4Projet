import UIKit

class Pui4ViewController: UIViewController {
    var nbPlayer = 1
    var currPlayer = 1
    var Grille: [[Int]] = Array(repeating: Array(repeating: 0, count: 7), count: 6)
    var lastCoin: (Int, Int) = (-1, -1)
    var lastAiCoin: (Int, Int) = (-1, -1)
    
    let directions: [(Int, Int)] = [(0, -1), (-1, -1), (-1, 0), (1, -1)] // gauche, diagonale gh, haut, diagonale droite-haut
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var grilleImage: UIImageView!
    
    @IBAction func insertCoin(_ sender: UIButton) {
        if let result = mettreJeton(col: sender.tag) {
            animJeton(colonne: result.1, ligne: result.0, couleur: currPlayer)
            
            if checkAlignements(cible: 4, player: currPlayer, coin: result) {
                print("Joueur \(currPlayer) a gagné")
                buttons.forEach { $0.isEnabled = false }
                return
            }
            
            currPlayer = (currPlayer == 1) ? 2 : 1
            
            if nbPlayer == 1 && currPlayer == 2 {
                iaJouer()
            }
        }
    }
    
    func iaJouer() {
        buttons.forEach { $0.isEnabled = false }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            let strategies = [3, 2, 1]
            var door = true
            
            for cible in strategies {
                if let move = trouverCoupIntelligent(player: 2, cible: cible) {
                    jouerIa(move: move)
                    door = false
                    break
                }
            }
            
            if door {
                jouerIa(move: Int.random(in: 0...6))
            }
            
            buttons.forEach { $0.isEnabled = true }
        }
    }
    
    func trouverCoupIntelligent(player: Int, cible: Int) -> Int? {
        
        return nil
    }
    
    func jouerIa(move: Int) {
        if let result = mettreJeton(col: move) {
            animJeton(colonne: result.1, ligne: result.0, couleur: currPlayer)
            lastAiCoin = result
            currPlayer = (currPlayer == 1) ? 2 : 1
        }
    }
    
    func checkAlignements(cible: Int, player: Int, coin: (Int, Int)) -> Bool {
        return directions.contains { dir in
            let total = 1 + compterAlignes(player: player, coin: coin, dir: dir) + compterAlignes(player: player, coin: coin, dir: (-dir.0, -dir.1))
            return total >= cible
        }
    }
    
    func compterAlignes(player: Int, coin: (Int, Int), dir: (Int, Int)) -> Int {
        var count = 0
        var (y, x) = coin
        
        while y >= 0, y < 6, x >= 0, x < 7, Grille[y][x] == player {
            count += 1
            y += dir.1
            x += dir.0
        }
        return count - 1
    }
    
    func mettreJeton(col: Int, simulate: Bool = false) -> (Int, Int)? {
        for row in (0..<6).reversed() {
            if Grille[row][col] == 0 {
                if !simulate {
                    Grille[row][col] = currPlayer
                    lastCoin = (row, col)
                }
                return (row, col)
            }
        }
        return nil
    }
    
    func animJeton(colonne: Int, ligne: Int, couleur: Int) {
        let tailleJeton: CGFloat = 40
        let startX = CGFloat(colonne) * (tailleJeton + 5.8) + 40
        let startY: CGFloat = 260
        let jeton = UIImageView(image: UIImage(named: "CoinJ" + String(couleur)))
        jeton.frame = CGRect(x: startX, y: startY, width: tailleJeton, height: tailleJeton)
        self.view.insertSubview(jeton, belowSubview: grilleImage)
        let finalY = CGFloat(ligne) * (tailleJeton + 6) + 308
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {
            jeton.frame.origin.y = finalY
        } completion: { _ in
            print("Jeton inséré en (\(ligne), \(colonne))")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
