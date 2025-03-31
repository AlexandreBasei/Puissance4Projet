//
//  ViewController.swift
//  Puissance4Projet
//
//  Created by Alexandre Basei on 20/03/2025.
//

import UIKit

class ViewController: UIViewController {

    var joueurs = -1
    var difficulty = -1
    var jouer = false
    
    @IBOutlet weak var btn_player: UIButton!
    
    
    @IBOutlet weak var btn_difficulty: UIButton!
    
    
    @IBOutlet weak var btnJouer: UIButton!
    
    
    @IBAction func playerNumberSelection (_ sender : UIAction) {
        print(sender.title)
        
        if sender.title == "1 joueur (vs IA)" {
            btn_difficulty.isHidden = false
            self.btn_player.setTitle(sender.title, for: .normal)
            joueurs = 1
            btnJouer.isEnabled = false
            btnJouer.layer.opacity = 0.7
        }
        else if sender.title == "2 joueurs" {
            btn_difficulty.isHidden = true
            self.btn_player.setTitle(sender.title, for: .normal)
            joueurs = 2
            btnJouer.isEnabled = true
            btnJouer.layer.opacity = 1
            difficulty = -1
            self.btn_difficulty.setTitle("Difficulté", for: .normal)
        }
        else if sender.title == "Facile" {
            self.btn_difficulty.setTitle(sender.title, for: .normal)
            difficulty = 1
            btnJouer.isEnabled = true
            btnJouer.layer.opacity = 1
        }
        else if sender.title == "Difficile" {
            self.btn_difficulty.setTitle(sender.title, for: .normal)
            difficulty = 3
            btnJouer.isEnabled = true
            btnJouer.layer.opacity = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btn_player.layer.cornerRadius = 10
        btn_difficulty.layer.cornerRadius = 10
        btn_difficulty.isHidden = true
        
        btnJouer.isEnabled = false
        btnJouer.layer.opacity = 0.7
    }

    @IBAction func jouer(_ sender: Any) {
        jouer = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let dest = segue.destination as! Pui4ViewController
    
        if jouer {
            dest.nbPlayer = joueurs
            dest.difficulté = difficulty
        }
    }


}

