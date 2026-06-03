//
//  AllSystemsGlow.metal
//  ShaderWallpaper
//
//  Created by Calle Gustafsson on 2026-06-03.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;

// =====================
// All Systems Glow tuning constants
// =====================

constant int kAppleBodyPointCount = 294;
constant int kAppleLeafPointCount = 89;

constant float kLogoScale = 0.2175;
constant float2 kLogoCenter = float2(0.0, -0.045);
constant float kEdgeAAMin = 0.0012;

constant float3 kBackgroundColor = float3(0.006, 0.009, 0.018);
constant float3 kBroadGlowColor = float3(0.010, 0.016, 0.040);

constant float kLightAngularVelocity = -0.14;
constant float kLightOrbitRadiusScale = 0.68;
constant float kLightOrbitRadiusPadding = 0.35;
constant float kLightColorPhase = 0.8;
constant float3 kLightWarmColor = float3(1.00, 0.46, 0.18);
constant float3 kLightCoolColor = float3(0.22, 0.82, 1.00);
constant float3 kLightNeutralColor = float3(0.92, 0.96, 1.00);
constant float kLightColorSaturation = 0.34;

constant float2 kCenterFocusRadius = float2(1.45, 1.20);
constant float2 kBodyCenter = float2(0.02, -0.20);
constant float2 kBodyDomeRadius = float2(0.82, 1.02);
constant float kBodyRoundPower = 0.58;
constant float kBodyLowerFullness = 0.13;
constant float kBodyBaseThickness = 0.05;
constant float kBodyDomeThickness = 0.33;
constant float kBodyDomeSlope = 0.80;
constant float kBodyRimXYStrength = 1.25;
constant float kBodyRimZStrength = 0.34;
constant float kBodyRimBlendNear = 0.006;
constant float kBodyRimBlendFar = 0.105;

constant float2 kLeafCenter = float2(0.20, 0.75);
constant float2 kLeafDomeRadius = float2(0.42, 0.22);
constant float kLeafDomeSlope = 0.72;
constant float kLeafRimXYStrength = 1.18;
constant float kLeafRimZStrength = 0.38;
constant float kLeafRimBlendNear = 0.004;
constant float kLeafRimBlendFar = 0.065;

constant float3 kViewDir = float3(0.0, 0.0, 1.0);
constant float kBodySpecPower = 42.0;
constant float kBodyBroadSpecPower = 9.0;
constant float kBodySpecStrength = 2.10;
constant float kBodyBroadSpecStrength = 0.52;
constant float kLeafSpecPower = 46.0;
constant float kLeafBroadSpecPower = 10.0;
constant float kLeafSpecStrength = 0.80;
constant float kLeafBroadSpecStrength = 0.14;

constant float3 kGlassBaseColor = float3(0.003, 0.005, 0.014);
constant float3 kBodyNoiseColor = float3(0.008, 0.014, 0.030);
constant float3 kLeafInternalColor = float3(0.032, 0.045, 0.080);
constant float3 kWhiteReflectionColor = float3(0.94, 0.97, 1.00);

// IMPORTANT: the logo silhouette below is not hand-drawn with circles/ellipses.
// It is the flattened cubic Bézier outline from allsystemglow/Apple_Logo.svg,
// normalized into local coordinates. The fragment shader uses these points for
// both the filled mask and distance-based glow/rim lighting.

