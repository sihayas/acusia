//
//  TailPath.swift
//  acusia
//
//  Created by decoherence on 8/29/24.
//

import SwiftUI

// A way to mask/clip the avatar so I can tuck a song underneath it.
struct AvatarPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.89526*width, y: 0.66388*height))
        path.addCurve(to: CGPoint(x: 0.999*width, y: 0.54548*height), control1: CGPoint(x: 0.94935*width, y: 0.64615*height), control2: CGPoint(x: 0.99544*width, y: 0.6036*height))
        path.addCurve(to: CGPoint(x: width, y: 0.51282*height), control1: CGPoint(x: 0.99967*width, y: 0.53468*height), control2: CGPoint(x: width, y: 0.52379*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: width, y: 0.2296*height), control2: CGPoint(x: 0.77614*width, y: 0))
        path.addCurve(to: CGPoint(x: 0, y: 0.51282*height), control1: CGPoint(x: 0.22386*width, y: 0), control2: CGPoint(x: 0, y: 0.2296*height))
        path.addCurve(to: CGPoint(x: 0.31802*width, y: 0.99062*height), control1: CGPoint(x: 0, y: 0.73019*height), control2: CGPoint(x: 0.13186*width, y: 0.91598*height))
        path.addCurve(to: CGPoint(x: 0.46601*width, y: 0.94444*height), control1: CGPoint(x: 0.37071*width, y: 1.01174*height), control2: CGPoint(x: 0.42759*width, y: 0.98701*height))
        path.addCurve(to: CGPoint(x: 0.89526*width, y: 0.66388*height), control1: CGPoint(x: 0.58177*width, y: 0.8162*height), control2: CGPoint(x: 0.72906*width, y: 0.71836*height))
        path.closeSubpath()
        return path
    }
}

