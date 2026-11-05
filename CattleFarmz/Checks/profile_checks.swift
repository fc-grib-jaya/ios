import Foundation

func check(_ condition: Bool, _ message: String) { precondition(condition, message) }
let c = CameraCalibration(fx: 100, fy: 100, cx: 5, cy: 4, width: 10, height: 8)
var d = DepthFrame(width: 10, height: 8, meters: Array(repeating: 1, count: 80), confidence: Array(repeating: 2, count: 80), calibration: c, orientation: .landscapeRight)
for o: CaptureOrientation in [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight] {
    d.orientation = o
    for p in [Point2(0,0), Point2(1,1), Point2(0.23,0.67)] {
        let q = o.displayPoint(fromRaw: o.rawPoint(fromDisplay: p))
        check(abs(p.x-q.x) < 1e-10 && abs(p.y-q.y) < 1e-10, "orientation round trip")
        let profile = try MeasurementEngine.chestProfile(top: p, bottom: p, depth: d)
        let sample = profile.samples[0]
        check(sample.x >= 0 && sample.x < 10 && sample.y >= 0 && sample.y < 8, "edge bounds")
        let actual = try d.point(at: sample.displayPoint)
        check((actual - sample.point!).norm < 1e-10, "pixel center and back projection agree")
    }
    let start = Point2(0.5, 0.5)
    for (dx,dy) in [(-1,0),(1,0),(0,-1),(0,1)] {
        let next = ProfileAnalysis.step(start, dx: dx, dy: dy, depth: d, crop: .full)!
        check(dx == 0 || (next.x-start.x)*Double(dx) > 0, "visual x direction")
        check(dy == 0 || (next.y-start.y)*Double(dy) > 0, "visual y direction")
        let raw1 = o.rawPoint(fromDisplay: start), raw2 = o.rawPoint(fromDisplay: next)
        check(abs(abs(raw2.x-raw1.x)*10 + abs(raw2.y-raw1.y)*8 - 1) < 1e-10, "one depth pixel")
    }
}
d.orientation = .landscapeRight
let a = Point2(0.55,0.01), b = Point2(0.55,0.99)
let full = try MeasurementEngine.chestProfile(top:a,bottom:b,depth:d)
check(Set(full.samples.map { $0.y * 10 + $0.x }).count == full.samples.count, "unique pixels")
check(ProfileAnalysis.complete(full), "complete original")
d.confidence[3*10+5] = 0
let partial = try MeasurementEngine.chestProfile(top:a,bottom:b,depth:d)
check(!ProfileAnalysis.complete(partial), "partial excluded")
let sections = ProfileAnalysis.segments(partial)
check(sections.count == 2, "gap splits segments before decimation")
for step in 1...3 {
    var sum = 0.0
    for segment in sections {
        var selected = stride(from:0,to:segment.count,by:step).map { segment[$0] }
        if (segment.count-1)%step != 0 { selected.append(segment.last!) }
        sum += ProfileAnalysis.length(selected)
    }
    check(abs(sum - partial.lengthCM!) < 1e-8, "strides preserve collinear lengths without bridging gap")
}
check(abs(ProfileAnalysis.length([Vector3(0,0,0),Vector3(1,0,0)]) - ProfileAnalysis.length([Vector3(0,0,0),Vector3(0.2,0,0),Vector3(1,0,0)])) < 1e-10, "collinear insertion")
let report = try ProfileAnalysis.report(top:a,bottom:b,depth:d,crop:.full)
check(a == Point2(0.55,0.01) && b == Point2(0.55,0.99), "analysis does not mutate endpoints")
check(report.contains("Rentang tidak tersedia"), "partial baseline never pooled with complete variations")
let crop = ImageCrop.matchingPreview(imageSize: CGSize(width:1920,height:1440),viewportSize:CGSize(width:800,height:400))
let screen = Point2(0.3,0.7)
let photo = Point2(crop.x+screen.x*crop.width,crop.y+screen.y*crop.height)
check(abs((photo.x-crop.x)/crop.width-screen.x)<1e-10 && abs((photo.y-crop.y)/crop.height-screen.y)<1e-10, "crop round trip")
print("PASS: geometry, crop, orientation, pixel centers, steps, bounds, uniqueness, gaps, strides, collinearity, sensitivity coverage")

var revision = LandmarkRevision()
let old = revision.value
revision.advance()
check(!revision.accepts(old) && revision.accepts(revision.value), "stale computation rejected")
print("PASS: stale result revision gate")
