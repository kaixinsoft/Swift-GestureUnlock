import UIKit

enum CircleState{
    case Normal, Selected, Error, LSelected, LError
    
    static let white = CircleState.rgba(241, g: 241, b: 241, a: 1.0)
    static let blue = CircleState.rgba(34, g: 178, b: 246, a: 1.0)
    static let red = CircleState.rgba(254, g: 82, b: 92, a: 1.0)
    static let tra = UIColor.clearColor()
    
    func getOutColor()->UIColor {
        switch self {
        case .Normal:
            return CircleState.white
        case .Selected:
            return CircleState.blue
        case .Error:
            return CircleState.red
        case .LSelected:
            return CircleState.blue
        case .LError:
            return CircleState.red
        default:
            return CircleState.tra
        }
    }
    func getInColor()->UIColor {
        switch self {
        case .Normal:
            return CircleState.tra
//        case .Selected:
//            return CircleState.blue
//        case .Error:
//            return CircleState.rgba(254, g: 82, b: 92, a: 1.0)
//        case .LSelected:
//            return CircleState.rgba(34, g: 178, b: 246, a: 1.0)
//        case .LError:
//            return CircleState.rgba(254, g: 82, b: 92, a: 1.0)
        default:
            return getOutColor()
        }
    }
    func getTrColor()->UIColor {
        switch self {
//        case .Normal:
//            return CircleState.tra
//        case .Selected:
//            return CircleState.rgba(34, g: 178, b: 246, a: 1.0)
//        case .Error:
//            return CircleState.rgba(254, g: 82, b: 92, a: 1.0)
        case .LSelected:
            return CircleState.tra
        case .LError:
            return CircleState.tra
        default:
            return getInColor()
        }
    }
    static func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}

class Circle: UIView {
    // 外圆线宽
    static let edgeWidthRadio: CGFloat = 0.02 //取圆直径的百分比
    static let inRadio: CGFloat = 0.4 //取内圆占外圆的百分比
    static let trPosRadio: CGFloat = 0.8 //以圆心为中心，偏移半径的百分比
    static let trLenRadio: CGFloat = 0.4 //同上
    var state: CircleState = CircleState.Normal {
        didSet{
            self.setNeedsDisplay()
        }
    }
    var angle: CGFloat = 0
    var row: Int!
    var col: Int!

    init(){
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.clearColor()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// mark - 设置angle
extension Circle{
    func setAagle(nextCircle: Circle){
        var lhs = nextCircle.col - self.col
        var rhs = nextCircle.row - self.row
        angle = atan2(CGFloat(lhs), CGFloat(rhs)) + CGFloat(M_PI_2)
    }
}
// mark - 画图形
extension Circle{
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        transformCtx(ctx, rect: rect)
        drawOutCircle(ctx, rect: rect)
        drawInCircle(ctx, rect: rect)
        drawTrangle(ctx, rect: rect)
    }
    // 中心旋转
    func transformCtx(ctx: CGContextRef, rect: CGRect){
        let len = rect.width / 2
        CGContextTranslateCTM(ctx, len, len)
        CGContextRotateCTM(ctx, angle)
        CGContextTranslateCTM(ctx, -len, -len)
    }
    // 绘制外圆
    func drawOutCircle(ctx: CGContextRef, rect: CGRect){
        let len = rect.width
        let edgeWidth = len * Circle.edgeWidthRadio
        // 注意ios绘制的线是，内外以path为分割各一半，于是edgeWidth要取一半...可以调大edgeWidth试下
        var circleRect = CGRect(
            x: edgeWidth / 2,
            y: edgeWidth / 2,
            width: len - edgeWidth,
            height: len - edgeWidth)
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, edgeWidth)
        state.getOutColor().set()
        CGContextStrokePath(ctx)
    }
    // 绘制内圆，且实心
    func drawInCircle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        var len = rect.width * Circle.inRadio / 2
        var start = rect.width / 2 - len
        var circleRect = CGRect(
            x: start,
            y: start,
            width: len * 2,
            height: len * 2)
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        state.getInColor().set()
        CGContextFillPath(ctx)
    }
    // 绘制三角形
    func drawTrangle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        var len = rect.size.width / 2 * Circle.trLenRadio
        var startX = rect.size.width / 2
        var startY = rect.size.width / 2 * (1.0 - Circle.trPosRadio)
        CGPathMoveToPoint(path, nil, startX, startY);
        CGPathAddLineToPoint(path, nil, startX - len/2, startY + len/2);
        CGPathAddLineToPoint(path, nil, startX + len/2, startY + len/2);
        CGContextAddPath(ctx, path);
        state.getTrColor().set()
        CGContextFillPath(ctx);
    }
}