constant float2 kAppleBody[294] = {
    float2(0.8070126, -0.5586072),
    float2(0.7986258, -0.5775264),
    float2(0.7899631, -0.5961718),
    float2(0.7810237, -0.6145450),
    float2(0.7718072, -0.6326478),
    float2(0.7623130, -0.6504819),
    float2(0.7525406, -0.6680487),
    float2(0.7424893, -0.6853502),
    float2(0.7321586, -0.7023878),
    float2(0.7215481, -0.7191633),
    float2(0.7106570, -0.7356784),
    float2(0.6994850, -0.7519347),
    float2(0.6843189, -0.7733053),
    float2(0.6696626, -0.7934455),
    float2(0.6555177, -0.8123552),
    float2(0.6418859, -0.8300345),
    float2(0.6287689, -0.8464834),
    float2(0.6161683, -0.8617018),
    float2(0.6040859, -0.8756897),
    float2(0.5925232, -0.8884472),
    float2(0.5814820, -0.8999743),
    float2(0.5709639, -0.9102709),
    float2(0.5609706, -0.9193370),
    float2(0.5442598, -0.9338516),
    float2(0.5273104, -0.9468789),
    float2(0.5101211, -0.9584203),
    float2(0.4926902, -0.9684772),
    float2(0.4750164, -0.9770513),
    float2(0.4570982, -0.9841439),
    float2(0.4389341, -0.9897566),
    float2(0.4205225, -0.9938908),
    float2(0.4018621, -0.9965480),
    float2(0.3829513, -0.9977297),
    float2(0.3690040, -0.9973405),
    float2(0.3544959, -0.9961712),
    float2(0.3394293, -0.9942198),
    float2(0.3238064, -0.9914840),
    float2(0.3076295, -0.9879615),
    float2(0.2909008, -0.9836501),
    float2(0.2736224, -0.9785477),
    float2(0.2557966, -0.9726519),
    float2(0.2374257, -0.9659607),
    float2(0.2185118, -0.9584716),
    float2(0.1994201, -0.9510160),
    float2(0.1806392, -0.9443516),
    float2(0.1621684, -0.9384767),
    float2(0.1440068, -0.9333899),
    float2(0.1261535, -0.9290898),
    float2(0.1086076, -0.9255748),
    float2(0.0913682, -0.9228436),
    float2(0.0744344, -0.9208945),
    float2(0.0578054, -0.9197261),
    float2(0.0414802, -0.9193370),
    float2(0.0243946, -0.9197261),
    float2(0.0070624, -0.9208945),
    float2(-0.0105172, -0.9228436),
    float2(-0.0283449, -0.9255748),
    float2(-0.0464215, -0.9290898),
    float2(-0.0647477, -0.9333899),
    float2(-0.0833243, -0.9384767),
    float2(-0.1021520, -0.9443516),
    float2(-0.1212316, -0.9510160),
    float2(-0.1405637, -0.9584716),
    float2(-0.1596734, -0.9659828),
    float2(-0.1780273, -0.9727398),
    float2(-0.1956270, -0.9787443),
    float2(-0.2124746, -0.9839978),
    float2(-0.2285719, -0.9885016),
    float2(-0.2439206, -0.9922573),
    float2(-0.2585227, -0.9952663),
    float2(-0.2723800, -0.9975302),
    float2(-0.2854943, -0.9990504),
    float2(-0.2978676, -0.9998284),
    float2(-0.3161168, -0.9997246),
    float2(-0.3343546, -0.9978571),
    float2(-0.3525816, -0.9942252),
    float2(-0.3707983, -0.9888282),
    float2(-0.3890053, -0.9816654),
    float2(-0.4072030, -0.9727359),
    float2(-0.4253919, -0.9620390),
    float2(-0.4435726, -0.9495741),
    float2(-0.4617456, -0.9353404),
    float2(-0.4799115, -0.9193370),
    float2(-0.4906901, -0.9095485),
    float2(-0.5019486, -0.8985663),
    float2(-0.5136866, -0.8863903),
    float2(-0.5259035, -0.8730207),
    float2(-0.5385987, -0.8584573),
    float2(-0.5517717, -0.8427002),
    float2(-0.5654219, -0.8257494),
    float2(-0.5795488, -0.8076049),
    float2(-0.5941517, -0.7882666),
    float2(-0.6092302, -0.7677346),
    float2(-0.6247836, -0.7460089),
    float2(-0.6363019, -0.7294570),
    float2(-0.6475613, -0.7125777),
    float2(-0.6585616, -0.6953708),
    float2(-0.6693029, -0.6778358),
    float2(-0.6797852, -0.6599724),
    float2(-0.6900084, -0.6417803),
    float2(-0.6999726, -0.6232590),
    float2(-0.7096777, -0.6044083),
    float2(-0.7191236, -0.5852276),
    float2(-0.7283105, -0.5657168),
    float2(-0.7372382, -0.5458754),
    float2(-0.7459067, -0.5257031),
    float2(-0.7543161, -0.5051994),
    float2(-0.7624662, -0.4843641),
    float2(-0.7703572, -0.4631968),
    float2(-0.7779889, -0.4416971),
    float2(-0.7849327, -0.4209319),
    float2(-0.7914808, -0.4002396),
    float2(-0.7976328, -0.3796204),
    float2(-0.8033888, -0.3590739),
    float2(-0.8087486, -0.3386003),
    float2(-0.8137121, -0.3181993),
    float2(-0.8182791, -0.2978708),
    float2(-0.8224497, -0.2776148),
    float2(-0.8262235, -0.2574311),
    float2(-0.8296006, -0.2373197),
    float2(-0.8325809, -0.2172804),
    float2(-0.8351641, -0.1973131),
    float2(-0.8373502, -0.1774178),
    float2(-0.8391391, -0.1575943),
    float2(-0.8405307, -0.1378426),
    float2(-0.8415248, -0.1181625),
    float2(-0.8421214, -0.0985539),
    float2(-0.8423203, -0.0790167),
    float2(-0.8420196, -0.0555553),
    float2(-0.8411175, -0.0324768),
    float2(-0.8396140, -0.0097817),
    float2(-0.8375088, 0.0125296),
    float2(-0.8348020, 0.0344568),
    float2(-0.8314933, 0.0559996),
    float2(-0.8275826, 0.0771575),
    float2(-0.8230700, 0.0979302),
    float2(-0.8179552, 0.1183174),
    float2(-0.8122382, 0.1383187),
    float2(-0.8059189, 0.1579336),
    float2(-0.7989971, 0.1771619),
    float2(-0.7914727, 0.1960033),
    float2(-0.7833457, 0.2144572),
    float2(-0.7746159, 0.2325235),
    float2(-0.7652832, 0.2502016),
    float2(-0.7553476, 0.2674913),
    float2(-0.7445591, 0.2851564),
    float2(-0.7332353, 0.3022384),
    float2(-0.7213758, 0.3187377),
    float2(-0.7089799, 0.3346545),
    float2(-0.6960471, 0.3499891),
    float2(-0.6825769, 0.3647419),
    float2(-0.6685688, 0.3789131),
    float2(-0.6540221, 0.3925031),
    float2(-0.6389364, 0.4055122),
    float2(-0.6233112, 0.4179406),
    float2(-0.6071458, 0.4297886),
    float2(-0.5904398, 0.4410567),
    float2(-0.5731926, 0.4517450),
    float2(-0.5555660, 0.4617515),
    float2(-0.5377220, 0.4709752),
    float2(-0.5196599, 0.4794176),
    float2(-0.5013792, 0.4870804),
    float2(-0.4828795, 0.4939653),
    float2(-0.4641600, 0.5000739),
    float2(-0.4452204, 0.5054078),
    float2(-0.4260601, 0.5099688),
    float2(-0.4066784, 0.5137584),
    float2(-0.3870750, 0.5167784),
    float2(-0.3672492, 0.5190303),
    float2(-0.3472005, 0.5205159),
    float2(-0.3269284, 0.5212367),
    float2(-0.3119771, 0.5207887),
    float2(-0.2961208, 0.5194468),
    float2(-0.2793576, 0.5172142),
    float2(-0.2616854, 0.5140938),
    float2(-0.2431023, 0.5100889),
    float2(-0.2236062, 0.5052025),
    float2(-0.2031953, 0.4994378),
    float2(-0.1818674, 0.4927979),
    float2(-0.1596205, 0.4852858),
    float2(-0.1364527, 0.4769047),
    float2(-0.1137340, 0.4684969),
    float2(-0.0927031, 0.4609634),
    float2(-0.0733614, 0.4543067),
    float2(-0.0557101, 0.4485295),
    float2(-0.0397504, 0.4436341),
    float2(-0.0254836, 0.4396232),
    float2(-0.0129110, 0.4364992),
    float2(-0.0020339, 0.4342646),
    float2(0.0071466, 0.4329220),
    float2(0.0146291, 0.4324740),
    float2(0.0207725, 0.4329983),
    float2(0.0292821, 0.4345708),
    float2(0.0401548, 0.4371908),
    float2(0.0533873, 0.4408577),
    float2(0.0689762, 0.4455708),
    float2(0.0869185, 0.4513294),
    float2(0.1072107, 0.4581328),
    float2(0.1298497, 0.4659805),
    float2(0.1548322, 0.4748717),
    float2(0.1821549, 0.4848057),
    float2(0.2063020, 0.4931509),
    float2(0.2297556, 0.5005584),
    float2(0.2525172, 0.5070293),
    float2(0.2745881, 0.5125651),
    float2(0.2959699, 0.5171669),
    float2(0.3166638, 0.5208360),
    float2(0.3366712, 0.5235738),
    float2(0.3559935, 0.5253814),
    float2(0.3746322, 0.5262603),
    float2(0.3925886, 0.5262115),
    float2(0.4098641, 0.5252366),
    float2(0.4325501, 0.5230578),
    float2(0.4547170, 0.5202248),
    float2(0.4763645, 0.5167374),
    float2(0.4974924, 0.5125953),
    float2(0.5181003, 0.5077984),
    float2(0.5381881, 0.5023463),
    float2(0.5577554, 0.4962389),
    float2(0.5768019, 0.4894758),
    float2(0.5953274, 0.4820569),
    float2(0.6133316, 0.4739820),
    float2(0.6308142, 0.4652507),
    float2(0.6477749, 0.4558629),
    float2(0.6642135, 0.4458184),
    float2(0.6801296, 0.4351168),
    float2(0.6955231, 0.4237579),
    float2(0.7103935, 0.4117415),
    float2(0.7247407, 0.3990675),
    float2(0.7385644, 0.3857354),
    float2(0.7518642, 0.3717452),
    float2(0.7646400, 0.3570965),
    float2(0.7768913, 0.3417891),
    float2(0.7886181, 0.3258229),
    float2(0.7694203, 0.3137224),
    float2(0.7510850, 0.3012078),
    float2(0.7336121, 0.2882792),
    float2(0.7170016, 0.2749370),
    float2(0.7012533, 0.2611812),
    float2(0.6863673, 0.2470121),
    float2(0.6723435, 0.2324298),
    float2(0.6591818, 0.2174347),
    float2(0.6468821, 0.2020268),
    float2(0.6354444, 0.1862064),
    float2(0.6248687, 0.1699737),
    float2(0.6151548, 0.1533289),
    float2(0.6063027, 0.1362722),
    float2(0.5983124, 0.1188037),
    float2(0.5911838, 0.1009238),
    float2(0.5849168, 0.0826325),
    float2(0.5795113, 0.0639301),
    float2(0.5749674, 0.0448168),
    float2(0.5712849, 0.0252928),
    float2(0.5684637, 0.0053583),
    float2(0.5665039, -0.0149865),
    float2(0.5654054, -0.0357415),
    float2(0.5651680, -0.0569063),
    float2(0.5658104, -0.0779768),
    float2(0.5672847, -0.0986502),
    float2(0.5695906, -0.1189260),
    float2(0.5727280, -0.1388037),
    float2(0.5766965, -0.1582829),
    float2(0.5814958, -0.1773631),
    float2(0.5871259, -0.1960438),
    float2(0.5935863, -0.2143246),
    float2(0.6008768, -0.2322050),
    float2(0.6089973, -0.2496845),
    float2(0.6179473, -0.2667627),
    float2(0.6277267, -0.2834390),
    float2(0.6383353, -0.2997130),
    float2(0.6497727, -0.3155843),
    float2(0.6620387, -0.3310524),
    float2(0.6751330, -0.3461167),
    float2(0.6890555, -0.3607769),
    float2(0.7038058, -0.3750325),
    float2(0.7163206, -0.3865063),
    float2(0.7291265, -0.3974476),
    float2(0.7422258, -0.4078570),
    float2(0.7556205, -0.4177354),
    float2(0.7693131, -0.4270834),
    float2(0.7833056, -0.4359018),
    float2(0.7976004, -0.4441913),
    float2(0.8121996, -0.4519526),
    float2(0.8271054, -0.4591866),
    float2(0.8423201, -0.4658939),
    float2(0.8389683, -0.4755197),
    float2(0.8355786, -0.4850647),
    float2(0.8321504, -0.4945297),
    float2(0.8286830, -0.5039155),
    float2(0.8251756, -0.5132227),
    float2(0.8216274, -0.5224522),
    float2(0.8180378, -0.5316047),
    float2(0.8144059, -0.5406808),
    float2(0.8107311, -0.5496814)
};

