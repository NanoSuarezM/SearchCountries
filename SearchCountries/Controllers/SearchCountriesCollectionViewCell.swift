//
//  SearchCountriesCollectionViewCell.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import UIKit

class SearchCountriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var countryPopulationLabel: UILabel!
    @IBOutlet weak var countryAreaLabel: UILabel!
    
    override func prepareForReuse() {
        
        countryFlagImageView.image = nil
        
        super.prepareForReuse()
    }
    
}

// MARK: Accessibility
extension SearchCountriesCollectionViewCell {
    func applyAccessibility(_ cellViewModel: SearchCountriesCellViewModel) {
        countryFlagImageView.isAccessibilityElement = true
        countryFlagImageView.accessibilityTraits = UIAccessibilityTraits.image
        countryFlagImageView.accessibilityLabel = "Flag of \(cellViewModel.countryName)"
        
        countryNameLabel.isAccessibilityElement = true
        countryPopulationLabel.isAccessibilityElement = true
        countryAreaLabel.isAccessibilityElement = true
        
    }
}

