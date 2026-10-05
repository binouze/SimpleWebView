//
//  SmartWKWebViewToolbar.swift
//  Pods-SmartWKWebView_Example
//
//  Created by Baris Atamer on 12/26/17.
//

import UIKit

// Toolbar construite en code, a l'identique de l'ancien SmartWKWebViewToolbar.xib (memes vues, couleurs,
// polices et contraintes). Les sources Swift etant compilees dans UnityFramework, un .xib ou un .xcassets
// ne serait pas embarque (et Bundle(for:) ne pointerait plus sur le framework) : plus aucune ressource,
// les icones sont des SF Symbols.
class SmartWKWebViewToolbar: UIView
{
    // MARK: - Private properties

    private let contentView = UIView()
    let titleLabel          = UILabel()
    let addressLabel        = UILabel()
    let closeButton         = UIButton(type: .custom)
    let backButton          = UIButton(type: .custom)

    public var progressView:  UIProgressView!

    // MARK: - Initializer

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }

    // MARK: - Private Methods

    private func commonInit()
    {
        construireContenu()

        addSubview(contentView)
        contentView.frame = self.bounds

        addProgressView()
        backButton.isHidden = true;
    }

    // contenu de l'ancien .xib : fond blanc, bordure basse grise de 1 pt, et de gauche a droite un bloc
    // de 60 pt (bouton retour), le bloc central (titre + adresse) et un bloc de 60 pt (bouton fermer)
    private func construireContenu()
    {
        // le gris du .xib (calibratedWhite 0.667) une fois converti par IB : 0.723366 a l'execution
        let gris = UIColor(white: 0.723366, alpha: 1)

        contentView.backgroundColor = UIColor.white

        let bordureBasse = UIView()
        bordureBasse.backgroundColor = gris

        let blocGauche = UIView()
        let blocCentre = UIView()
        let blocLabels = UIView()
        blocLabels.backgroundColor = UIColor.clear
        let blocDroite = UIView()
        blocDroite.backgroundColor = UIColor.clear

        // « boldSystem » du .xib = SF Bold ; UIFont.boldSystemFont renverrait du Semibold
        configurerLabel(titleLabel,   texte: "Title",   police: UIFont.systemFont(ofSize: 14, weight: .bold))
        configurerLabel(addressLabel, texte: "http://", police: UIFont.systemFont(ofSize: 11))
        addressLabel.textColor = gris

        configurerBouton(backButton,  symbole: "chevron.left", taille: 16)
        configurerBouton(closeButton, symbole: "xmark",        taille: 17)

        for v in [bordureBasse, blocGauche, blocCentre, blocDroite, blocLabels, titleLabel, addressLabel, backButton, closeButton]
        {
            v.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(bordureBasse)
        contentView.addSubview(blocGauche)
        contentView.addSubview(blocCentre)
        contentView.addSubview(blocDroite)
        blocGauche.addSubview(backButton)
        blocCentre.addSubview(blocLabels)
        blocLabels.addSubview(titleLabel)
        blocLabels.addSubview(addressLabel)
        blocDroite.addSubview(closeButton)

        NSLayoutConstraint.activate([
            bordureBasse.heightAnchor.constraint(equalToConstant: 1),
            bordureBasse.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bordureBasse.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bordureBasse.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            blocGauche.widthAnchor.constraint(equalToConstant: 60),
            blocGauche.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blocGauche.topAnchor.constraint(equalTo: contentView.topAnchor),
            blocGauche.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: blocGauche.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: blocGauche.centerYAnchor),

            blocCentre.leadingAnchor.constraint(equalTo: blocGauche.trailingAnchor),
            blocCentre.trailingAnchor.constraint(equalTo: blocDroite.leadingAnchor),
            blocCentre.topAnchor.constraint(equalTo: contentView.topAnchor),
            blocCentre.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            blocLabels.heightAnchor.constraint(equalToConstant: 29),
            blocLabels.leadingAnchor.constraint(equalTo: blocCentre.leadingAnchor),
            blocLabels.trailingAnchor.constraint(equalTo: blocCentre.trailingAnchor),
            blocLabels.centerYAnchor.constraint(equalTo: blocCentre.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: blocLabels.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: blocLabels.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: blocLabels.topAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 13),
            addressLabel.leadingAnchor.constraint(equalTo: blocLabels.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: blocLabels.trailingAnchor),
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            blocDroite.widthAnchor.constraint(equalToConstant: 60),
            blocDroite.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blocDroite.topAnchor.constraint(equalTo: contentView.topAnchor),
            blocDroite.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.leadingAnchor.constraint(equalTo: blocDroite.layoutMarginsGuide.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: blocDroite.centerYAnchor),
        ])
    }

    private func configurerLabel(_ label: UILabel, texte: String, police: UIFont)
    {
        label.text          = texte
        label.font          = police
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.isOpaque      = false
        label.contentMode   = .left
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
    }

    // SF Symbol a la place des anciennes icones ic_back / ic_close, teinte en noir comme avant. Tailles
    // mesurees pour retrouver leurs glyphes : 14 pt de haut (croix 14 x 14, chevron 8 x 14), trait de ~2 pt
    private func configurerBouton(_ bouton: UIButton, symbole: String, taille: CGFloat)
    {
        let config = UIImage.SymbolConfiguration(pointSize: taille, weight: .semibold)
        bouton.setImage(UIImage(systemName: symbole, withConfiguration: config), for: .normal)
        bouton.tintColor = UIColor.black
        bouton.isOpaque  = false
    }

    func addProgressView()
    {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        addSubview(progressView)
    }

    override func layoutSubviews()
    {
        progressView.frame = CGRect(x: 0,
                                    y: bounds.height - 1,
                                width: bounds.width,
                               height: 1)

        contentView.frame = self.bounds
        round(corners: [.topLeft, .topRight], radius: 20)
    }

    func round(corners: UIRectCorner, radius: Int)
    {
        let rectShape      = CAShapeLayer()
        rectShape.bounds   = self.frame
        rectShape.position = self.center
        rectShape.path     = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                          cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = rectShape
    }
}