// A way to mask/clip artwork so I can tuck a rating underneath it.
struct ArtifactPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: width, y: 0.21099*height))
        path.addCurve(to: CGPoint(x: 0.98563*width, y: 0.072*height), control1: CGPoint(x: width, y: 0.13714*height), control2: CGPoint(x: width, y: 0.10021*height))
        path.addCurve(to: CGPoint(x: 0.928*width, y: 0.01437*height), control1: CGPoint(x: 0.97298*width, y: 0.04719*height), control2: CGPoint(x: 0.95281*width, y: 0.02702*height))
        path.addCurve(to: CGPoint(x: 0.78901*width, y: 0), control1: CGPoint(x: 0.89979*width, y: 0), control2: CGPoint(x: 0.86286*width, y: 0))
        path.addLine(to: CGPoint(x: 0.21099*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.072*width, y: 0.01437*height), control1: CGPoint(x: 0.13714*width, y: 0), control2: CGPoint(x: 0.10021*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.01437*width, y: 0.072*height), control1: CGPoint(x: 0.04719*width, y: 0.02702*height), control2: CGPoint(x: 0.02702*width, y: 0.04719*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.21099*height), control1: CGPoint(x: 0, y: 0.10021*height), control2: CGPoint(x: 0, y: 0.13714*height))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.25*width, y: 0.75*height), control1: CGPoint(x: 0, y: height), control2: CGPoint(x: 0.07928*width, y: 0.55174*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0.42252*width, y: 0.95035*height), control2: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0.78901*width, y: height))
        path.addCurve(to: CGPoint(x: 0.928*width, y: 0.98563*height), control1: CGPoint(x: 0.86286*width, y: height), control2: CGPoint(x: 0.89979*width, y: height))
        path.addCurve(to: CGPoint(x: 0.98563*width, y: 0.928*height), control1: CGPoint(x: 0.95281*width, y: 0.97298*height), control2: CGPoint(x: 0.97298*width, y: 0.95281*height))
        path.addCurve(to: CGPoint(x: width, y: 0.78901*height), control1: CGPoint(x: width, y: 0.89979*height), control2: CGPoint(x: width, y: 0.86287*height))
        path.addLine(to: CGPoint(x: width, y: 0.21099*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9844*width, y: 0.07263*height))
        path.addCurve(to: CGPoint(x: 0.99684*width, y: 0.12449*height), control1: CGPoint(x: 0.99148*width, y: 0.0865*height), control2: CGPoint(x: 0.99504*width, y: 0.10259*height))
        path.addCurve(to: CGPoint(x: 0.99863*width, y: 0.21099*height), control1: CGPoint(x: 0.99863*width, y: 0.14641*height), control2: CGPoint(x: 0.99863*width, y: 0.17404*height))
        path.addLine(to: CGPoint(x: 0.99863*width, y: 0.78901*height))
        path.addCurve(to: CGPoint(x: 0.99684*width, y: 0.87551*height), control1: CGPoint(x: 0.99863*width, y: 0.82596*height), control2: CGPoint(x: 0.99863*width, y: 0.85359*height))
        path.addCurve(to: CGPoint(x: 0.9844*width, y: 0.92738*height), control1: CGPoint(x: 0.99504*width, y: 0.89741*height), control2: CGPoint(x: 0.99148*width, y: 0.9135*height))
        path.addCurve(to: CGPoint(x: 0.92738*width, y: 0.9844*height), control1: CGPoint(x: 0.97189*width, y: 0.95193*height), control2: CGPoint(x: 0.95193*width, y: 0.97189*height))
        path.addCurve(to: CGPoint(x: 0.87551*width, y: 0.99684*height), control1: CGPoint(x: 0.9135*width, y: 0.99148*height), control2: CGPoint(x: 0.89741*width, y: 0.99504*height))
        path.addCurve(to: CGPoint(x: 0.78901*width, y: 0.99863*height), control1: CGPoint(x: 0.85359*width, y: 0.99863*height), control2: CGPoint(x: 0.82596*width, y: 0.99863*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.99863*height))
        path.addCurve(to: CGPoint(x: 0.27457*width, y: 0.98777*height), control1: CGPoint(x: 0.37495*width, y: 0.99863*height), control2: CGPoint(x: 0.30778*width, y: 0.99552*height))
        path.addCurve(to: CGPoint(x: 0.25589*width, y: 0.98118*height), control1: CGPoint(x: 0.26629*width, y: 0.98584*height), control2: CGPoint(x: 0.2602*width, y: 0.98364*height))
        path.addCurve(to: CGPoint(x: 0.24793*width, y: 0.9732*height), control1: CGPoint(x: 0.25158*width, y: 0.97872*height), control2: CGPoint(x: 0.24912*width, y: 0.97605*height))
        path.addCurve(to: CGPoint(x: 0.24773*width, y: 0.96338*height), control1: CGPoint(x: 0.24674*width, y: 0.97035*height), control2: CGPoint(x: 0.24673*width, y: 0.96712*height))
        path.addCurve(to: CGPoint(x: 0.25339*width, y: 0.95082*height), control1: CGPoint(x: 0.24873*width, y: 0.95963*height), control2: CGPoint(x: 0.25071*width, y: 0.95546*height))
        path.addCurve(to: CGPoint(x: 0.26288*width, y: 0.93579*height), control1: CGPoint(x: 0.25603*width, y: 0.94622*height), control2: CGPoint(x: 0.25931*width, y: 0.94123*height))
        path.addLine(to: CGPoint(x: 0.26298*width, y: 0.93564*height))
        path.addCurve(to: CGPoint(x: 0.27426*width, y: 0.91785*height), control1: CGPoint(x: 0.26658*width, y: 0.93015*height), control2: CGPoint(x: 0.27047*width, y: 0.92423*height))
        path.addCurve(to: CGPoint(x: 0.29287*width, y: 0.87389*height), control1: CGPoint(x: 0.28184*width, y: 0.9051*height), control2: CGPoint(x: 0.28906*width, y: 0.8905*height))
        path.addCurve(to: CGPoint(x: 0.25104*width, y: 0.7491*height), control1: CGPoint(x: 0.30052*width, y: 0.84056*height), control2: CGPoint(x: 0.2944*width, y: 0.79946*height))
        path.addCurve(to: CGPoint(x: 0.19077*width, y: 0.70158*height), control1: CGPoint(x: 0.2296*width, y: 0.72421*height), control2: CGPoint(x: 0.20953*width, y: 0.70937*height))
        path.addCurve(to: CGPoint(x: 0.13864*width, y: 0.69626*height), control1: CGPoint(x: 0.17199*width, y: 0.69377*height), control2: CGPoint(x: 0.15461*width, y: 0.69305*height))
        path.addCurve(to: CGPoint(x: 0.09517*width, y: 0.71443*height), control1: CGPoint(x: 0.1227*width, y: 0.69948*height), control2: CGPoint(x: 0.10821*width, y: 0.7066*height))
        path.addCurve(to: CGPoint(x: 0.07665*width, y: 0.72634*height), control1: CGPoint(x: 0.08865*width, y: 0.71835*height), control2: CGPoint(x: 0.08247*width, y: 0.72245*height))
        path.addLine(to: CGPoint(x: 0.07556*width, y: 0.72707*height))
        path.addCurve(to: CGPoint(x: 0.06027*width, y: 0.73698*height), control1: CGPoint(x: 0.07014*width, y: 0.7307*height), control2: CGPoint(x: 0.06506*width, y: 0.73409*height))
        path.addCurve(to: CGPoint(x: 0.0461*width, y: 0.74399*height), control1: CGPoint(x: 0.05516*width, y: 0.74005*height), control2: CGPoint(x: 0.05044*width, y: 0.74251*height))
        path.addCurve(to: CGPoint(x: 0.03437*width, y: 0.74521*height), control1: CGPoint(x: 0.04176*width, y: 0.74547*height), control2: CGPoint(x: 0.03787*width, y: 0.74596*height))
        path.addCurve(to: CGPoint(x: 0.01636*width, y: 0.7217*height), control1: CGPoint(x: 0.02749*width, y: 0.74374*height), control2: CGPoint(x: 0.02138*width, y: 0.73729*height))
        path.addCurve(to: CGPoint(x: 0.00511*width, y: 0.64607*height), control1: CGPoint(x: 0.01137*width, y: 0.70617*height), control2: CGPoint(x: 0.00761*width, y: 0.68203*height))
        path.addCurve(to: CGPoint(x: 0.00137*width, y: 0.5*height), control1: CGPoint(x: 0.00261*width, y: 0.61013*height), control2: CGPoint(x: 0.00137*width, y: 0.56249*height))
        path.addLine(to: CGPoint(x: 0.00137*width, y: 0.21099*height))
        path.addCurve(to: CGPoint(x: 0.00317*width, y: 0.12449*height), control1: CGPoint(x: 0.00137*width, y: 0.17404*height), control2: CGPoint(x: 0.00137*width, y: 0.14641*height))
        path.addCurve(to: CGPoint(x: 0.0156*width, y: 0.07263*height), control1: CGPoint(x: 0.00496*width, y: 0.10259*height), control2: CGPoint(x: 0.00853*width, y: 0.0865*height))
        path.addCurve(to: CGPoint(x: 0.07263*width, y: 0.0156*height), control1: CGPoint(x: 0.02811*width, y: 0.04807*height), control2: CGPoint(x: 0.04807*width, y: 0.02811*height))
        path.addCurve(to: CGPoint(x: 0.12449*width, y: 0.00317*height), control1: CGPoint(x: 0.0865*width, y: 0.00853*height), control2: CGPoint(x: 0.10259*width, y: 0.00496*height))
        path.addCurve(to: CGPoint(x: 0.21099*width, y: 0.00137*height), control1: CGPoint(x: 0.14641*width, y: 0.00137*height), control2: CGPoint(x: 0.17404*width, y: 0.00137*height))
        path.addLine(to: CGPoint(x: 0.78901*width, y: 0.00137*height))
        path.addCurve(to: CGPoint(x: 0.87551*width, y: 0.00317*height), control1: CGPoint(x: 0.82596*width, y: 0.00137*height), control2: CGPoint(x: 0.85359*width, y: 0.00137*height))
        path.addCurve(to: CGPoint(x: 0.92738*width, y: 0.0156*height), control1: CGPoint(x: 0.89741*width, y: 0.00496*height), control2: CGPoint(x: 0.9135*width, y: 0.00853*height))
        path.addCurve(to: CGPoint(x: 0.9844*width, y: 0.07263*height), control1: CGPoint(x: 0.95193*width, y: 0.02811*height), control2: CGPoint(x: 0.97189*width, y: 0.04807*height))
        path.closeSubpath()
        return path
    }
}

