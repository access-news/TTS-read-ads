-module(pub_guide).
-export(
   [ print/0
   , test_guide/0
   ]
).

print() ->
    [ { { category, "Main menu" }
        , MainCategories
      }
    ] = test_guide()
,   do_print(MainCategories, [], 0, "")
.

do_print([], _CounterList, _CurrentCounter, _Pad) ->
    done;

do_print([ Head | Rest ], CounterList, CurrentCounter, Pad) ->
    NewCounter = CurrentCounter + 1
,   PrintPack = [CounterList, NewCounter, Pad]
,   case Head of
        { { category, HasName }, CategoryList } ->
            put_name(HasName, PrintPack)
        ,   do_print(CategoryList, CounterList ++ [NewCounter], 0, Pad ++ "  ");
        { publication, HasName } ->
            put_name(HasName, PrintPack);
        { { sectioned_publication , HasName }, _} ->
            put_name(HasName, PrintPack)
    end
% ,   do_print(Head, NewCounter, Pad)
,   do_print(Rest, CounterList, NewCounter, Pad)
.

put_name(HasName, [ CounterList, CurrentCounter, Pad ]) ->
    ToPrint =
        case HasName of
            { Name, _ } -> Name;
            HasName when is_list(HasName) -> HasName
        end
,   io:fwrite("~s~p ~s~n", [Pad, CounterList ++ [CurrentCounter], ToPrint])
.

