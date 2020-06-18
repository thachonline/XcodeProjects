//
//  ViewController.swift
//  OpenStreetMapTest
//
//  Created by Bondar Yaroslav on 6/18/20.
//  Copyright © 2020 Bondar Yaroslav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

final class OSMMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        let template = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        addOverlay(overlay, level: .aboveLabels)
        //let tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        delegate = self
        
    }
    
}

extension OSMMapView: MKMapViewDelegate {
    
    /// called once
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        } else {
            assertionFailure()
            return MKOverlayRenderer()
        }
    }
}