struct HeartPath: Shape {
    // 64x58
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.50377*width, y: 0.9948*height))
        path.addCurve(to: CGPoint(x: 0.55992*width, y: 0.90184*height), control1: CGPoint(x: 0.51099*width, y: 0.97265*height), control2: CGPoint(x: 0.53393*width, y: 0.93472*height))
        path.addCurve(to: CGPoint(x: 0.70968*width, y: 0.75711*height), control1: CGPoint(x: 0.60414*width, y: 0.84596*height), control2: CGPoint(x: 0.65475*width, y: 0.79696*height))
        path.addCurve(to: CGPoint(x: 0.85063*width, y: 0.64795*height), control1: CGPoint(x: 0.79539*width, y: 0.69485*height), control2: CGPoint(x: 0.81879*width, y: 0.67673*height))
        path.addCurve(to: CGPoint(x: 0.93793*width, y: 0.54953*height), control1: CGPoint(x: 0.88596*width, y: 0.61598*height), control2: CGPoint(x: 0.9162*width, y: 0.58192*height))
        path.addCurve(to: CGPoint(x: 0.9988*width, y: 0.38005*height), control1: CGPoint(x: 0.97334*width, y: 0.49684*height), control2: CGPoint(x: 0.99355*width, y: 0.44046*height))
        path.addCurve(to: CGPoint(x: 0.99728*width, y: 0.28684*height), control1: CGPoint(x: 1.00085*width, y: 0.35631*height), control2: CGPoint(x: 1.00024*width, y: 0.31637*height))
        path.addCurve(to: CGPoint(x: 0.85876*width, y: 0.03018*height), control1: CGPoint(x: 0.98557*width, y: 0.16996*height), control2: CGPoint(x: 0.93542*width, y: 0.077*height))
        path.addCurve(to: CGPoint(x: 0.78338*width, y: 0.00191*height), control1: CGPoint(x: 0.8365*width, y: 0.01651*height), control2: CGPoint(x: 0.81028*width, y: 0.00669*height))
        path.addCurve(to: CGPoint(x: 0.72229*width, y: 0.00107*height), control1: CGPoint(x: 0.77138*width, y: -0.00019*height), control2: CGPoint(x: 0.73612*width, y: -0.00069*height))
        path.addCurve(to: CGPoint(x: 0.54237*width, y: 0.12323*height), control1: CGPoint(x: 0.65247*width, y: 0.00996*height), control2: CGPoint(x: 0.59001*width, y: 0.05233*height))
        path.addCurve(to: CGPoint(x: 0.50187*width, y: 0.19992*height), control1: CGPoint(x: 0.52732*width, y: 0.14563*height), control2: CGPoint(x: 0.51213*width, y: 0.17441*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.20403*height))
        path.addLine(to: CGPoint(x: 0.49693*width, y: 0.19614*height))
        path.addCurve(to: CGPoint(x: 0.3901*width, y: 0.05217*height), control1: CGPoint(x: 0.47071*width, y: 0.13431*height), control2: CGPoint(x: 0.43417*width, y: 0.08506*height))
        path.addCurve(to: CGPoint(x: 0.28349*width, y: 0.00611*height), control1: CGPoint(x: 0.35644*width, y: 0.02716*height), control2: CGPoint(x: 0.32194*width, y: 0.01215*height))
        path.addCurve(to: CGPoint(x: 0.22757*width, y: 0.00485*height), control1: CGPoint(x: 0.27255*width, y: 0.00434*height), control2: CGPoint(x: 0.2392*width, y: 0.00359*height))
        path.addCurve(to: CGPoint(x: 0.06124*width, y: 0.11006*height), control1: CGPoint(x: 0.16055*width, y: 0.01198*height), control2: CGPoint(x: 0.10235*width, y: 0.04889*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.30698*height), control1: CGPoint(x: 0.02629*width, y: 0.16216*height), control2: CGPoint(x: 0.0057*width, y: 0.2292*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.37821*height), control1: CGPoint(x: -0.00038*width, y: 0.32552*height), control2: CGPoint(x: -0.00023*width, y: 0.36336*height))
        path.addCurve(to: CGPoint(x: 0.03085*width, y: 0.48988*height), control1: CGPoint(x: 0.00479*width, y: 0.41856*height), control2: CGPoint(x: 0.01383*width, y: 0.45229*height))
        path.addCurve(to: CGPoint(x: 0.10645*width, y: 0.60029*height), control1: CGPoint(x: 0.04848*width, y: 0.52864*height), control2: CGPoint(x: 0.07196*width, y: 0.56287*height))
        path.addCurve(to: CGPoint(x: 0.24998*width, y: 0.72397*height), control1: CGPoint(x: 0.14095*width, y: 0.63771*height), control2: CGPoint(x: 0.17689*width, y: 0.66867*height))
        path.addCurve(to: CGPoint(x: 0.30127*width, y: 0.76373*height), control1: CGPoint(x: 0.27187*width, y: 0.74049*height), control2: CGPoint(x: 0.28843*width, y: 0.75333*height))
        path.addCurve(to: CGPoint(x: 0.48728*width, y: 0.97609*height), control1: CGPoint(x: 0.37756*width, y: 0.82548*height), control2: CGPoint(x: 0.45651*width, y: 0.91559*height))
        path.addCurve(to: CGPoint(x: 0.49617*width, y: 0.99866*height), control1: CGPoint(x: 0.49153*width, y: 0.98456*height), control2: CGPoint(x: 0.49617*width, y: 0.99622*height))
        path.addCurve(to: CGPoint(x: 0.49913*width, y: height), control1: CGPoint(x: 0.49617*width, y: 0.99966*height), control2: CGPoint(x: 0.49693*width, y: height))
        path.addCurve(to: CGPoint(x: 0.50377*width, y: 0.9948*height), control1: CGPoint(x: 0.50202*width, y: height), control2: CGPoint(x: 0.5021*width, y: 0.99992*height))
        path.closeSubpath()
        return path
    }
}

