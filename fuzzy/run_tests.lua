#!/usr/bin/env luajit

-- Test runner for double metaphone algorithm
-- This script runs the test suite and reports failures

local doubleMetaphone = require('fuzzy.double_metaphone')

local TEST_CASES = {
    { "ALLERTON",         "ALRTN",    "ALRTN" },
    { "Acton",            "AKTN",     "AKTN" },
    { "Adams",            "ATMS",     "ATMS" },
    { "Aggar",            "AKR",      "AKR" },
    { "Ahl",              "AL",       "AL" },
    { "Aiken",            "AKN",      "AKN" },
    { "Alan",             "ALN",      "ALN" },
    { "Alcock",           "ALKK",     "ALKK" },
    { "Alden",            "ALTN",     "ALTN" },
    { "Aldham",           "ALTM",     "ALTM" },
    { "Allen",            "ALN",      "ALN" },
    { "Allerton",         "ALRTN",    "ALRTN" },
    { "Alsop",            "ALSP",     "ALSP" },
    { "Alwein",           "ALN",      "ALN" },
    { "Ambler",           "AMPLR",    "AMPLR" },
    { "Andevill",         "ANTFL",    "ANTFL" },
    { "Andrews",          "ANTRS",    "ANTRS" },
    { "Andreyco",         "ANTRK",    "ANTRK" },
    { "Andriesse",        "ANTRS",    "ANTRS" },
    { "Angier",           "ANJ",      "ANJR" },
    { "Annabel",          "ANPL",     "ANPL" },
    { "Anne",             "AN",       "AN" },
    { "Anstye",           "ANST",     "ANST" },
    { "Appling",          "APLNK",    "APLNK" },
    { "Apuke",            "APK",      "APK" },
    { "Arnold",           "ARNLT",    "ARNLT" },
    { "Ashby",            "AXP",      "AXP" },
    { "Astwood",          "ASTT",     "ASTT" },
    { "Atkinson",         "ATKNSN",   "ATKNSN" },
    { "Audley",           "ATL",      "ATL" },
    { "Austin",           "ASTN",     "ASTN" },
    { "Avenal",           "AFNL",     "AFNL" },
    { "Ayer",             "AR",       "AR" },
    { "Ayot",             "AT",       "AT" },
    { "Bachelor",         "PXLR",     "PKLR" },
    { "Beauchamp",        "PXMP",     "PKMP" },
    { "Beech",            "PX",       "PK" },
    { "Bergen",           "PRJN",     "PRKN" },
    { "Bigelow",          "PJL",      "PKLF" },
    { "Bouchier",         "PX",       "PKR" },
    { "Church",           "XRX",      "XRK" },
    { "Collier",          "KL",       "KLR" },
    { "DANGER",           "TNJR",     "TNKR" },
    { "D'Aubigny",        "TPN",      "TPKN" },
    { "DAVIS",            "TFS",      "TFS" },
    { "Eglinton",         "AKLNTN",   "ALNTN" },
    { "Folger",           "FLKR",     "FLJR" },
    { "Fischer",          "FXR",      "FSKR" },
    { "Gaffney",          "KFN",      "KFN" },
    { "Gage",             "KJ",       "KK" },
    { "Gerken",           "KRKN",     "JRKN" },
    { "Giffard",          "JFRT",     "KFRT" },
    { "Gybbes",           "KPS",      "JPS" },
    { "Hathaway",         "H0",       "HT" },
    { "Hungerford",       "HNKRFRT",  "HNJRFRT" },
    { "Huttinger",        "HTNKR",    "HTNJR" },
    { "Jackson",          "JKSN",     "AKSN" },
    { "Jacob",            "JKP",      "AKP" },
    { "Jans",             "JNS",      "ANS" },
    { "Jenkins",          "JNKNS",    "ANKNS" },
    { "Josephine",        "JSFN",     "HSFN" },
    { "Langer",           "LNKR",     "LNJR" },
    { "Leager",           "LKR",      "LJR" },
    { "Lestrange",        "LSTRNJ",   "LSTRNK" },
    { "MANGER",           "MNJR",     "MNKR" },
    { "Mayhew",           "MH",       "MHF" },
    { "Montboucher",      "MNTPXR",   "MNTPKR" },
    { "Munger",           "MNKR",     "MNJR" },
    { "Page",             "PJ",       "PK" },
    { "Ranger",           "RNJR",     "RNKR" },
    { "Rachel",           "RXL",      "RKL" },
    { "Reichert",         "RXRT",     "RKRT" },
    { "Richards",         "RXRTS",    "RKRTS" },
    { "Richardson",       "RXRTSN",   "RKRTSN" },
    { "Rogers",           "RKRS",     "RJRS" },
    { "Sanger",           "SNKR",     "SNJR" },
    { "Sargent",          "SRJNT",    "SRKNT" },
    { "Schlegel",         "XLKL",     "SLKL" },
    { "Segersall",        "SJRSL",    "SKRSL" },
    { "Springer",         "SPRNKR",   "SPRNJR" },
    { "Starkweather",     "STRK0R",   "STRKTR" },
    { "Turgeon",          "TRJN",     "TRKN" },
}

local failureCount = 0
local passCount = 0

print("Running Double Metaphone Tests...")
print("=" .. string.rep("=", 79))

for idx, case in ipairs(TEST_CASES) do
    local input = case[1]
    local expectedPrimary = case[2]
    local expectedSecondary = case[3]
    
    local result = doubleMetaphone(input)
    local actualPrimary = result[1] or ""
    local actualSecondary = result[2] or ""
    
    if actualPrimary ~= expectedPrimary or actualSecondary ~= expectedSecondary then
        failureCount = failureCount + 1
        print(string.format("FAIL [%3d]: %-20s", idx, input))
        print(string.format("  Expected: {%-8s, %-8s}", expectedPrimary, expectedSecondary))
        print(string.format("  Got:      {%-8s, %-8s}", actualPrimary, actualSecondary))
    else
        passCount = passCount + 1
    end
end

print("=" .. string.rep("=", 79))
print(string.format("Results: %d passed, %d failed out of %d tests", passCount, failureCount, passCount + failureCount))

if failureCount > 0 then
    os.exit(1)
else
    print("All tests passed!")
    os.exit(0)
end