constant float2 kAppleLeaf[89] = {
    float2(0.4210983, 0.9599889),
    float2(0.4206112, 0.9400728),
    float2(0.4191500, 0.9203342),
    float2(0.4167152, 0.9007735),
    float2(0.4133073, 0.8813914),
    float2(0.4089268, 0.8621883),
    float2(0.4035739, 0.8431650),
    float2(0.3972492, 0.8243219),
    float2(0.3899532, 0.8056596),
    float2(0.3816862, 0.7871786),
    float2(0.3724487, 0.7688796),
    float2(0.3622411, 0.7507631),
    float2(0.3510639, 0.7328296),
    float2(0.3389175, 0.7150797),
    float2(0.3258024, 0.6975141),
    float2(0.3117189, 0.6801331),
    float2(0.2969002, 0.6634121),
    float2(0.2817501, 0.6475205),
    float2(0.2662784, 0.6324845),
    float2(0.2504947, 0.6183302),
    float2(0.2344088, 0.6050836),
    float2(0.2180304, 0.5927709),
    float2(0.2013692, 0.5814181),
    float2(0.1844348, 0.5710514),
    float2(0.1672372, 0.5616969),
    float2(0.1497858, 0.5533806),
    float2(0.1320906, 0.5461287),
    float2(0.1141611, 0.5399673),
    float2(0.0960071, 0.5349224),
    float2(0.0776383, 0.5310202),
    float2(0.0590645, 0.5282867),
    float2(0.0402953, 0.5267481),
    float2(0.0213405, 0.5264305),
    float2(0.0022097, 0.5273600),
    float2(0.0017878, 0.5309788),
    float2(0.0014042, 0.5346354),
    float2(0.0010606, 0.5383300),
    float2(0.0007581, 0.5420625),
    float2(0.0004984, 0.5458332),
    float2(0.0002827, 0.5496420),
    float2(0.0001125, 0.5534890),
    float2(-0.0000108, 0.5573743),
    float2(-0.0000858, 0.5612979),
    float2(-0.0001112, 0.5652601),
    float2(0.0004434, 0.5845467),
    float2(0.0020960, 0.6039679),
    float2(0.0048300, 0.6234782),
    float2(0.0086287, 0.6430323),
    float2(0.0134755, 0.6625850),
    float2(0.0193537, 0.6820909),
    float2(0.0262467, 0.7015048),
    float2(0.0341377, 0.7207813),
    float2(0.0430102, 0.7398752),
    float2(0.0528474, 0.7587412),
    float2(0.0636328, 0.7773339),
    float2(0.0753497, 0.7956081),
    float2(0.0879813, 0.8135184),
    float2(0.1015111, 0.8310196),
    float2(0.1159224, 0.8480663),
    float2(0.1273427, 0.8606138),
    float2(0.1393672, 0.8727313),
    float2(0.1519955, 0.8844188),
    float2(0.1652273, 0.8956764),
    float2(0.1790624, 0.9065042),
    float2(0.1935005, 0.9169023),
    float2(0.2085411, 0.9268707),
    float2(0.2241842, 0.9364096),
    float2(0.2404293, 0.9455189),
    float2(0.2572761, 0.9541989),
    float2(0.2742940, 0.9621649),
    float2(0.2911259, 0.9693835),
    float2(0.3077712, 0.9758528),
    float2(0.3242291, 0.9815710),
    float2(0.3404989, 0.9865362),
    float2(0.3565798, 0.9907464),
    float2(0.3724710, 0.9941998),
    float2(0.3881719, 0.9968945),
    float2(0.4036817, 0.9988285),
    float2(0.4189996, 1.0000000),
    float2(0.4194184, 0.9959887),
    float2(0.4197867, 0.9919780),
    float2(0.4201062, 0.9879685),
    float2(0.4203783, 0.9839608),
    float2(0.4206045, 0.9799557),
    float2(0.4207862, 0.9759537),
    float2(0.4209250, 0.9719555),
    float2(0.4210223, 0.9679617),
    float2(0.4210795, 0.9639731),
    float2(0.4210983, 0.9599901)
};

