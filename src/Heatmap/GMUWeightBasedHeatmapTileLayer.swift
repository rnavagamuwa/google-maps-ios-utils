//
//  GMUWeightBasedHeatmapTileLayer.swift
//  GoogleMapsUtils
//
//  Created by Admin on 06/01/2018.
//  Copyright © 2018 Google. All rights reserved.
//

import Foundation
import GoogleMaps

class GMUWeightBasedHeatmapTileLayer: GMSSyncTileLayer {
    
    let DEFAULT_RADIUS = 20
    let DEFAULT_OPACITY: CGFloat = 0.7
    let DEFAULT_GRADIENT_COLORS = [UIColor(red: CGFloat(102.0/255.0), green: CGFloat(225.0/255.0), blue: CGFloat(0/255.0), alpha: 1), UIColor(red: CGFloat(255.0/255.0), green: 0.0, blue: 0.0, alpha: 1)]
    let DEFAULT_GRADIENT_START_POINTS = [0.2, 1.0]
    var DEFAULT_GRADIENT: GMUGradient
    let WORLD_WIDTH = 1.0
    let TILE_DIM = 512
    let SCREEN_SIZE = 1280
    let DEFAULT_MIN_ZOOM = 5
    let DEFAULT_MAX_ZOOM = 11
    let MAX_ZOOM_LEVEL = 22
    let MIN_RADIUS = 10
    let DEFAULT_GRADIENT_SMOOTHING = 10.0
    let DEFAULT_MAX_INTENSITY = 0
    let kCGImageAlphaLast = CGImageAlphaInfo.last
    
    var mData: [GMUWeightedLatLng]
    var mTree: GQTPointQuadTree
    var mBounds: GQTBounds
    var mRadius: Int
    var mGradient: GMUGradient
    var mColorMap: [UIColor]
    var mOpacity: CGFloat
    var mMaxIntensity: [Double]
    var staticMaxIntensity: Double? = nil
    var mGradientSmoothing: Double
    
    struct PixelData {
        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    init(weightedData: [GMUWeightedLatLng]) {
        self.DEFAULT_GRADIENT = GMUGradient(colors: DEFAULT_GRADIENT_COLORS, startPoints: DEFAULT_GRADIENT_START_POINTS as [NSNumber], colorMapSize: 1000)
        mData = weightedData
        mRadius = DEFAULT_RADIUS
        mGradient = DEFAULT_GRADIENT
        mOpacity = DEFAULT_OPACITY
        mGradientSmoothing = DEFAULT_GRADIENT_SMOOTHING
        mTree = GQTPointQuadTree.init()
        mBounds = GQTBounds.init()
        mColorMap = []
        mMaxIntensity = []
        super.init()
        super.tileSize = TILE_DIM
        setGradient(gradient: mGradient)
        setWeightedData(data: mData)
    }
    
    func setMap(map: GMSMapView) -> Void {
        super.map = map
    }
    
    func getMaxIntensities(radius: Int) -> [Double] {
        let maxIntensityArray = [Double]()
        if(staticMaxIntensity == nil) {
            // to do
        }
        return maxIntensityArray;
    }
    
    func getBounds(points: [GMUWeightedLatLng]) -> GQTBounds {
        var result = GQTBounds()
        result.minX = 0
        result.minY = 0
        result.maxX = 0
        result.maxY = 0
        if (points.count == 0) {
            return result;
        }
        var point = points[0]
        result.minX = point.point().x
        result.maxX = point.point().x
        result.minY = point.point().y
        result.maxY = point.point().y
        if(points.count > 1) {
            for i in 1...points.count-1 {
                point = points[i]
                if (result.minX > point.point().x) {
                    result.minX = point.point().x
                }
                if (result.maxX < point.point().x) {
                    result.maxX = point.point().x
                }
                if (result.minY > point.point().y) {
                    result.minY = point.point().y
                }
                if (result.maxY < point.point().y) {
                    result.maxY = point.point().y
                }
            }
        }
        
        return result;
    }
    
    func setWeightedData(data: [GMUWeightedLatLng]) -> Void {
        mData = data
        mBounds = getBounds(points: mData)
        mTree = GQTPointQuadTree(bounds: mBounds)
        for l in mData {
            mTree.add(l)
        }
        mMaxIntensity = getMaxIntensities(radius: mRadius)
    }
    
    func setGradient(gradient: GMUGradient) -> Void {
        mGradient = gradient
        mColorMap = gradient.generateColorMap()
    }
    
    func calculateDistance(x1: Int, y1: Int, x2: Int, y2: Int) -> Double {
        let dx = x1 - x2
        let dy = y1 - y2
        return sqrt(Double(dx * dx + dy * dy))
    }
    
    func calculateIntensity(distance: Double) -> Double {
        return exp(Double(-distance * distance) / Double(mRadius/3 * mRadius/3 * 2))
    }
    
    func mergeHeatmapPoints(heatmapPoint1: HeatmapPoint, heatmapPoint2: HeatmapPoint) -> HeatmapPoint {
        let newWeight = weightedAverage(pointWeight1: heatmapPoint1.weight, pointWeight2: heatmapPoint2.weight, pointIntensity1: heatmapPoint1.intensity, pointIntensity2: heatmapPoint2.intensity)
        let newIntensity = max(heatmapPoint1.intensity, heatmapPoint2.intensity)
        return HeatmapPoint(intensity: newIntensity, weight: newWeight)
    }
    
    func weightedAverage(pointWeight1: Double, pointWeight2: Double, pointIntensity1: Double, pointIntensity2: Double) -> Double {
        return ((pointIntensity1 * pointWeight1) + (pointIntensity2 * pointWeight2)) / (pointIntensity1 + pointIntensity2)
    }
    
