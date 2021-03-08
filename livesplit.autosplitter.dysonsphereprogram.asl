state("DSPGAME", "0.6.17.5827")
{
    // DspGame.GameMain fields
    long timei      : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x28;
    double timef    : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x30;
    bool running    : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x38;
    bool loading    : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x39;
    bool paused     : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x3B;
    bool isMenuDemo : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x3F;
    bool ended      : "mono.dll", 0x00265A68, 0xA0, 0xE68, 0x3E;
    
    // DspGame.GameMain.GameData.GameHistoryData fields
    int currentTech           : "mono.dll", 0x002685D8, 0xEC8, 0x40, 0x4c;
    bool missionAccomplished  : "mono.dll", 0x002685D8, 0xEC8, 0x40, 0xA8;

    // DspGame.GameMain.GameData.GameHistoryData.techStates.Values
    byte6680 techStates       : "mono.dll", 0x002685D8, 0xEC8, 0x40, 0x28, 0x28, 0x48;
    
    /*
    251 TechStates in array, but only 168 techs/upgrades as of 2021-02-27, followed by bunches of 0s

    Can use the following memory signature to search for the TechState array:
    FB00000000000000
    01000000000000000000000000000000010000000000000001000000000000000000000000000000
    0?000000000000000000000000000000????000000000000B0040000000000000000000000000000
    0?000000000000000000000000000000????00000000000008070000000000000000000000000000

    We skip the 8 byte length field and first 40 byte entry with the last offset of 0x48

    struct TechState               // 40 bytes
    {
        public bool unlocked;      // 4 bytes
        public int curLevel;       // 4 bytes 
        public int maxLevel;       // 4 bytes
                                   // 4 byte pad
        public long hashUploaded;  // 8 bytes
        public long hashNeeded;    // 8 bytes
        public int uPointPerHash;  // 4 bytes
                                   // 4 byte pad
    }
    */
}