struct HeartbreakLeftPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.49693*width, y: 0.19615*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.20403*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.30698*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.40936*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.49427*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.62667*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.76374*height))
        path.addLine(to: CGPoint(x: 0.49913*width, y: 0.90563*height))
        path.addLine(to: CGPoint(x: 0.49913*width, y: 1.00001*height))
        path.addCurve(to: CGPoint(x: 0.49617*width, y: 0.99866*height), control1: CGPoint(x: 0.49693*width, y: 1.00001*height), control2: CGPoint(x: 0.49617*width, y: 0.99967*height))
        path.addCurve(to: CGPoint(x: 0.48728*width, y: 0.97609*height), control1: CGPoint(x: 0.49617*width, y: 0.99623*height), control2: CGPoint(x: 0.49153*width, y: 0.98457*height))
        path.addCurve(to: CGPoint(x: 0.30127*width, y: 0.76374*height), control1: CGPoint(x: 0.45651*width, y: 0.9156*height), control2: CGPoint(x: 0.37756*width, y: 0.82549*height))
        path.addCurve(to: CGPoint(x: 0.24998*width, y: 0.72397*height), control1: CGPoint(x: 0.28843*width, y: 0.75334*height), control2: CGPoint(x: 0.27187*width, y: 0.7405*height))
        path.addCurve(to: CGPoint(x: 0.10645*width, y: 0.6003*height), control1: CGPoint(x: 0.17689*width, y: 0.66868*height), control2: CGPoint(x: 0.14095*width, y: 0.63772*height))
        path.addCurve(to: CGPoint(x: 0.03085*width, y: 0.48988*height), control1: CGPoint(x: 0.07196*width, y: 0.56288*height), control2: CGPoint(x: 0.04848*width, y: 0.52865*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.37821*height), control1: CGPoint(x: 0.01383*width, y: 0.4523*height), control2: CGPoint(x: 0.00479*width, y: 0.41857*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.30698*height), control1: CGPoint(x: -0.00023*width, y: 0.36336*height), control2: CGPoint(x: -0.00038*width, y: 0.32552*height))
        path.addCurve(to: CGPoint(x: 0.06124*width, y: 0.11006*height), control1: CGPoint(x: 0.0057*width, y: 0.2292*height), control2: CGPoint(x: 0.02629*width, y: 0.16217*height))
        path.addCurve(to: CGPoint(x: 0.22757*width, y: 0.00485*height), control1: CGPoint(x: 0.10235*width, y: 0.0489*height), control2: CGPoint(x: 0.16055*width, y: 0.01198*height))
        path.addCurve(to: CGPoint(x: 0.28349*width, y: 0.00611*height), control1: CGPoint(x: 0.2392*width, y: 0.00359*height), control2: CGPoint(x: 0.27255*width, y: 0.00435*height))
        path.addCurve(to: CGPoint(x: 0.3901*width, y: 0.05217*height), control1: CGPoint(x: 0.32194*width, y: 0.01215*height), control2: CGPoint(x: 0.35644*width, y: 0.02717*height))
        path.addCurve(to: CGPoint(x: 0.49693*width, y: 0.19615*height), control1: CGPoint(x: 0.43417*width, y: 0.08506*height), control2: CGPoint(x: 0.47071*width, y: 0.13431*height))
        path.closeSubpath()
        return path
    }
}