static float hash21(float2 p) {
    p = fract(p * float2(127.1, 311.7));
    p += dot(p, p + 37.7);
    return fract(p.x * p.y);
}

static float noise21(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

static float fbm21(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise21(p);
        p = rot(p, 0.71) * 2.05 + 13.7;
        a *= 0.5;
    }
    return v;
}

static float segmentDistanceSquared21(float2 p, float2 a, float2 b) {
    float2 ba = b - a;
    float h = clamp(dot(p - a, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0);
    float2 d = p - (a + ba * h);
    return dot(d, d);
}

static float signedPolygonDistance21(float2 p, constant float2 *pts, int count) {
    float d2 = 1e20;
    bool inside = false;

    for (int i = 0; i < count; i++) {
        float2 a = pts[i];
        float2 b = pts[(i + 1) % count];
        d2 = min(d2, segmentDistanceSquared21(p, a, b));

        bool crosses = ((a.y > p.y) != (b.y > p.y));
        if (crosses) {
            float x = a.x + (p.y - a.y) * (b.x - a.x) / (b.y - a.y);
            if (p.x < x) { inside = !inside; }
        }
    }

    return sqrt(d2) * (inside ? -1.0 : 1.0);
}

static float3 spectralEdge21(float x) {
    return 0.52 + 0.48 * cos(2.0 * PI * (float3(0.02, 0.25, 0.55) + x));
}

fragment float4 appleLogoShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float2 centered = uv - 0.5;
    float aspect = u.resolution.x / max(u.resolution.y, 1.0);
    float2 q = float2(centered.x * aspect, -centered.y);
    float t = u.time;

    // SVG local coordinates: y spans roughly [-1, 1].
    float logoScale = kLogoScale;
    float2 logoCenter = kLogoCenter;
    float2 p = (q - logoCenter) / logoScale;

    float bodyLocalD = signedPolygonDistance21(p, kAppleBody, kAppleBodyPointCount);
    float leafLocalD = signedPolygonDistance21(p, kAppleLeaf, kAppleLeafPointCount);
    float bodyD = bodyLocalD * logoScale;
    float leafD = leafLocalD * logoScale;
    float logoD = min(bodyD, leafD);

    float bodyAA = max(fwidth(bodyD), kEdgeAAMin);
    float leafAA = max(fwidth(leafD), kEdgeAAMin);
    float bodyMask = 1.0 - smoothstep(-bodyAA, bodyAA, bodyD);
    float leafMask = 1.0 - smoothstep(-leafAA, leafAA, leafD);
    float logoMask = max(bodyMask, leafMask);
    float outsideMask = 1.0 - logoMask;

    // Reference-like black field with only a soft blue aura around the logo.
    float vignetteR = length(q - logoCenter);
    float3 color = float3(0.0);
    color += kBackgroundColor * smoothstep(1.10, 0.10, vignetteR);

    // Slow orbital spotlight: the light lives outside the screen and always aims
    // at the center of the screen. One full revolution takes ~45 seconds.
    float lightAngle = t * kLightAngularVelocity;
    float screenRadius = length(float2(aspect, 1.0)) * kLightOrbitRadiusScale + kLightOrbitRadiusPadding;
    float2 lightScreenPos = float2(cos(lightAngle), sin(lightAngle)) * screenRadius;
    float2 beamDir = normalize(-lightScreenPos);              // light -> screen center
    float2 lightDir = normalize(lightScreenPos - logoCenter); // logo center -> light
    float2 beamTangent = float2(-beamDir.y, beamDir.x);
    float3 lightColor = mix(kLightWarmColor, kLightCoolColor, 0.5 + 0.5 * sin(lightAngle + kLightColorPhase));
    lightColor = mix(kLightNeutralColor, lightColor, kLightColorSaturation);

    float2 lightToFrag = q - lightScreenPos;
    float beamTravel = dot(lightToFrag, beamDir);
    float beamPerp = abs(dot(lightToFrag, beamTangent));
    float beamWidth = 0.060 + beamTravel * 0.095;
    float screenBeam = exp(-(beamPerp * beamPerp) / max(beamWidth * beamWidth, 1e-4))
                     * smoothstep(0.0, 0.28, beamTravel)
                     * smoothstep(screenRadius * 1.55, screenRadius * 0.20, beamTravel);
    float centerFocus = exp(-dot((q - logoCenter) / (logoScale * kCenterFocusRadius),
                                 (q - logoCenter) / (logoScale * kCenterFocusRadius)));

    float outside = max(logoD, 0.0);
    float broadGlow = exp(-outside * 6.0) * outsideMask;
    float tightGlow = exp(-outside * 34.0) * outsideMask;
    float2 logoRadial = normalize(p - float2(0.0, -0.04));
    float exteriorLight = smoothstep(-0.30, 0.95, dot(logoRadial, lightDir));
    float orbitalAura = screenBeam * centerFocus * outsideMask;
    color += kBroadGlowColor * broadGlow;
    color += lightColor * screenBeam * outsideMask * 0.055;
    color += lightColor * tightGlow * (0.04 + 0.68 * exteriorLight * screenBeam);
    color += lightColor * orbitalAura * 0.42;

    // Rounded virtual 3D glass volume, inferred from AppleRoundedGlass.*.
    // The SVG silhouette remains the mask, but shading now comes from a domed
    // apple/leaf height field, rounded rim normals, Fresnel reflection, and
    // refracted caustics rather than a flat 2D fill.
    float n = fbm21(p * 2.1 + float2(t * 0.018, -t * 0.013));
    float bodyInner = max(-bodyD, 0.0);
    float bodyInnerLocal = max(-bodyLocalD, 0.0);
    float2 bodyCenter = kBodyCenter;
    float2 bodyP = p - bodyCenter;
    float bodyS = length(bodyP / kBodyDomeRadius);
    float bodyRound = pow(clamp(1.0 - bodyS * bodyS, 0.0, 1.0), kBodyRoundPower);
    float bodyLowerFullness = 1.0 + kBodyLowerFullness * max(0.0, -normalize(bodyP + float2(1e-4)).y);
    float bodyHeight = kBodyBaseThickness + kBodyDomeThickness * bodyRound * bodyLowerFullness;
    float2 bodyEdgeNormal2 = normalize(float2(dfdx(bodyLocalD), dfdy(bodyLocalD)) + float2(1e-5));
    float3 bodyDomeNormal = normalize(float3(bodyP.x * kBodyDomeSlope / (kBodyDomeRadius.x * kBodyDomeRadius.x), bodyP.y * kBodyDomeSlope / (kBodyDomeRadius.y * kBodyDomeRadius.y), max(bodyRound, 0.18)));
    float3 bodyRimNormal = normalize(float3(bodyEdgeNormal2 * kBodyRimXYStrength, kBodyRimZStrength));
    float bodyRimBlend = 1.0 - smoothstep(kBodyRimBlendNear, kBodyRimBlendFar, bodyInnerLocal);
    float3 bodyNormal = normalize(mix(bodyDomeNormal, bodyRimNormal, bodyRimBlend));

    float3 viewDir = kViewDir;
    float3 bodyLight3 = normalize(float3(lightDir * 0.92, 0.54));
    float bodyDiffuse = clamp(dot(bodyNormal, bodyLight3), 0.0, 1.0);
    float bodyFacingLight = smoothstep(0.00, 0.88, bodyDiffuse);
    float bodyBackRim = smoothstep(0.66, -0.08, dot(bodyNormal, bodyLight3));
    float bodyFresnel = pow(clamp(1.0 - dot(bodyNormal, viewDir), 0.0, 1.0), 2.8);
    float bodySpec = pow(clamp(dot(reflect(-bodyLight3, bodyNormal), viewDir), 0.0, 1.0 ), kBodySpecPower);
    float bodyBroadSpec = pow(clamp(dot(reflect(-bodyLight3, bodyNormal), viewDir), 0.0, 1.0 ), kBodyBroadSpecPower);
    float bodyRefract = pow(clamp(dot(bodyNormal, normalize(float3(-lightDir * 0.75, 0.58))), 0.0, 1.0), 3.2);

    // Prism thickness follows light proximity: thickest on the edge nearest the
    // off-screen spotlight, tighter/thinner as the light moves away.
    float bodyLightProximity = pow(bodyFacingLight, 1.35);
    float bodyEdgeFalloff = mix(1400.0, 92.0, bodyLightProximity);
    float bodyInnerFalloff = mix(480.0, 38.0, bodyLightProximity);
    float bodyCausticAOffset = mix(0.002, 0.016, bodyLightProximity);
    float bodyCausticBOffset = mix(0.004, 0.034, bodyLightProximity);
    float bodyCausticAFalloff = mix(1100.0, 92.0, bodyLightProximity);
    float bodyCausticBFalloff = mix(700.0, 54.0, bodyLightProximity);

    float bodyEdge = exp(-abs(bodyD) * bodyEdgeFalloff);
    float bodyInnerWall = exp(-bodyInner * bodyInnerFalloff) * bodyMask;
    float bodyCausticA = exp(-abs(bodyD + bodyCausticAOffset) * bodyCausticAFalloff) * bodyMask;
    float bodyCausticB = exp(-abs(bodyD + bodyCausticBOffset) * bodyCausticBFalloff) * bodyMask;
    float movingHotspot = screenBeam * centerFocus * bodyEdge;
    float3 prismA = spectralEdge21(dot(bodyNormal.xy, lightDir) * 0.42 + bodyLocalD * 1.8 + lightAngle * 0.08);
    float3 prismB = spectralEdge21(dot(bodyNormal.xy, float2(-lightDir.y, lightDir.x)) * 0.52 - lightAngle * 0.06);

    float bodyInternalLight = bodyMask * bodyHeight * (0.08 + 0.46 * bodyDiffuse) * (0.55 + 0.45 * bodyRound);
    float lowerInternalBounce = exp(-dot((bodyP - float2(-0.10, -0.34)) / float2(0.62, 0.28),
                                        (bodyP - float2(-0.10, -0.34)) / float2(0.62, 0.28))) * bodyMask;
    // Large refracted white sheet, like the original image: bright but shaped by
    // the rounded volume so it reads as internal reflection, not flat milkiness.
    float bodyWhiteSheet = smoothstep(0.20, -0.48, bodyP.y + 0.36 * bodyP.x + 0.05)
                         * smoothstep(1.02, 0.30, bodyS)
                         * bodyMask;
    float bodyWhiteCore = exp(-dot((bodyP - float2(-0.16, -0.46)) / float2(0.72, 0.34),
                                   (bodyP - float2(-0.16, -0.46)) / float2(0.72, 0.34))) * bodyMask;
    float bodyWhiteRefraction = (bodyWhiteSheet * 0.58 + bodyWhiteCore * 0.44) * (0.48 + 0.52 * bodyRefract);

    float3 bodyFill = kGlassBaseColor;
    bodyFill += kBodyNoiseColor * n * bodyMask;
    bodyFill += float3(0.030, 0.044, 0.085) * bodyInternalLight;
    bodyFill += float3(0.92, 0.96, 1.00) * bodyWhiteRefraction;
    bodyFill += kWhiteReflectionColor * (bodySpec * kBodySpecStrength + bodyBroadSpec * kBodyBroadSpecStrength) * bodyMask;
    bodyFill += float3(0.72, 0.80, 1.00) * lowerInternalBounce * bodyRefract * 0.42;
    bodyFill += mix(prismA, lightColor, 0.24) * bodyRefract * bodyMask * (0.12 + 0.36 * bodyDiffuse);
    bodyFill += prismA * bodyEdge * (0.34 + 1.35 * bodyFacingLight + 0.55 * bodyFresnel);
    bodyFill += prismB * bodyInnerWall * (0.10 + 0.70 * bodyFacingLight);
    bodyFill += prismA * bodyCausticA * (0.16 + 0.55 * bodyFacingLight);
    bodyFill += prismB * bodyCausticB * (0.08 + 0.28 * bodyBackRim);
    bodyFill += lightColor * bodyEdge * bodyFacingLight * 1.45;
    bodyFill += lightColor * movingHotspot * 0.22;

    // Leaf uses the same rounded-volume model, but with its own light direction
    // 180 degrees from the body light.
    float2 leafLightDir = -lightDir;
    float3 leafLightColor = mix(float3(0.20, 0.78, 1.00), float3(1.00, 0.50, 0.18), 0.5 + 0.5 * sin(lightAngle + 0.8));
    leafLightColor = mix(float3(0.95, 0.97, 1.0), leafLightColor, 0.28);
    float2 leafCenter = kLeafCenter;
    float2 leafP = p - leafCenter;
    float leafInnerLocal = max(-leafLocalD, 0.0);
    float leafS = length(leafP / kLeafDomeRadius);
    float leafRound = pow(clamp(1.0 - leafS * leafS, 0.0, 1.0), kBodyRoundPower);
    float2 leafEdgeNormal2 = normalize(float2(dfdx(leafLocalD), dfdy(leafLocalD)) + float2(1e-5));
    float3 leafDomeNormal = normalize(float3(leafP.x * kLeafDomeSlope / (kLeafDomeRadius.x * kLeafDomeRadius.x), leafP.y * kLeafDomeSlope / (kLeafDomeRadius.y * kLeafDomeRadius.y), max(leafRound, 0.22)));
    float3 leafRimNormal = normalize(float3(leafEdgeNormal2 * kLeafRimXYStrength, kLeafRimZStrength));
    float leafRimBlend = 1.0 - smoothstep(kLeafRimBlendNear, kLeafRimBlendFar, leafInnerLocal);
    float3 leafNormal = normalize(mix(leafDomeNormal, leafRimNormal, leafRimBlend));
    float3 leafLight3 = normalize(float3(leafLightDir * 0.88, 0.62));
    float leafDiffuse = clamp(dot(leafNormal, leafLight3), 0.0, 1.0);
    float leafFacingLight = smoothstep(0.00, 0.88, leafDiffuse);
    float leafSpec = pow(clamp(dot(reflect(-leafLight3, leafNormal), viewDir), 0.0, 1.0 ), kLeafSpecPower);
    float leafBroadSpec = pow(clamp(dot(reflect(-leafLight3, leafNormal), viewDir), 0.0, 1.0 ), kLeafBroadSpecPower);
    float leafRefract = pow(clamp(dot(leafNormal, normalize(float3(-leafLightDir * 0.72, 0.62))), 0.0, 1.0), 3.0);
    float leafLightProximity = pow(leafFacingLight, 1.35);
    float leafEdge = exp(-abs(leafD) * mix(1500.0, 105.0, leafLightProximity));
    float3 leafPrism = spectralEdge21(dot(leafNormal.xy, leafLightDir) * 0.48 + leafLocalD * 1.6 + lightAngle * 0.08 + 0.5);
    float leafInternalLight = leafMask * (0.06 + 0.42 * leafDiffuse) * (0.45 + 0.55 * leafRound);
    float leafWhitePlate = exp(-dot((leafP - leafLightDir * 0.10) / float2(0.34, 0.15),
                                    (leafP - leafLightDir * 0.10) / float2(0.34, 0.15))) * leafMask;
    float leafWhiteRake = smoothstep(0.26, -0.08, leafP.y - 0.34 * leafP.x)
                        * smoothstep(0.96, 0.25, leafS)
                        * leafMask;
    float leafWhiteRefraction = (leafWhitePlate * 0.28 + leafWhiteRake * 0.16) * (0.32 + 0.42 * leafRefract);
    float3 leafFill = kGlassBaseColor;
    leafFill += kLeafInternalColor * leafInternalLight;
    leafFill += kWhiteReflectionColor * leafWhiteRefraction;
    leafFill += kWhiteReflectionColor * (leafSpec * kLeafSpecStrength + leafBroadSpec * kLeafBroadSpecStrength) * leafMask;
    leafFill += mix(leafPrism, leafLightColor, 0.22) * leafRefract * leafMask * (0.08 + 0.22 * leafDiffuse);
    leafFill += leafPrism * leafEdge * (0.24 + 1.05 * leafFacingLight);
    leafFill += leafLightColor * leafEdge * leafFacingLight * 1.05;

    float3 insideFill = mix(bodyFill, leafFill, leafMask);
    color = mix(color, insideFill, logoMask);

    // Bloom spills only from the lit glass edge/aura, so it follows the orbiting
    // light instead of glowing uniformly.
    float outsidePrismProximity = exteriorLight * screenBeam;
    color += lightColor * exp(-outside * mix(290.0, 24.0, outsidePrismProximity)) * outsidePrismProximity * outsideMask * 0.34;
    color += spectralEdge21(dot(p, lightDir) * 0.22 + lightAngle * 0.06) * exp(-outside * mix(430.0, 36.0, outsidePrismProximity)) * outsidePrismProximity * outsideMask * 0.14;

    // Darken corners; reference background is nearly black.
    float vig = smoothstep(1.05, 0.20, vignetteR);
    color *= 0.62 + 0.38 * vig;

    color = 1.0 - exp(-color * 1.22);
    color = pow(color, float3(0.90));
    return float4(color, 1.0);
}