startup
{
    // Technology/Upgrades
    /////////////////////////////////////

    // techId, name, T (technology) or U (upgrade), max hash, default settings (t/f)
    // could do a sanity check to make sure the "hashNeeded" field in techStates matches this list
    var techNames = new Dictionary<int, string>()
    {
        { 1001, "Electromagnetism                        ,T,1200,t" },
        { 1002, "Electromagnetic Matrix                  ,T,1800,t" },
        { 1101, "High-Efficiency Plasma Control          ,T,9000,t" },
        { 1102, "Plasma Extract Refining                 ,T,36000,t" },
        { 1103, "X-ray Cracking                          ,T,72000,t" },
        { 1111, "Energy Matrix                           ,T,36000,t" },
        { 1112, "Hydrogen Fuel Rod                       ,T,72000,t" },
        { 1113, "Thruster                                ,T,180000,t" },
        { 1114, "Reinforced Thruster                     ,T,288000,t" },
        { 1120, "Fluid Storage Encapsulation             ,T,9000,t" },
        { 1121, "Basic Chemical Engineering              ,T,72000,t" },
        { 1122, "Polymer Chemical Engineering            ,T,72000,t" },
        { 1123, "High-Strength Crystal                   ,T,108000,t" },
        { 1124, "Structure Matrix                        ,T,240000,t" },
        { 1125, "Casimir Crystal                         ,T,240000,t" },
        { 1126, "High-Strength Glass                     ,T,240000,t" },
        { 1131, "Applied Superconductor                  ,T,72000,t" },
        { 1132, "High-Strength Material                  ,T,135000,t" },
        { 1133, "Particle Control Technology             ,T,180000,t" },
        { 1134, "Deuterium Fractionation                 ,T,36000,t" },
        { 1141, "Wave Function Interference              ,T,360000,t" },
        { 1142, "Miniature Particle Collider             ,T,240000,t" },
        { 1143, "Strange Matter                          ,T,300000,t" },
        { 1144, "Artificial Star                         ,T,432000,f" },
        { 1145, "Controlled Annihilation Reaction        ,T,600000,f" },
        { 1151, "Accelerant Mk. I (Coming Soon)          ,T,36000,t" },
        { 1152, "Accelerant Mk. II (Coming Soon)         ,T,180000,t" },
        { 1153, "Accelerant Mk. III (Coming Soon)        ,T,360000,t" },
        { 1201, "Basic Assembling Processes              ,T,1800,t" },
        { 1202, "High-Speed Assembling Processes         ,T,108000,t" },
        { 1203, "Quantum Printing Technology             ,T,288000,f" },
        { 1302, "Processor                               ,T,144000,t" },
        { 1303, "Quantum Chip                            ,T,288000,t" },
        { 1311, "Semiconductor Material                  ,T,18000,t" },
        { 1312, "Information Matrix                      ,T,288000,t" },
        { 1401, "Automatic Metallurgy                    ,T,1800,t" },
        { 1402, "Smelting Purification                   ,T,18000,t" },
        { 1403, "Crystal Smelting                        ,T,90000,t" },
        { 1411, "Steel Smelting                          ,T,21600,t" },
        { 1412, "Thermal Power                           ,T,5400,t" },
        { 1413, "Titanium Smelting                       ,T,36000,t" },
        { 1414, "High-Strength Titanium Alloy            ,T,144000,t" },
        { 1415, "Environment Modification                ,T,72000,t" },
        { 1416, "Mini Fusion Power Generation            ,T,180000,t" },
        { 1501, "Solar Collection                        ,T,18000,t" },
        { 1502, "Photon Frequency Conversion             ,T,36000,t" },
        { 1503, "Solar Sail Orbit System                 ,T,54000,t" },
        { 1504, "Ray Receiver                            ,T,108000,t" },
        { 1505, "Planetary Ionosphere Utilization        ,T,360000,t" },
        { 1506, "Dirac Inversion Mechanism               ,T,540000,t" },
        { 1507, "Universe Matrix                         ,T,720000,t" },
        { 1508, "Mission Completed!                      ,T,3600000,t" },
        { 1511, "Energy Storage                          ,T,108000,t" },
        { 1512, "Interstellar Power Transmission         ,T,216000,t" },
        { 1521, "High-Strength Lightweight Structure     ,T,360000,t" },
        { 1522, "Vertical Launching Silo                 ,T,576000,t" },
        { 1523, "Dyson Sphere Stress System              ,T,360000,f" },
        { 1601, "Basic Logistics System                  ,T,1800,t" },
        { 1602, "Improved Logistics System               ,T,18000,t" },
        { 1603, "High-Efficiency Logistics System        ,T,72000,t" },
        { 1604, "Planetary Logistics System              ,T,144000,t" },
        { 1605, "Interstellar Logistics System           ,T,216000,t" },
        { 1606, "Gas Giants Exploitation                 ,T,432000,f" },
        { 1701, "Electromagnetic Drive                   ,T,9000,t" },
        { 1702, "Magnetic Levitation Technology          ,T,72000,t" },
        { 1703, "Magnetic Particle Trap                  ,T,288000,t" },
        { 1704, "Gravitational Wave Refraction           ,T,360000,t" },
        { 1705, "Gravity Matrix                          ,T,576000,t" },
        { 1711, "Super Magnetic Field Generator          ,T,180000,t" },
        { 1712, "Satellite Power Distribution System     ,T,240000,t" },
        { 2101, "Mecha Core 1                            ,U,3600,t" },
        { 2102, "Mecha Core 2                            ,U,36000,t" },
        { 2103, "Mecha Core 3                            ,U,108000,t" },
        { 2104, "Mecha Core 4                            ,U,300000,f" },
        { 2105, "Mecha Core 5                            ,U,1440000,f" },
        { 2106, "Mecha Core ∞                            ,U,1800000,f" },
        { 2201, "Mechanical Frame 1                      ,U,7200,t" },
        { 2202, "Mechanical Frame 2                      ,U,36000,t" },
        { 2203, "Mechanical Frame 3                      ,U,72000,t" },
        { 2204, "Mechanical Frame 4                      ,U,180000,t" },
        { 2205, "Mechanical Frame 5                      ,U,240000,t" },
        { 2206, "Mechanical Frame 6                      ,U,300000,f" },
        { 2207, "Mechanical Frame 7                      ,U,360000,f" },
        { 2208, "Mechanical Frame 8                      ,U,1200000,f" },
        { 2301, "Inventory Capacity 1                    ,U,7200,t" },
        { 2302, "Inventory Capacity 2                    ,U,36000,t" },
        { 2303, "Inventory Capacity 3                    ,U,72000,t" },
        { 2304, "Inventory Capacity 4                    ,U,180000,t" },
        { 2305, "Inventory Capacity 5                    ,U,240000,t" },
        { 2306, "Inventory Capacity 6                    ,U,600000,f" },
        { 2401, "Communication Control 1                 ,U,9000,t" },
        { 2402, "Communication Control 2                 ,U,36000,t" },
        { 2403, "Communication Control 3                 ,U,72000,t" },
        { 2404, "Communication Control 4                 ,U,180000,t" },
        { 2405, "Communication Control 5                 ,U,300000,f" },
        { 2406, "Communication Control 6                 ,U,1440000,f" },
        { 2407, "Communication Control ∞                 ,U,1800000,f" },
        { 2501, "Energy Circuit 1                        ,U,7200,t" },
        { 2502, "Energy Circuit 2                        ,U,72000,t" },
        { 2503, "Energy Circuit 3                        ,U,216000,t" },
        { 2504, "Energy Circuit 4                        ,U,600000,f" },
        { 2505, "Energy Circuit 5                        ,U,2700000,f" },
        { 2506, "Energy Circuit ∞                        ,U,3600000,f" },
        { 2601, "Drone Engine 1                          ,U,18000,t" },
        { 2602, "Drone Engine 2                          ,U,72000,t" },
        { 2603, "Drone Engine 3                          ,U,144000,t" },
        { 2604, "Drone Engine 4                          ,U,360000,f" },
        { 2605, "Drone Engine 5                          ,U,1440000,f" },
        { 2606, "Drone Engine ∞                          ,U,1800000,f" },
        { 2901, "Drive Engine 1                          ,U,10800,t" },
        { 2902, "Drive Engine 2                          ,U,36000,t" },
        { 2903, "Drive Engine 3                          ,U,180000,t" },
        { 2904, "Drive Engine 4                          ,U,720000,f" },
        { 3281, "Solar Sail Life 1                       ,U,36000,f" },
        { 3282, "Solar Sail Life 2                       ,U,108000,f" },
        { 3283, "Solar Sail Life 3                       ,U,144000,f" },
        { 3284, "Solar Sail Life 4                       ,U,300000,f" },
        { 3285, "Solar Sail Life 5                       ,U,480000,f" },
        { 3286, "Solar Sail Life 6                       ,U,1200000,f" },
        { 3201, "Ray Transmission Efficiency 1           ,U,54000,f" },
        { 3202, "Ray Transmission Efficiency 2           ,U,144000,f" },
        { 3203, "Ray Transmission Efficiency 3           ,U,180000,f" },
        { 3204, "Ray Transmission Efficiency 4           ,U,360000,f" },
        { 3205, "Ray Transmission Efficiency 5           ,U,420000,f" },
        { 3206, "Ray Transmission Efficiency 6           ,U,480000,f" },
        { 3207, "Ray Transmission Efficiency 7           ,U,1620000,f" },
        { 3208, "Ray Transmission Efficiency ∞           ,U,1800000,f" },
        { 3301, "Sorter Cargo Stacking 1                 ,U,36000,f" },
        { 3302, "Sorter Cargo Stacking 2                 ,U,108000,f" },
        { 3303, "Sorter Cargo Stacking 3                 ,U,144000,f" },
        { 3304, "Sorter Cargo Stacking 4                 ,U,300000,f" },
        { 3305, "Sorter Cargo Stacking 5                 ,U,900000,f" },
        { 3401, "Logistics Carrier Engine 1              ,U,36000,t" },
        { 3402, "Logistics Carrier Engine 2              ,U,108000,t" },
        { 3403, "Logistics Carrier Engine 3              ,U,144000,f" },
        { 3404, "Logistics Carrier Engine 4              ,U,300000,f" },
        { 3405, "Logistics Carrier Engine 5              ,U,360000,f" },
        { 3406, "Logistics Carrier Engine 6              ,U,1440000,f" },
        { 3407, "Logistics Carrier Engine ∞              ,U,1800000,f" },
        { 3501, "Logistics Carrier Capacity 1            ,U,36000,t" },
        { 3502, "Logistics Carrier Capacity 2            ,U,108000,t" },
        { 3503, "Logistics Carrier Capacity 3            ,U,144000,f" },
        { 3504, "Logistics Carrier Capacity 4            ,U,300000,f" },
        { 3505, "Logistics Carrier Capacity 5            ,U,720000,f" },
        { 3506, "Logistics Carrier Capacity 6            ,U,960000,f" },
        { 3507, "Logistics Carrier Capacity 7            ,U,2400000,f" },
        { 3508, "Logistics Carrier Capacity 8            ,U,4800000,f" },
        { 3601, "Veins Utilization 1                     ,U,36000,t" },
        { 3602, "Veins Utilization 2                     ,U,180000,t" },
        { 3603, "Veins Utilization 3                     ,U,180000,f" },
        { 3604, "Veins Utilization 4                     ,U,480000,f" },
        { 3605, "Veins Utilization 5                     ,U,1800000,f" },
        { 3606, "Veins Utilization ∞                     ,U,3600000,f" },
        { 3701, "Vertical Construction 1                 ,U,36000,t" },
        { 3702, "Vertical Construction 2                 ,U,108000,t" },
        { 3703, "Vertical Construction 3                 ,U,144000,f" },
        { 3704, "Vertical Construction 4                 ,U,300000,f" },
        { 3705, "Vertical Construction 5                 ,U,480000,f" },
        { 3706, "Vertical Construction 6                 ,U,1200000,f" },
        { 3901, "Research Speed 1                        ,U,600000,t" },
        { 3902, "Research Speed 2                        ,U,1200000,f" },
        { 3903, "Research Speed 3                        ,U,2400000,f" },
        { 3904, "Research Speed ∞                        ,U,14400000,f" },
        { 261 , "Universe Exploration 1                  ,U,1800,t" },
        { 262 , "Universe Exploration 2                  ,U,36000,f" },
        { 263 , "Universe Exploration 3                  ,U,300000,f" },
        { 264 , "Universe Exploration 4                  ,U,1200000,f" }
    };

    int[] ids = new int[techNames.Keys.Count];
    techNames.Keys.CopyTo(ids, 0);
    vars.techIds = new List<int>(ids);
    vars.techName = new Dictionary<int, string>();

    settings.Add("T", true, "Split When Technologies are Researched");
    settings.Add("U", true, "Split When Upgrades are Researched");
    foreach (var p in techNames)
    {
        string[] tech = p.Value.Split(',');
        settings.Add("t" + p.Key, tech[3] == "t", tech[0].Trim(), tech[1]);
        vars.techName.Add(p.Key, tech[0].Trim());
    }

    // Production
    /////////////////////////////////////

    // itemId, description, split on total built, rate/sec split targets 1/2/3/4, default settings (t/f)
    vars.items = new Dictionary<int, dynamic>() 
    {
        { 1001, new { desc = "Iron Ore"                      , total = 1, rate0 =  1, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1002, new { desc = "Copper Ore"                    , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1003, new { desc = "Silicon Ore"                   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1004, new { desc = "Titanium Ore"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1005, new { desc = "Stone Ore"                     , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1006, new { desc = "Coal"                          , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1030, new { desc = "Log"                           , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1031, new { desc = "Plant fuel"                    , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1011, new { desc = "Fire ice"                      , total = 0, rate0 = 18, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1012, new { desc = "Kimberlite ore"                , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1013, new { desc = "Fractal silicon"               , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1014, new { desc = "Optical grating crystal"       , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1015, new { desc = "Spiniform stalagmite crystal"  , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1016, new { desc = "Unipolar magnet"               , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1101, new { desc = "Iron ingot"                    , total = 0, rate0 =  6, rate1 = 30, rate2 =  0, rate3 =  0 } },
        { 1104, new { desc = "Copper Ingot"                  , total = 0, rate0 =  6, rate1 = 54, rate2 =  0, rate3 =  0 } },
        { 1105, new { desc = "High-purity Silicon"           , total = 0, rate0 = 60, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1106, new { desc = "Titanium Ingot"                , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1108, new { desc = "Stone brick"                   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1109, new { desc = "Energetic Graphite"            , total = 0, rate0 = 12, rate1 = 18, rate2 = 24, rate3 = 36 } },
        { 1103, new { desc = "Steel"                         , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1107, new { desc = "Titanium alloy"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1110, new { desc = "Glass"                         , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1119, new { desc = "Titanium glass"                , total = 0, rate0 = 12, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1111, new { desc = "Prism"                         , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1112, new { desc = "Diamond"                       , total = 0, rate0 =  6, rate1 = 18, rate2 =  0, rate3 =  0 } },
        { 1113, new { desc = "Crystal silicon"               , total = 1, rate0 = 12, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1201, new { desc = "Gear"                          , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1102, new { desc = "Magnet"                        , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1202, new { desc = "Magnetic Coil"                 , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1203, new { desc = "Electric motor"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1204, new { desc = "Electromechanic turbine"       , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1205, new { desc = "Super-magnetic ring"           , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1206, new { desc = "Particle container"            , total = 1, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1127, new { desc = "Strange matter"                , total = 0, rate0 =  3, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1301, new { desc = "Circuit board"                 , total = 0, rate0 =  6, rate1 = 30, rate2 =  0, rate3 =  0 } },
        { 1303, new { desc = "Processor"                     , total = 1, rate0 = 12, rate1 = 18, rate2 =  0, rate3 =  0 } },
        { 1305, new { desc = "Quantum chip"                  , total = 0, rate0 =  3, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1302, new { desc = "Microcrystalline component"    , total = 1, rate0 = 24, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1304, new { desc = "Plane filter"                  , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1402, new { desc = "Particle broadband"            , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1401, new { desc = "Plasma excitor"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1404, new { desc = "Photon combiner"               , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1501, new { desc = "Solar sail"                    , total = 0, rate0 = 36, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1000, new { desc = "Water"                         , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1007, new { desc = "Crude oil"                     , total = 0, rate0 = 24, rate1 = 30, rate2 = 36, rate3 =  0 } },
        { 1114, new { desc = "Refined oil"                   , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1116, new { desc = "Sulfuric acid"                 , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1120, new { desc = "Hydrogen"                      , total = 0, rate0 = 12, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1121, new { desc = "Deuterium"                     , total = 1, rate0 = 30, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1122, new { desc = "Antimatter"                    , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1208, new { desc = "Critical photon"               , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1801, new { desc = "Hydrogen fuel rod"             , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1802, new { desc = "Deuteron fuel rod"             , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1803, new { desc = "Antimatter fuel rod"           , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1115, new { desc = "Plastic"                       , total = 0, rate0 = 12, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1123, new { desc = "Graphene"                      , total = 0, rate0 = 18, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1124, new { desc = "Carbon nanotube"               , total = 0, rate0 = 12, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1117, new { desc = "Organic crystal"               , total = 0, rate0 =  6, rate1 = 12, rate2 =  0, rate3 =  0 } },
        { 1118, new { desc = "Titanium crystal"              , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1126, new { desc = "Casimir crystal"               , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1209, new { desc = "Graviton lens"                 , total = 0, rate0 =  3, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1210, new { desc = "Space warper"                  , total = 2, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1403, new { desc = "Annihilation constraint sphere", total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1405, new { desc = "Thruster"                      , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1406, new { desc = "Reinforced thruster"           , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 5001, new { desc = "Logistics drone"               , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 5002, new { desc = "Logistics vessel"              , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1125, new { desc = "Frame material"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1502, new { desc = "Dyson sphere component"        , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1503, new { desc = "Small carrier rocket"          , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1131, new { desc = "Foundation"                    , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1141, new { desc = "Accelerant Mk. I"              , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1142, new { desc = "Accelerant Mk. II"             , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 1143, new { desc = "Accelerant Mk. III"            , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2001, new { desc = "Conveyor belt Mk. I"           , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2002, new { desc = "Conveyor belt Mk. II"          , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2003, new { desc = "Conveyor belt Mk. III"         , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2011, new { desc = "Sorter Mk. I"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2012, new { desc = "Sorter Mk. II"                 , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2013, new { desc = "Sorter Mk. II"                 , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2020, new { desc = "Splitter"                      , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2101, new { desc = "Storage Mk. I"                 , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2102, new { desc = "Storage Mk. II"                , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2106, new { desc = "Storage tank"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2303, new { desc = "Assembly machine Mk. I"        , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2304, new { desc = "Assembly machine Mk. II"       , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2305, new { desc = "Assembly machine Mk. III"      , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2201, new { desc = "Tesla tower"                   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2202, new { desc = "Wireless power tower"          , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2212, new { desc = "Satellite substation"          , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2203, new { desc = "Wind turbine"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2204, new { desc = "Thermal power station"         , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2211, new { desc = "Mini fusion power station"     , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2301, new { desc = "Mining machine"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2302, new { desc = "Smelter"                       , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2307, new { desc = "Oil extractor"                 , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2308, new { desc = "Oil refinery"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2306, new { desc = "Water pump"                    , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2309, new { desc = "Chemical plant"                , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2314, new { desc = "Fractionator"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2313, new { desc = "Spray coater"                  , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2205, new { desc = "Solar panel"                   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2206, new { desc = "Accumulator"                   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2207, new { desc = "Accumulator (full)"            , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2311, new { desc = "EM-Rail Ejector"               , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2208, new { desc = "Ray receiver"                  , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2312, new { desc = "Vertical launching silo"       , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2209, new { desc = "Energy exchanger"              , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2310, new { desc = "Miniature particle collider"   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2210, new { desc = "Artificial star"               , total = 0, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2103, new { desc = "Planetary logistics station"   , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2104, new { desc = "Interstellar logistics station", total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2105, new { desc = "Orbital collector"             , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 2901, new { desc = "Matrix lab"                    , total = 1, rate0 =  0, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6001, new { desc = "Electromagnetic matrix (blue)" , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6002, new { desc = "Energy matrix (red)"           , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6003, new { desc = "Structure matrix (yellow)"     , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6004, new { desc = "Information matrix (purple)"   , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6005, new { desc = "Gravity matrix (green)"        , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } },
        { 6006, new { desc = "Universe matrix (white)"       , total = 0, rate0 =  6, rate1 =  0, rate2 =  0, rate3 =  0 } }
    };

    vars.itemNames = new Dictionary<int, string>();
    vars.itemTotalGoals = new Dictionary<int, int>();
    vars.itemRateGoals = new Dictionary<int, List<int>>();

    settings.Add("P", true, "Split on First X Production of an Item");
    settings.Add("R", true, "Split on Item Production Rate");
    
    foreach (var p in vars.items)
    {
        var item = p.Value as dynamic;
        settings.Add("i" + p.Key, item.total != 0, item.desc, "P");
        vars.itemNames.Add(p.Key, item.desc);
        vars.itemTotalGoals.Add(p.Key, item.total);
        vars.itemRateGoals.Add(p.Key, new List<int>{item.rate0});
        if (item.rate0 != 0)
        {
            if (item.rate1 != 0) vars.itemRateGoals[p.Key].Add(item.rate1);
            if (item.rate2 != 0) vars.itemRateGoals[p.Key].Add(item.rate2);
            if (item.rate3 != 0) vars.itemRateGoals[p.Key].Add(item.rate3);

            if (item.rate0 != 0) settings.Add("r0." + p.Key, p.Key != 1001, item.rate0 + "/s - " + item.desc, "R"); 
            if (item.rate1 != 0) settings.Add("r1." + p.Key, true, item.rate1 + "/s - " + item.desc, "R");
            if (item.rate2 != 0) settings.Add("r2." + p.Key, true, item.rate2 + "/s - " + item.desc, "R");
            if (item.rate3 != 0) settings.Add("r3." + p.Key, true, item.rate3 + "/s - " + item.desc, "R");
        }
    }
    vars.itemNextRateGoal = new Dictionary<int, List<int>>(vars.itemRateGoals);
    vars.productionTotalsSec = new Dictionary<int, int>(); // per 1 sec
    vars.productionTotalsSecAge = new Dictionary<int, int>(); // <itemId, timef>

    // Power
    /////////////////////////////////////

    vars.powerGoals = new List<long>
    {
        30, 130, 260, 500, 700, 4500, 0 // in MW, ends with 0
    };
    vars.nextPowerGoal = vars.powerGoals[0];

    settings.Add("E", true, "Split on Electrical Generation (MW)");

    foreach (int e in vars.powerGoals)
    {
        if (e == 0) break;
        settings.Add("e" + e, true, "Generate " + e + " MW", "E");
    }
}

start
{
    bool shouldBeStarted = current.running && !current.isMenuDemo && current.timei > 0;
    bool wasStarted = old.running && !old.isMenuDemo && old.timei > 0;
    if (shouldBeStarted && !wasStarted)
    {
        vars.itemNextRateGoal = new Dictionary<int, List<int>>(vars.itemRateGoals);
        vars.nextPowerGoal = vars.powerGoals[0];
        vars.productionTotalsSec = new Dictionary<int, int>(); // per 1 sec
        vars.productionTotalsSecAge = new Dictionary<int, int>(); // <itemId, timef>
        return true;
    }
}

reset
{
    return current.isMenuDemo && !old.isMenuDemo;
}

isLoading
{
    return current.paused;
}

gameTime
{
    return TimeSpan.FromSeconds(current.timef);
}

split
{   
    if (!current.running || current.isMenuDemo || current.timei == 0) return false;

    //
    // Check Technologies
    //
    //////////////////////////////////////////////

    if (current.currentTech != old.currentTech && 
        old.currentTech != 0 &&
        settings.ContainsKey("t" + old.currentTech) && 
        settings["t" + old.currentTech] &&                                   // user has setting enabled
        vars.techIds.Contains(old.currentTech) &&
        old.techStates[vars.techIds.IndexOf(old.currentTech) * 40] == 0 &&   // was locked
        current.techStates[vars.techIds.IndexOf(old.currentTech) * 40] == 1  // is now unlocked
        )
    {
        print("LiveSplit: [" + current.timei + "] Splitting on technology: " + vars.techName[old.currentTech]);
        return true;
    }

    //
    // Check Production
    //
    //////////////////////////////////////////////

    current.productionTotals = new Dictionary<int, int>(); // per frame
    long powerGenTotal = 0;
    for (int factoryIndex = 0; factoryIndex < 1; factoryIndex++) // just do the home planet for now
    {
        powerGenTotal += new DeepPointer("mono.dll", 0x002685D8, 0xEC8, 0x48, 0x18, 0x18, 0x08 * factoryIndex + 0x20, 0x48).Deref<long>(game); 

        IntPtr productPoolArrayAddr = new DeepPointer("mono.dll", 0x002685D8, 0xEC8, 0x48, 0x18, 0x18, 0x08 * factoryIndex + 0x20, 0x10).Deref<IntPtr>(game);       
        if (productPoolArrayAddr == IntPtr.Zero) continue;
        int numProducts = (int) memory.ReadValue<long>(productPoolArrayAddr + 0x18);

        for (int i=1; i<numProducts; i++) 
        {
            IntPtr productStatAddr = memory.ReadValue<IntPtr>(productPoolArrayAddr + 0x08 * i + 0x20);
            if (productStatAddr == IntPtr.Zero) break;
            int itemId = memory.ReadValue<int>(productStatAddr + 0x28);
            if (itemId == 0 || !vars.items.ContainsKey(itemId)) break;

            // Total produced
            //////////////////////////////
            IntPtr totalsArrayAddr = memory.ReadValue<IntPtr>(productStatAddr + 0x20);
            int totalProduced = memory.ReadValue<int>(totalsArrayAddr + 0x38);
            current.productionTotals.Add(itemId, totalProduced);
            int totalProducedTarget = vars.itemTotalGoals[itemId];
            if (totalProducedTarget == 0) totalProducedTarget = 1;

            try 
            {
                if (totalProduced >= totalProducedTarget && 
                    old.productionTotals.ContainsKey(itemId) && old.productionTotals[itemId] < totalProducedTarget && 
                    settings.ContainsKey("i" + itemId) && settings["i" + itemId] 
                   ) 
                {
                    print("LiveSplit: [" + current.timei + "] Splitting on total produced [" + i + "]: " + vars.itemNames[itemId]);
                    return true;
                } 
            } 
            catch (Exception) 
            {
                // first time getting data
                continue;
            } 

            // Rates
            ////////////////////////////// 

            if (current.timef % 1 != 0) continue; // only check rates at 1 Hz
            if (!vars.productionTotalsSec.ContainsKey(itemId)) 
            {
                vars.productionTotalsSec.Add(itemId, totalProduced);
                vars.productionTotalsSecAge.Add(itemId, timef);
                continue;
            }
            int lastTotalProduced = vars.productionTotalsSec[itemId];
            double oldTimef = vars.productionTotalsSecAge[itemId];
            vars.productionTotalsSec[itemId] = totalProduced;
            vars.productionTotalsSecAge[itemId] = timef;

            if (timef - oldTimef > 1.5) continue;

            try 
            {
                if (!vars.itemNextRateGoal.ContainsKey(itemId)) continue;
                int rateTarget = vars.itemNextRateGoal[itemId][0];
                int rateProduced = totalProduced - lastTotalProduced; // items / sec
                if (rateProduced < rateTarget) continue;

                // set next rate goal
                int idx = vars.itemRateGoals[itemId].IndexOf(rateTarget);
                string keystring = "r" + idx + "." + itemId;
                vars.itemNextRateGoal[itemId].RemoveAt(0);
                if (0 == vars.itemNextRateGoal[itemId].Count) vars.itemNextRateGoal.Remove(itemId); 

                if (settings.ContainsKey(keystring) && settings[keystring])
                {
                    print("LiveSplit: [" + current.timei + "] Splitting on rate " + rateTarget + "/s: " + vars.itemNames[itemId]);
                    return true;
                }
            } 
            catch (Exception) 
            {
                // first time getting data
                continue;
            } 
        }
    }    
 
    // Power generation
    ////////////////////////////// 
    double powerGen = powerGenTotal / 16666.6666; // convert to MW
    if (vars.nextPowerGoal != 0 && powerGen >= vars.nextPowerGoal) 
    {
        string keystring = "e" + vars.nextPowerGoal;
        vars.nextPowerGoal = vars.powerGoals[vars.powerGoals.IndexOf(vars.nextPowerGoal) + 1];
        if (settings[keystring])
        {
            print("LiveSplit: [" + current.timei + " secs] Splitting on power goal of  " + keystring.Substring(1) + "MW");
            return true;
        }
        
    }
} 