//
//  SearchCountriesViewController.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import UIKit
import SVGKit

class SearchCountriesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var searchCountriesViewModel : SearchCountriesViewModel = {
        return SearchCountriesViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        self.setupBindings()
        self.searchCountriesViewModel.initFetch(searchText: nil, searchType: nil)
    }
    
    func setupSearchController() {
        
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.scopeButtonTitles = ["Name", "Capital", "Language", "Region", "Currency"]
    }
    
    func setupBindings() {
        self.searchCountriesViewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if (self?.searchCountriesViewModel.numberOfCells ?? 0) > 0 {
                    self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }
            }
        }
        
        self.searchCountriesViewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.searchCountriesViewModel.isLoading ?? false
                
                if isLoading {
                    self?.activityIndicator?.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator?.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 1.0
                    })
                }
            }
        }
        
        self.searchCountriesViewModel.showAlertMessage = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.searchCountriesViewModel.alertMessage {
                    self?.collectionView.setMessage(message: message)
                }
            }
        }
    }
    
    func filterSearchController(_ searchBar: UISearchBar) {
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        print(scopeString)
        let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        self.searchCountriesViewModel.initFetch(searchText: searchText, searchType: scopeString)
    }
    
    //    func showAlertMessage(message: String) {
    //        self.collectionView.setMessage(message: message)
    //    }
}

extension SearchCountriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.searchCountriesViewModel.numberOfCells > 0) {
            self.collectionView.restore()
        }
        return self.searchCountriesViewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! SearchCountriesCollectionViewCell
        
        let cellViewModel = self.searchCountriesViewModel.cellviewmodels[indexPath.row]
        
        ImageLoader.image(for: cellViewModel.countryFlag_url) { image in
            if let image = image  {
                cell.countryFlagImageView.image = image
            }
        }
        
        cell.countryNameLabel.text = cellViewModel.countryName
        cell.countryPopulationLabel.text = cellViewModel.countryPopulation
        cell.countryAreaLabel.text = cellViewModel.countryArea
        return cell
    }
}

extension SearchCountriesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterSearchController(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchCountriesViewModel.isLoading = false
        
        searchBar.text = ""
        searchBar.placeholder = "Search countries"
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        switch selectedScope {
        case 0:
            searchBar.placeholder = "Search by name"
        case 1:
            searchBar.placeholder = "Search by capital"
        case 2:
            searchBar.placeholder = "Search by language"
        case 3:
            searchBar.placeholder = "Search by region"
        case 4:
            searchBar.placeholder = "Search by currency"
        default:
            searchBar.placeholder = "Search countries"
        }
    }
}

extension UICollectionView {
    func setMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        messageLabel.isHidden = false
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

