state("DSPGAME")
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
    int currentTech           : "mono.dll", 0x002685D8, 0xEC8, 0x28, 0x4c;
    bool missionAccomplished  : "mono.dll", 0x002685D8, 0xEC8, 0x28, 0xA8;

    // DspGame.GameMain.GameData.GameHistoryData.techStates.Values
    byte6680 techStates       : "mono.dll", 0x0026AC30, 0x38, 0x118, 0x28, 0x28, 0x28, 0x48;
    
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
    // could do a sanity check to make sure the "hashNeeded" field in techStates matches 
    // this list
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
        { 264 , "Universe Exploration 4                  ,U,1200000,f" },
    };

    int[] ids = new int[techNames.Keys.Count];
    techNames.Keys.CopyTo(ids, 0);
    vars.techIds = new List<int>(ids);

    settings.Add("T", true, "Split When Technologies are Researched");
    settings.Add("U", true, "Split When Upgrades are Researched");
    foreach (var p in techNames)
    {
        string[] tech = p.Value.Split(',');
        settings.Add("t" + p.Key, tech[3] == "t", tech[0].Trim(), tech[1]);
    }

    // Production
    /////////////////////////////////////

    var itemNames = new Dictionary<int, string>()
    {
        { 1001, "Iron Ore,f" },
        { 1002, "Copper Ore,f" },
        { 1005, "Stone Ore,f" },
        { 1101, "Iron ingot,f" },
        { 1104, "Copper Ingot,f" },
        { 1108, "Stone brick,f" },
        { 1201, "Gear,f" },
        { 1102, "Magnet,f" },
        { 1202, "Magnetic Coil,f" },
        { 1301, "Circuit board,f" },
        { 2201, "Tesla tower,f" },
        { 2203, "Wind turbine,f" },
        { 2301, "Mining machine,f" },
    };

    int[] iids = new int[itemNames.Keys.Count];
    itemNames.Keys.CopyTo(iids, 0);
    vars.itemIds = new List<int>(iids);

    settings.Add("P", true, "Split on First Automatic Production of an Item");
    foreach (var p in itemNames)
    {
        string[] item = p.Value.Split(',');
        settings.Add("i" + p.Key, item[1] == "t", item[0], "P");
    }
}

start
{
    return current.running && !current.isMenuDemo && current.timei > 0 && old.timei == 0;
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
    // make sure you're Timer's layout is using GameTime!
    return TimeSpan.FromSeconds(current.timef);
}

split
{   
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
        return true;
    }

    //
    // Check Production
    //
    //////////////////////////////////////////////
    
    // DspGame.GameMain.GameData.GameStatData.ProductionStatistics.FactoryProductPool[0-? num planets].productPool[0-? num items].itemId
    // DspGame.GameMain.GameData.GameStatData.ProductionStatistics.FactoryProductPool[0-? num planets].productPool[0-? num items].total[6]
    // notice: the productPools are not sorted, which makes this a difficult task

    current.productionTotals = new Dictionary<int, int>();
    int factoryIndex = 0; // just look at planet/factory 0 to save resources
    IntPtr productPoolArrayAddr = new DeepPointer("mono.dll", 0x0026AC30, 0x38, 0x118, 0x30, 0x18, 0x18, 0x08 * factoryIndex + 0x20, 0x10).Deref<IntPtr>(game); 
    if (productPoolArrayAddr != IntPtr.Zero)
    {
        int numProducts = (int) memory.ReadValue<long>(productPoolArrayAddr + 0x18);
        for (int i=0; i<numProducts; i++) 
        {
            IntPtr productStatAddr = memory.ReadValue<IntPtr>(productPoolArrayAddr + 0x08 * i + 0x20);
            int itemId = memory.ReadValue<int>(productStatAddr + 0x28);
            if (itemId != 0 && vars.itemIds.Contains(itemId)) 
            {
                IntPtr totalsArrayAddr = memory.ReadValue<IntPtr>(productStatAddr + 0x20);
                int totalProduced = memory.ReadValue<int>(totalsArrayAddr + 0x38);
                current.productionTotals.Add(itemId, totalProduced);

                if (totalProduced > 0 && // <-- this is always true  
                    !old.productionTotals.ContainsKey(itemId) && 
                    settings.ContainsKey("i" + itemId) &&
                    settings["i" + itemId] 
                   ) 
                {
                    return true;
                }
            }
        }
    }
} 