    override func tileFor(x: UInt, y: UInt, zoom: UInt) -> UIImage? {
        
        let tileWidth = 2.0 / pow(2.0, Double(zoom))
        
        let minX = -1 + Double(x) * tileWidth
        let minY = 1 - Double(y + 1) * tileWidth
        
        let padding = Double(mRadius) * tileWidth / Double(TILE_DIM)
        
        let minXextended = -1 + Double(x) * tileWidth - padding
        let maxXextended = -1 + Double(x + 1) * tileWidth + padding;
        let minYextended = 1 - Double(y + 1) * tileWidth - padding;
        let maxYextended = 1 - Double(y) * tileWidth + padding;
        
        let tileExtendedBounds = GQTBounds(minX: minXextended, minY: minYextended, maxX: maxXextended, maxY: maxYextended)
        
        // let paddedBounds = GQTBounds(minX: mBounds.minX - padding, minY: mBounds.minY - padding, maxX: mBounds.maxX + padding, maxY: mBounds.maxY + padding)
        
        let points = mTree.search(with: tileExtendedBounds)
        
        if(points?.isEmpty ?? true) {
            return kGMSTileLayerNoTile
        }
        
        var tileGrid: Array<Array<HeatmapPoint?>> = Array(repeating: Array(repeating: nil, count: TILE_DIM), count: TILE_DIM)

        let middle = mRadius - 1
        
        for rawpoint in points! {
            let point = rawpoint as! GMUWeightedLatLng
            let pointWeight = Double(point.intensity)

            let pointGridX = Int(((point.point().x - minX) * Double(TILE_DIM)) / tileWidth)
            let pointGridY = Int(((point.point().y - minY) * Double(TILE_DIM)) / tileWidth)

            var iStart = 0
            var iEnd = 2 * mRadius
            var jStart = 0
            var jEnd = 2 * mRadius

            if (pointGridX - mRadius < 0) {
                iStart = mRadius - pointGridX;
            }

            if (pointGridX + mRadius > TILE_DIM) {
                iEnd = mRadius - (pointGridX - TILE_DIM);
            }

            if (pointGridY - mRadius < 0) {
                jStart = mRadius - pointGridY;
            }

            if (pointGridY + mRadius > TILE_DIM) {
                jEnd = mRadius - (pointGridY - TILE_DIM);
            }

            for i in iStart...iEnd-1 {
                for j in jStart...jEnd-1 {
                    let distanceToPoint = calculateDistance(x1: i, y1: j, x2: middle, y2: middle)
                    let intensity = calculateIntensity(distance: distanceToPoint)
                    let weight = max((intensity * mGradientSmoothing) + (pointWeight - mGradientSmoothing), 1.0)

                    let tileXIndex = (i - middle) + pointGridX - 1
                    let tileYIndex = (j - middle) + pointGridY - 1

                    if(intensity > 0.01) {
                        let newPoint = HeatmapPoint(intensity: intensity, weight: weight)
                        if(tileGrid[tileXIndex][tileYIndex] != nil) {
                            tileGrid[tileXIndex][tileYIndex] = mergeHeatmapPoints(heatmapPoint1: tileGrid[tileXIndex][tileYIndex]!, heatmapPoint2: newPoint)
                        } else {
                            tileGrid[tileXIndex][tileYIndex] = newPoint
                        }
                    }
                }
            }
        }
        
        var maxValue: Double

        if(staticMaxIntensity != nil) {
            maxValue = staticMaxIntensity!
        } else {
            maxValue = mMaxIntensity[Int(zoom)]
        }
        
        let rawpixels = colorize(grid: tileGrid, colorMap: mColorMap, max: maxValue)
        
        return imageFromBitmap(pixels: rawpixels, width: TILE_DIM, height: TILE_DIM)
    }
    
    func setRadius(radius: Int) -> Void {
        mRadius = radius
        mMaxIntensity = getMaxIntensities(radius: mRadius)
    }
    
    func setOpacity(opacity: CGFloat) -> Void {
        mOpacity = opacity
    }
    
    func setMaxIntensity(maxIntensity: Double) -> Void {
        staticMaxIntensity = maxIntensity
    }
    
    func colorize(grid: Array<Array<HeatmapPoint?>>, colorMap: [UIColor], max: Double) -> [PixelData] {
        
        let maxColor = colorMap[colorMap.count - 1]
        let colorMapScaling = Double(colorMap.count - 1) / max
        let dim = grid.count
    
        var colors: Array<PixelData> = Array(repeating: PixelData(a: 0, r: 0, g: 0, b: 0), count: dim * dim)
        
        for y in (0...dim-1).reversed() {
            for x in (0...dim-1) {
                let point = grid[x][y]
                let index = (dim - y - 1) * dim + x

                if(point != nil) {
                    let col = Int(point!.weight * colorMapScaling)
                    let transparency = CGFloat(CGFloat(point!.intensity) * mOpacity)
                    var chosenColor: UIColor
                    if(col < colorMap.count) {
                        chosenColor = colorMap[col].withAlphaComponent(transparency)
                    } else {
                        chosenColor = maxColor.withAlphaComponent(transparency)
                    }
                    
                    let components = chosenColor.cgColor.components
                    let r = UInt8(components![0] * 255)
                    let g = UInt8(components![1] * 255)
                    let b = UInt8(components![2] * 255)
                    let a = UInt8(components![3] * 255)

                    colors[index] = PixelData(a: a, r: r, g: g, b: b)
                }
            }
        }
        return colors
    }
    
    func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        let pixelDataSize = MemoryLayout<PixelData>.size
        
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
}

class HeatmapPoint {
    var intensity: Double
    var weight: Double
    
    init(intensity: Double, weight: Double) {
        self.intensity = intensity
        self.weight = weight
    }
}