struct HeartbreakRightPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.55996*width, y: 0.90184*height))
        path.addCurve(to: CGPoint(x: 0.5038*width, y: 0.9948*height), control1: CGPoint(x: 0.53397*width, y: 0.93472*height), control2: CGPoint(x: 0.51102*width, y: 0.97265*height))
        path.addCurve(to: CGPoint(x: 0.49917*width, y: height), control1: CGPoint(x: 0.50213*width, y: 0.99992*height), control2: CGPoint(x: 0.50205*width, y: height))
        path.addLine(to: CGPoint(x: 0.49917*width, y: 0.90563*height))
        path.addLine(to: CGPoint(x: 0.45166*width, y: 0.76373*height))
        path.addLine(to: CGPoint(x: 0.50031*width, y: 0.62667*height))
        path.addLine(to: CGPoint(x: 0.45166*width, y: 0.49427*height))
        path.addLine(to: CGPoint(x: 0.50031*width, y: 0.40936*height))
        path.addLine(to: CGPoint(x: 0.45166*width, y: 0.30698*height))
        path.addLine(to: CGPoint(x: 0.50031*width, y: 0.20403*height))
        path.addLine(to: CGPoint(x: 0.5019*width, y: 0.19992*height))
        path.addCurve(to: CGPoint(x: 0.5424*width, y: 0.12323*height), control1: CGPoint(x: 0.51216*width, y: 0.17441*height), control2: CGPoint(x: 0.52736*width, y: 0.14563*height))
        path.addCurve(to: CGPoint(x: 0.72233*width, y: 0.00107*height), control1: CGPoint(x: 0.59004*width, y: 0.05233*height), control2: CGPoint(x: 0.6525*width, y: 0.00996*height))
        path.addCurve(to: CGPoint(x: 0.78342*width, y: 0.00191*height), control1: CGPoint(x: 0.73616*width, y: -0.00069*height), control2: CGPoint(x: 0.77142*width, y: -0.00019*height))
        path.addCurve(to: CGPoint(x: 0.8588*width, y: 0.03018*height), control1: CGPoint(x: 0.81032*width, y: 0.00669*height), control2: CGPoint(x: 0.83653*width, y: 0.01651*height))
        path.addCurve(to: CGPoint(x: 0.99731*width, y: 0.28684*height), control1: CGPoint(x: 0.93546*width, y: 0.077*height), control2: CGPoint(x: 0.98561*width, y: 0.16996*height))
        path.addCurve(to: CGPoint(x: 0.99883*width, y: 0.38005*height), control1: CGPoint(x: 1.00028*width, y: 0.31637*height), control2: CGPoint(x: 1.00088*width, y: 0.35631*height))
        path.addCurve(to: CGPoint(x: 0.93797*width, y: 0.54953*height), control1: CGPoint(x: 0.99359*width, y: 0.44046*height), control2: CGPoint(x: 0.97338*width, y: 0.49684*height))
        path.addCurve(to: CGPoint(x: 0.85067*width, y: 0.64795*height), control1: CGPoint(x: 0.91624*width, y: 0.58192*height), control2: CGPoint(x: 0.886*width, y: 0.61598*height))
        path.addCurve(to: CGPoint(x: 0.70972*width, y: 0.75711*height), control1: CGPoint(x: 0.81883*width, y: 0.67673*height), control2: CGPoint(x: 0.79543*width, y: 0.69485*height))
        path.addCurve(to: CGPoint(x: 0.55996*width, y: 0.90184*height), control1: CGPoint(x: 0.65478*width, y: 0.79696*height), control2: CGPoint(x: 0.60418*width, y: 0.84596*height))
        path.closeSubpath()
        return path
    }
}