test_guide() ->
    [ { {category, "Main menu"}
    % [ { {category, "Main category"}
      , [ { { category % ads {{-
            , { "Store sales advertising"
              , [ {dir_prefix, "ads"} ]
              }
            }
          , [ { { category % grocery stores % {{-
                , { "Grocery stores"
                  , [ {dir_prefix, "grocery"} ]
                  }
                }
              , [ { { category, "Grocery stores with names beginning with 'A' through 'K'" }
                  , [ {publication, {"Aldi",        [{ alt, "aldi"        }]}}
                    , {publication, {"Foods Co",    [{ alt, "foods-co"    }]}}
                    , {publication, {"Food Source", [{ alt, "food-source" }]}}
                    , {publication, {"Kroger",      [{ alt, "kroger"      }]}}
                    ]
                  }
                , { { category, "Grocery stores with names beginning with 'L' through 'R'" }
                  , [ {publication, {"La Superior",               [{ alt, "la-superior"                }]}}
                    , {publication, {"Lidl",                      [{ alt, "lidl"                       }]}}
                    , {publication, {"Lucky Supermarkets",        [{ alt, "lucky"                      }]}}
                    , {publication, {"Raley's",                   [{ alt, "raleys-sue"                 }]}}
                    , {publication, {"Rancho San Miguel Markets", [{ alt, "rancho-san-miguel-markets"  }]}}
                    ]
                  }
                , { { category, "Grocery stores with names beginning with 'S' through 'Z'" }
                  , [ {publication, {"Sacramento Natural Foods Co-op", [{ alt, "sac-coop" }]}} 
                    , { { sectioned_publication, "Safeway" } % {{-
	                    , [ {section, {"Weekly ads", [{alt, "safeway-this-week"}]}}
                        , {section, {"Big Book of Savings",  [{alt, "safeway-big-book"}]}}
                        % , {section, {"Weekly ads from February 3rd to the 9th",  [{alt, "safeway-last-week"}]}}
                        ]
                      } % }}-
                    , {publication, "Savemart"}
                    , {publication, "Sprouts"}
                    , {publication, {"Trader Joe's", [{ alt, "trader-joes" }]}}
                    ]
                  }
                ]
              } % }}-
          % , [ { { category % grocery stores % {{-
          %       , { "Grocery stores"
          %         , [ {dir_prefix, "grocery"} ]
          %         }
          %       }
          %     % , [ { publication, { "Safeway",  [{alt, "safeway-sue"  }]}} % 1
          %     , [ { { sectioned_publication, "Safeway" }
          %           % , { "Safeway"
          %           %   , [ {dir_prefix, "safeway"} ]
          %           %   }
          %           % }
          %         , [ {section, {"Big Book of Savings, valid from February 1st to March 2nd",  [{alt, "safeway-big-book"}]}}
          %           % , {section, {"Weekly ads from February 3rd to the 9th",  [{alt, "safeway-last-week"}]}}
		    % , {section, {"Weekly ads", [{alt, "safeway-this-week"}]}}
          %           ]
          %         }
          %       , { publication, { "Raley's",  [{alt, "raleys-sue"  }]}} % 2
          %       % , { { sectioned_publication
          %       %     , { "Raley's"
          %       %       , [ {dir_prefix, "raleys"} ]
          %       %       }
          %       %     }
          %       %   , [ {section, {"This week's ads",  [{alt, "latest"}]}}
          %       %     , {section, {"Week 8/26/2020 to 9/1/2020",  [{alt, "08262020"}]}}
		    % % , {section, {"Week 8/19/2020 to 8/25/2020", [{alt, "08192020"}]}}
		    % % , {section, {"Week 8/12/2020 to 8/18/2020", [{alt, "08122020"}]}}
		    % % , {section, {"Week 8/4/2020 to 8/11/2020",  [{alt, "08042020"}]}}
		    % % , {section, {"Week 7/28/2020 to 8/3/2020",  [{alt, "07282020"}]}}
		    % % , {section, {"Week 7/22/2020 to 7/27/2020", [{alt, "07222020"}]}}
          %       %     ]
          %       %   }
          %       % , {publication, {"Raley's",            [{ alt, "raleys"      }]}}
          %       , {publication, {"La Superior",        [{ alt, "la-superior"          }]}} % 3
          %       , {publication, {"Food Source",        [{ alt, "food-source"          }]}} % 4
          %       , {publication, "Savemart"}                                                % 5
          %       , {publication, {"Foods Co",           [{ alt, "foods-co"             }]}} % 6
          %       , {publication, {"Trader Joe's",       [{ alt, "trader-joes"          }]}} % 7
          %       , {publication, "Sprouts"}                                                 % 8
          %       , {publication, {"Lucky Supermarkets", [{ alt, "lucky"                }]}} % 9
          %       , {publication, {"Sacramento Natural Foods Co-op", [{ alt, "sac-coop" }]}} % 10
          %       , {publication, {"Aldi",                           [{ alt, "aldi"     }]}} % 11
          %       , {publication, {"Lidl",                           [{ alt, "lidl"     }]}} % 12
          %       , {publication, {"Kroger",                         [{ alt, "kroger"   }]}} % 13
          %       ]
          %     } % }}-
            , { { category % drug stores {{-
                , { "Drug stores"
                  , [ {dir_prefix, "drug"} ]
                  }
                }
              , [ {publication, "CVS"}
                , {publication, {"Rite Aid",   [{ alt, "rite-aid"  }]}}
                , {publication, {"Walgreen's", [{ alt, "walgreens" }]}}
                , {publication, {"Pharmaca",   [{ alt, "pharmaca"  }]}}
                ]
              } % }}-
            , { { category % discount stores {{-
                , { "Discount stores"
                  , [ {dir_prefix, "discount"} ]
                  }
                }
              , [ {publication, "Target"}
                , {publication, "Walmart"}
                , {publication, {"Big Lots",   [{ alt, "big-lots"  }]}}
                , {publication, "Costco"}
                ]
              } % }}-
            ]
          } % }}-
        , { { category % northern california newspapers and magazines {{-
            , { "Northern California newspapers and magazines"
              , [ {dir_prefix, "norcal"} ]
              }
            }
          , [ { { category % sacramento newspapers and mags {{-
                , { "Sacramento newspapers and magazines"
                  , [ {dir_prefix, "sac"} ]
                  }
                }
              , [ { { category % newspapers{{-
                    , { "Sacramento newspapers"
                      , [ {dir_prefix, "newspapers"} ]
                      }
                    }
                  , [ { { sectioned_publication % sacramento bee {{-
                        , { "Sacramento Bee sections"
                          , [ {dir_prefix, "sacbee"} ]
                          }
                        }
                      , [ {section, "Sports"}
                        , {section, "News"}
                        , {section, "Obituaries"}
                        ]
                      } % }}-
                    , {publication, {"Sacramento News & Review",    [{ alt, "SNR"              }]}}
                    % , {publication, {"Sacramento Press",            [{ alt, "sacramento-press" }]}}
                    , {publication, {"Sacramento Business Journal", [{ alt, "business-journal" }]}}
                    , {publication, {"Sacramento Observer",         [{ alt, "observer"         }]}}
                    % , {publication, {"Sacramento City Express",     [{ alt, "city-express"     }]}}
                    , {publication, {"East Sacramento News",        [{ alt, "east-sac-news"    }]}}
                    % , {publication, {"The Land Park News",          [{ alt, "land-park-news"   }]}}
                    % , {publication, {"The Pocket News",             [{ alt, "pocket-news"      }]}}
                    , {publication, {"Cal Matters",                 [{ alt, "cal-matters"      }]}}
                    ]
                  } % }}-
                , { { category  % magazines {{-
                    , { "Sacramento magazines"
                      , [ {dir_prefix, "magazines"} ]
                      }
                    }
                  , [ {publication, "Comstocks"}
                    , {publication, "SacTown"}
                    , {publication, {"Sacramento Magazine", [{alt, "sacramento-magazine"}]}}
                    ]
                  } % }}-
                ]
              } % }}-
            , { { category  % greater sac {{-
                , { "Greater Sacramento area newspapers"
                  , [ {dir_prefix, "greater-sac"} ]
                  }
                }
              , [ {publication, {"Carmichael Times",                   [{ alt, "carmichael-times"                   }]}}
                % , {publication, {"Arden Carmichael News",              [{ alt, "arden-carmichael-news"              }]}}
                , {publication, {"Davis Enterprise",                   [{ alt, "davis-enterprise"                   }]}}
                % , {publication, {"Roseville Press Tribune",            [{ alt, "roseville-press-tribune"            }]}}
                , {publication, {"Woodland Daily Democrat",            [{ alt, "woodland-daily-democrat"            }]}}
                , {publication, {"Elk Grove Citizen",                  [{ alt, "elk-grove-citizen"                  }]}}
                , {publication, {"Auburn Journal",                     [{ alt, "auburn-journal"                     }]}}
                , {publication, {"Grass Valley-Nevada City Union",     [{ alt, "grass-valley-nevada-city-union"     }]}}
                % , {publication, {"El Dorado County Mountain Democrat", [{ alt, "el-dorado-county-mountain-democrat" }]}}
                % , {publication, {"Loomis News",                        [{ alt, "loomis-news"                        }]}}
                ]
              } % }}-
            , { { category  % sf and bay area {{-
                , { "San Francisco and Bay Area newspapers"
                  , [ {dir_prefix, "bay-area"} ]
                  }
                }
              % , [ {publication, {"Vallejo Times Herald",       [{ alt, "vallejo-times-herald"      }]}}
              , [ {publication, {"Santa Rosa Press Democrat",  [{ alt, "santa-rosa-press-democrat" }]}}
                , {publication, {"SF Gate",                    [{ alt, "sf-gate"                   }]}}
                % , {publication, {"San Francisco Bay Guardian", [{ alt, "sf-bay-guardian"           }]}}
                , {publication, {"East Bay Times",             [{ alt, "east-bay-times"            }]}}
                , {publication, {"SF Weekly",                  [{ alt, "sf-weekly"                 }]}}
                , {publication, {"KQED",                       [{ alt, "KQED-bay-area-bites"       }]}}
                ]
              } % }}-
            , { { category % central california {{-
                , { "Central California newspapers"
                  , [ {dir_prefix, "central-cal"} ]
                  }
              }
              % , [ {publication, {"Modesto Bee",     [{ alt, "modesto-bee"     }]}}
              , [ {publication, {"Stockton Record", [{ alt, "stockton-record" }]}}
                ]
              } % }}-
            , { { category % mendocino {{-
                , { "Mendocino county newspapers"
                  , [ {dir_prefix, "mendocino"} ]
                  }
              }
              , [ {publication, {"Fort Bragg Advocate News", [{ alt, "fort-bragg-advocate-news" }]}}
                , {publication, {"The Mendocino Beacon",     [{ alt, "mendocino-beacon"         }]}}
                ]
              } % }}-
            , { { category % humboldt and trinity counties {{-
                , { "Humboldt & Trinity county newspapers"
                  , [ {dir_prefix, "humboldt-trinity"} ]
                  }
              }
              , [ {publication, {"Humboldt Senior Resource Center's Senior News", [{ alt, "senior-news"           }]}}
                , {publication, {"North Coast Journal",                           [{ alt, "north-coast-journal"   }]}}
                % , {publication, {"Eureka Times Standard",                         [{ alt, "eureka-times-standard" }]}}
                , {publication, {"Ferndale Enterprise",                           [{ alt, "ferndale-enterprise"   }]}}
                , {publication, {"Mad River Union",                               [{ alt, "mad-river-union"       }]}}
                ]
              } % }}-
            ]
          } % }}-
        , { { category % popular magazines {{-
            , { "Popular magazines"
              , [ {dir_prefix, "pop"} ]
              }
            }
          , [ { { category, "News, Entertainment, and Finance" } % {{-
              , [ {publication, "Newsweek"}
                , {publication, {"Entertainment Weekly", [{ alt, "EW"                 }]}}
                , {publication, "Fortune"}
                , {publication, {"Capital Public Radio", [{ alt, "CPR"                }]}}
                , {publication, {"Braille Monitor",      [{ alt, "braille-monitor"    }]}}
                ]
              } % }}-
            , { { category, "History, Science, Travel, and Culture" } % {{-
              , [ {publication, {"Mental Floss",         [{ alt, "mental-floss"       }]}}
                , { { sectioned_publication, "Atlas Obscura" } % {{-
                  , [ {publication, {"Latest articles", [{ alt, "atlas-obscura"      }]}}
                    , {publication, {"2016 articles",   [{ alt, "atlas-mental-archive-2016" }]}}
                    , {publication, {"2017 articles",   [{ alt, "atlas-mental-archive-2017" }]}}
                    , {publication, {"2018 articles",   [{ alt, "atlas-mental-archive-2018" }]}}
                    , {publication, {"2019 articles",   [{ alt, "atlas-mental-archive-2019" }]}}
                    , {publication, {"2020 articles",   [{ alt, "atlas-mental-archive-2020" }]}}
                    ]
                  } % }}-
                % , {publication, {"New Scientist",        [{ alt, "new-scientist"      }]}}
                % , {publication, {"Travel & Leisure",     [{ alt, "travel-and-leisure" }]}}
                , {publication, {"Wild West",            [{ alt, "wild-west"          }]}}
                , {publication, {"Civil War Times",      [{ alt, "civil-war-times"    }]}}
                ]
              } % }}-
            ]
          } % }}-
        , { { category % old time radio {{-
            , { "Old Time Radio Theater"
              , [ {dir_prefix, "OTR"} ]
              }
            }
          , [ { {category, "Mystery"} % {{-
              , [
                  {publication, {"Inner Sanctum",                     [{ alt, "inner-sanctum"         }]}}
                , {publication, {"Mercury Radio Theater",             [{ alt, "mercury-radio-theater" }]}}
                , {publication, {"Mystery Traveler",                  [{ alt, "mystery-traveler"      }]}}
                , {publication, {"The Shadow",                        [{ alt, "the-shadow"            }]}}
                , {publication, "Suspense"}
                , {publication, {"The Whistler",                      [{ alt, "the-whistler"          }]}}
                , {publication, {"Light's Out",                       [{ alt, "lights-out"            }]}}
                , { { sectioned_publication % {{- The Lone Ranger
                    , { "CBS Radio Mystery Theater"
                      , [ {dir_prefix, "cbs-radio-mystery-theater"} ]
                      }
                    }
                  , [
                      { section, { "Episodes    1 to   50", [{ alt, "cbs_radio_mystery_theater-0001-0050" }] } } % 1
                    , { section, { "Episodes   51 to  100", [{ alt, "cbs_radio_mystery_theater-0051-0100" }] } } % 2
                    , { section, { "Episodes  101 to  150", [{ alt, "cbs_radio_mystery_theater-0101-0150" }] } } % 3
                    , { section, { "Episodes  151 to  200", [{ alt, "cbs_radio_mystery_theater-0151-0200" }] } } % 4
                    , { section, { "Episodes  201 to  250", [{ alt, "cbs_radio_mystery_theater-0201-0250" }] } } % 5
                    , { section, { "Episodes  251 to  300", [{ alt, "cbs_radio_mystery_theater-0251-0300" }] } } % 6
                    , { section, { "Episodes  301 to  350", [{ alt, "cbs_radio_mystery_theater-0301-0350" }] } } % 7
                    , { section, { "Episodes  351 to  400", [{ alt, "cbs_radio_mystery_theater-0351-0400" }] } } % 8
                    , { section, { "Episodes  401 to  450", [{ alt, "cbs_radio_mystery_theater-0401-0450" }] } } % 9
                    , { section, { "Episodes  451 to  500", [{ alt, "cbs_radio_mystery_theater-0451-0500" }] } } % 10
                    , { section, { "Episodes  501 to  550", [{ alt, "cbs_radio_mystery_theater-0501-0550" }] } } % 11
                    , { section, { "Episodes  551 to  600", [{ alt, "cbs_radio_mystery_theater-0551-0600" }] } } % 12
                    , { section, { "Episodes  601 to  650", [{ alt, "cbs_radio_mystery_theater-0601-0650" }] } } % 13
                    , { section, { "Episodes  651 to  700", [{ alt, "cbs_radio_mystery_theater-0651-0700" }] } } % 14
                    , { section, { "Episodes  701 to  750", [{ alt, "cbs_radio_mystery_theater-0701-0750" }] } } % 15
                    , { section, { "Episodes  751 to  800", [{ alt, "cbs_radio_mystery_theater-0751-0800" }] } } % 16
                    , { section, { "Episodes  801 to  850", [{ alt, "cbs_radio_mystery_theater-0801-0850" }] } } % 17
                    , { section, { "Episodes  851 to  900", [{ alt, "cbs_radio_mystery_theater-0851-0900" }] } } % 18
                    , { section, { "Episodes  901 to  950", [{ alt, "cbs_radio_mystery_theater-0901-0950" }] } } % 19
                    , { section, { "Episodes  951 to 1000", [{ alt, "cbs_radio_mystery_theater-0951-1000" }] } } % 20
                    , { section, { "Episodes 1001 to 1050", [{ alt, "cbs_radio_mystery_theater-1001-1050" }] } } % 21
                    , { section, { "Episodes 1051 to 1100", [{ alt, "cbs_radio_mystery_theater-1051-1100" }] } } % 22
                    , { section, { "Episodes 1101 to 1150", [{ alt, "cbs_radio_mystery_theater-1101-1150" }] } } % 23
                    , { section, { "Episodes 1151 to 1200", [{ alt, "cbs_radio_mystery_theater-1151-1200" }] } } % 24
                    , { section, { "Episodes 1201 to 1250", [{ alt, "cbs_radio_mystery_theater-1201-1250" }] } } % 25
                    , { section, { "Episodes 1251 to 1300", [{ alt, "cbs_radio_mystery_theater-1251-1300" }] } } % 26
                    , { section, { "Episodes 1301 to 1350", [{ alt, "cbs_radio_mystery_theater-1301-1350" }] } } % 27
                    , { section, { "Episodes 1351 to 1399", [{ alt, "cbs_radio_mystery_theater-1351-1399" }] } } % 28
                    ]
                  } % }}-
                , {publication, {"The Sealed Book",                   [{ alt, "the-sealed-book"       }]}}
                ]
              } % }}-
            , { {category, "Crime"} % {{-
              , [
                  {publication, {"Broadway's my Beat",                [{ alt, "broadways-my-beat"     }]}}
                , {publication, {"Black Stone the Magic Detective",   [{ alt, "black-stone"           }]}}
                , {publication, {"Boston Blacky",                     [{ alt, "boston-blacky"         }]}}
                , {publication, {"Crime Does Not Pay",                [{ alt, "crime-does-not-play"   }]}}
                , {publication, "Dragnet"}
                , {publication, {"Gang Busters",                      [{ alt, "gang-busters"          }]}}
                , {publication, {"Richard Diamond Private Detective", [{ alt, "richard-diamond"       }]}}
                , {publication, {"Adventures of Sam Spade",           [{ alt, "sam-spade"             }]}}
                ]
              } % }}-
            , { {category, "Comedy"} % {{-
              , [ {publication, {"Abbot and Costello",                  [{ alt, "abbot-and-costello"            }]}}
                , {publication, {"The Adventures of Ozzie and Harriet", [{ alt, "ozzie-and-harriet"             }]}}
                , {publication, {"The Bickerson's",                     [{ alt, "the-bickersons"                }]}}
                , {publication, {"Father Knows Best",                   [{ alt, "father-knows-best"             }]}}
                , {publication, {"Fibber McGee and Molly",              [{ alt, "fibber-mcgee-and-molly"        }]}}
                , {publication, {"The Fred Allen Show",                 [{ alt, "the-fred-allen-show"           }]}}
                , {publication, {"George Burns and Gracie Allen",       [{ alt, "george-burns-and-gracie-allen" }]}}
                , {publication, {"Life of Riley",                       [{ alt, "life-of-riley"                 }]}}
                , {publication, {"The Red Skelton Show",                [{ alt, "the-red-skelton-show"          }]}}
                ]
              } % }}-
            , { {category, "Westerns"} % {{-
              , [ {publication, {"The Cisco Kid",              [{ alt, "the-cisco-kid" }]}}
                , {publication, {"Gun Smoke",                  [{ alt, "gun-smoke"     }]}}
                , { { sectioned_publication % {{- The Lone Ranger
                    , { "The Lone Ranger"
                      , [ {dir_prefix, "lone-ranger"} ]
                      }
                    }
                  , [ { section, { "Introduction",          [{ alt,  "intro"  }] } }
                    , { section, { "Episodes    1 to  100", [{ alt,  "to-100" }] } }
                    , { section, { "Episodes  101 to  200", [{ alt,  "to-200" }] } }
                    , { section, { "Episodes  201 to  300", [{ alt,  "to-300" }] } }
                    , { section, { "Episodes  301 to  400", [{ alt,  "to-400" }] } }
                    , { section, { "Episodes  401 to  500", [{ alt,  "to-500" }] } }
                    , { section, { "Episodes  501 to  600", [{ alt,  "to-600" }] } }
                    , { section, { "Episodes  601 to  700", [{ alt,  "to-700" }] } }
                    , { section, { "Episodes  701 to  800", [{ alt,  "to-800" }] } }
                    , { section, { "Episodes  801 to  900", [{ alt,  "to-900" }] } }
                    , { section, { "Episodes  901 to 1000", [{ alt, "to-1000" }] } }
                    , { section, { "Episodes 1001 to 1100", [{ alt, "to-1100" }] } }
                    , { section, { "Episodes 1101 to 1200", [{ alt, "to-1200" }] } }
                    , { section, { "Episodes 1201 to 1300", [{ alt, "to-1300" }] } }
                    , { section, { "Episodes 1301 to 1400", [{ alt, "to-1400" }] } }
                    , { section, { "Episodes 1401 to 1500", [{ alt, "to-1500" }] } }
                    , { section, { "Episodes 1501 to 1600", [{ alt, "to-1600" }] } }
                    , { section, { "Episodes 1601 to 1700", [{ alt, "to-1700" }] } }
                    , { section, { "Episodes 1701 to 1800", [{ alt, "to-1800" }] } }
                    , { section, { "Episodes 1801 to 1900", [{ alt, "to-1900" }] } }
                    , { section, { "Episodes 1901 to 2000", [{ alt, "to-2000" }] } }
                    , { section, { "Episodes 2000 to 2100", [{ alt, "to-2100" }] } }
                    , { section, { "Episodes 2101 to 2200", [{ alt, "to-2200" }] } }
                    , { section, { "Episodes 2201 to 2300", [{ alt, "to-2300" }] } }
                    , { section, { "Episodes 2301 to 2400", [{ alt, "to-2400" }] } }
                    ]
                  } % }}-
                , {publication, {"Tales of the Texas Rangers", [{ alt, "texas-rangers" }]}}
                ]
              } % }}-
            , { {category, "Science fiction and fantasy"} % {{-
              , [ {publication, {"The Blue Beetle",  [{ alt, "blue-beetle"  }]}}
                , {publication, "Escape"}
                , {publication, {"The Green Hornet", [{ alt, "green-hornet" }]}}
                , {publication, {"X Minus 1",        [{ alt, "x-minus-1"    }]}}
                ]
              } % }}-
            , {publication, "Commercials"}
            ]
          } % }}-
        , { { category % games{{-
            , { "Games"
              , [ {dir_prefix, "games"} ]
              }
            }
          , [ {publication, "Crosswords"}
            , {publication, "Trivia"}
            ]
          } % }}-
        , { { category % community {{-
            , { "Community information and resources"
              , [ {dir_prefix, "community-resources"} ]
              }
            }
          % , [ { { category, "Voter information guides" } % {{-
          %     , [ {publication, {"California voter guide",        [{ alt, "cal-voter-guide" }]}}
          %       , {publication, {"Sacramento County voter guide", [{ alt, "sac-county-voter-guide" }]}}
          %       , { { sectioned_publication
          %           , { "Propositions"
          %             , [ {dir_prefix, "propositions"} ]
          %             }
          %           }
          %         , [ {section, { "Proposition 14", [{alt, "props-14"}]}}
		    % , {section, { "Proposition 15", [{alt, "props-15"}]}}
		    % , {section, { "Proposition 16", [{alt, "props-16"}]}}
		    % , {section, { "Proposition 17", [{alt, "props-17"}]}}
		    % , {section, { "Proposition 18", [{alt, "props-18"}]}}
		    % , {section, { "Proposition 19", [{alt, "props-19"}]}}
		    % , {section, { "Proposition 20", [{alt, "props-20"}]}}
		    % , {section, { "Proposition 21", [{alt, "props-21"}]}}
		    % , {section, { "Proposition 22", [{alt, "props-22"}]}}
		    % , {section, { "Proposition 23", [{alt, "props-23"}]}}
		    % , {section, { "Proposition 24", [{alt, "props-24"}]}}
		    % , {section, { "Proposition 25", [{alt, "props-25"}]}}
          %           ]
          %         }
          %       ]
          %     } % }}-
          , [ { { category, "Podcasts"} % {{-
              , [ { publication
                  , { "Beyond Barriers Project"
                    , [ {dir_prefix, "SFTB"}
                      , {link, "beyond-barriers"}
                      ]
                    }
                  }
                , { publication
                  , { "Beyond Barriers Project's music theory with Jim"
                    , [ {dir_prefix, "SFTB"}
                      , {link, "bbu-music-theory-with-jim" }
                      ]
                    }
                  }
                , {publication, {"Live Audiozine", [{alt, "live-audiozine"}]}}
                % , {publication, {"The Redacted Files Podcast", [{alt, "TRP"}]}}
                ]
              } % }}-
            % , { { category, "Poetry" } % {{-
            %   , [ {publication, {"Brad Buchanan",       [{ alt, "brad-buchanan"      }]}}
            %     , {publication, {"Writer's on the air", [{ alt, "writers-on-the-air" }]}}
            %     ]
            %   } % }}-
            ]
          } % }}-
        , { { category % blindness resources {{-
            , { "Blindness information and resources"
              , [ {dir_prefix, "blindness-resources"} ]
              }
            }
          , [ { { category % organizations {{-
                , { "Organizations"
                  , [ {dir_prefix, "orgs"} ]
                  }
                }
              , [ { { category % SFTB {{-
                    , { "Society for the Blind"
                      , [ {dir_prefix, "SFTB"} ]
                      }
                    }
                  , [ {publication, {"SFB Connection",                                  [{ alt, "sfb-connection"   }]}}
                    , {publication, {"Monthly newsletter",                              [{ alt, "newsletter"       }]}}
                    , {publication, {"Society for the Blind's student handbook",        [{ alt, "student-handbook" }]}}
                    , {publication, {"Beyond Barriers Project",                         [{ alt, "beyond-barriers"  }]}}
                    , {publication, {"Beyond Barriers Project's music theory with Jim", [{ alt, "bbu-music-theory-with-jim"  }]}}
                    ]
                  } % }}-
                , {publication, {"The Earle Baum Center",           [{ alt, "EBC"   }]}}
                , {publication, {"Sierra Services for the Blind",   [{ alt, "SSFTB" }]}}
                , {publication, {"California Council of the Blind", [{ alt, "CCB"   }]}}
                , {publication, {"The Council of Citizens with Low Vision international", [{ alt, "CCLVI"   }]}}
                ]
              } % }}-
            , { { category % publications {{-
                , { "Publications"
                  , [ {dir_prefix, "publications" } ]
                  }
                }
              , [ {publication, {"Braille Monitor",           [{ link, "braille-monitor" }]}}
                , {publication, {"Client Assistence Program", [{ link, "CAP"              }]}}
                ]
              } % }}-
            ]
          } % }}-
        , { { category  % education and resources {{-
            , { "Education and resources"
              , [ {dir_prefix, "edu"} ]
              }
            }
          , [ {publication, {"Society for the Blind's student handbook", [{ link, "student-handbook"       }]}}
            % , {publication, {"Balance exercises",                        [{ alt, "balance-exercises"       }]}}
            % , {publication, {"Achieve a healthy weight by UC Davis",     [{ alt, "uc-davis-healthy-weight" }]}}
            % , {publication, {"Yuba-Sutter Meals On Wheels",              [{ alt, "YSMOW"                   }]}}
            % , {publication, {"Client Assistence Program",                [{ alt, "CAP"                     }]}}
            ]
          } % }}-
        % , { { category  % access news {{-
        %     , { "Access News"
        %       , [ {dir_prefix, "access-news"} ]
        %       }
        %     }
        %   , [ {publication, {"Updates and announcements", [{ alt, "updates" }]}}
        %     , {publication, {"Our volunteer readers",     [{ alt, "readers" }]}}
        %     , {publication, {"History of Access News",    [{ alt, "history" }]}}
        %     ]
        %   } % }}-
        ]
      } % main category
    ].
% }}-
