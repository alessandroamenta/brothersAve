//
//  CardsCollectionCell.swift
//  Food App
//
//  Created by HF on 02/01/2023.
//

import UIKit

class CardsCollectionCell: UICollectionViewCell {

    // MARK: - Outlets...
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var deleteBtn: UIImageView!
    @IBOutlet weak var deleteActionBtn: UIButton!
    
    var identifier = "CardsCollectionCell"
    var delegate: AllCardsVC?
    
    var data: PaymentMethodResponse? {
        didSet {
            guard let data = data?.card else { return }
            if data.brand == "mastercard" { cardImageView.setImage(image: "logoMastercard") } else { cardImageView.setImage(image: "logoVisa") }
            cardNumber.text = "••••••••••••\(data.last4 ?? "0000")"
        }
    }
    
    // MARK: - Cell init method...
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
  
    @IBAction func DeleteBtnAction(_ sender: Any) {
        guard let data = data else { return }
        delegate?.didTapOnDeleteCardBtn(card: data)
    }

}