struct NoodleIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.20743*width, y: 0.22529*height))
        path.addCurve(to: CGPoint(x: 0.41576*width, y: 0.58954*height), control1: CGPoint(x: 0.23801*width, y: 0.36667*height), control2: CGPoint(x: 0.31216*width, y: 0.48463*height))
        path.addCurve(to: CGPoint(x: 0.89289*width, y: 0.80689*height), control1: CGPoint(x: 0.55211*width, y: 0.72033*height), control2: CGPoint(x: 0.70496*width, y: 0.80287*height))
        path.addCurve(to: CGPoint(x: 0.97219*width, y: 0.89223*height), control1: CGPoint(x: 0.94107*width, y: 0.80792*height), control2: CGPoint(x: 0.97328*width, y: 0.84791*height))
        path.addCurve(to: CGPoint(x: 0.89034*width, y: 0.97213*height), control1: CGPoint(x: 0.97115*width, y: 0.93466*height), control2: CGPoint(x: 0.93938*width, y: 0.97448*height))
        path.addCurve(to: CGPoint(x: 0.88342*width, y: 0.9718*height), control1: CGPoint(x: 0.88804*width, y: 0.97202*height), control2: CGPoint(x: 0.88573*width, y: 0.97191*height))
        path.addCurve(to: CGPoint(x: 0.74369*width, y: 0.95718*height), control1: CGPoint(x: 0.83849*width, y: 0.96967*height), control2: CGPoint(x: 0.79024*width, y: 0.96738*height))
        path.addCurve(to: CGPoint(x: 0.21121*width, y: 0.61031*height), control1: CGPoint(x: 0.52228*width, y: 0.90868*height), control2: CGPoint(x: 0.34787*width, y: 0.78566*height))
        path.addCurve(to: CGPoint(x: 0.0278*width, y: 0.11974*height), control1: CGPoint(x: 0.09998*width, y: 0.46759*height), control2: CGPoint(x: 0.03094*width, y: 0.30588*height))
        path.addCurve(to: CGPoint(x: 0.04798*width, y: 0.0553*height), control1: CGPoint(x: 0.02739*width, y: 0.09554*height), control2: CGPoint(x: 0.03338*width, y: 0.0727*height))
        path.addCurve(to: CGPoint(x: 0.10769*width, y: 0.02783*height), control1: CGPoint(x: 0.06294*width, y: 0.03746*height), control2: CGPoint(x: 0.08427*width, y: 0.02855*height))
        path.addCurve(to: CGPoint(x: 0.17005*width, y: 0.05275*height), control1: CGPoint(x: 0.13213*width, y: 0.02707*height), control2: CGPoint(x: 0.15411*width, y: 0.03539*height))
        path.addCurve(to: CGPoint(x: 0.19443*width, y: 0.11572*height), control1: CGPoint(x: 0.18542*width, y: 0.06949*height), control2: CGPoint(x: 0.19278*width, y: 0.09197*height))
        path.addCurve(to: CGPoint(x: 0.20743*width, y: 0.22529*height), control1: CGPoint(x: 0.19708*width, y: 0.15391*height), control2: CGPoint(x: 0.19989*width, y: 0.19042*height))
        path.closeSubpath()
        return path
    }
}
