//
//  SampleData.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 18-05-21.
//

import Foundation

var sampleData: Data =
#"""
    {
    "data": [
    {
        "id": "1394683703016804358",
        "entities": {
            "annotations": [
                {
                    "start": 2,
                    "end": 15,
                    "probability": 0.4948,
                    "type": "Organization",
                    "normalized_text": "North Carolina"
                },
                {
                    "start": 56,
                    "end": 71,
                    "probability": 0.9491,
                    "type": "Person",
                    "normalized_text": "Andrew Brown Jr."
                }
            ],
            "urls": [
                {
                    "start": 149,
                    "end": 172,
                    "url": "https://t.co/Z9WTKy4Bc5",
                    "expanded_url": "https://cnn.it/3fqcNIM",
                    "display_url": "cnn.it/3fqcNIM"
                }
            ]
        },
        "text": "A North Carolina district attorney says the shooting of Andrew Brown Jr., a 42-year-old Black man fatally shot by deputies last April, was justified https://t.co/Z9WTKy4Bc5",
        "context_annotations": [
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 39,
            "reply_count": 75,
            "like_count": 124,
            "quote_count": 20
        },
        "created_at": "2021-05-18T15:58:01.000Z"
    },
    {
        "id": "1394671346383216640",
        "entities": {
            "annotations": [
                {
                    "start": 56,
                    "end": 57,
                    "probability": 0.6343,
                    "type": "Place",
                    "normalized_text": "US"
                }
            ],
            "urls": [
                {
                    "start": 137,
                    "end": 160,
                    "url": "https://t.co/cJRsoI6E6W",
                    "expanded_url": "https://cnn.it/3u6KC7f",
                    "display_url": "cnn.it/3u6KC7f"
                }
            ]
        },
        "text": "Colorectal cancer screening should now start at age 45, US health task force says. Previously, it recommended screening start at age 50.\nhttps://t.co/cJRsoI6E6W",
        "context_annotations": [
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 164,
            "reply_count": 57,
            "like_count": 429,
            "quote_count": 30
        },
        "created_at": "2021-05-18T15:08:55.000Z"
    },
    {
        "id": "1394668444084326400",
        "entities": {
            "annotations": [
                {
                    "start": 67,
                    "end": 75,
                    "probability": 0.9519,
                    "type": "Place",
                    "normalized_text": "Louisiana"
                },
                {
                    "start": 81,
                    "end": 98,
                    "probability": 0.8981,
                    "type": "Place",
                    "normalized_text": "southeastern Texas"
                }
            ],
            "urls": [
                {
                    "start": 174,
                    "end": 197,
                    "url": "https://t.co/uf6cJwRwPU",
                    "expanded_url": "https://cnn.it/3wfmkcC",
                    "display_url": "cnn.it/3wfmkcC",
                    "images": [
                        {
                            "url": "https://pbs.twimg.com/news_img/1394664093924040704/CV_fENym?format=jpg&name=orig",
                            "width": 1100,
                            "height": 619
                        },
                        {
                            "url": "https://pbs.twimg.com/news_img/1394664093924040704/CV_fENym?format=jpg&name=150x150",
                            "width": 150,
                            "height": 150
                        }
                    ],
                    "status": 200,
                    "title": "Flooding leads to rescues in Louisiana and Texas, with more rain on the way",
                    "description": "Water rescues were underway in Louisiana's capital region Tuesday morning, after torrential rain starting a day earlier caused dangerous flash flooding in parts of that state and southeastern Texas.",
                    "unwound_url": "https://www.cnn.com/2021/05/18/weather/flooding-baton-rouge-louisiana-texas/index.html?utm_term=link&utm_source=twcnnbrk&utm_medium=social&utm_content=2021-05-18T14%3A57%3A22"
                }
            ]
        },
        "text": "Water rescues are underway a day after torrential rain in parts of Louisiana and southeastern Texas led to dangerous flash flooding. More rain is expected through Thursday. \nhttps://t.co/uf6cJwRwPU",
        "context_annotations": [
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 97,
            "reply_count": 28,
            "like_count": 209,
            "quote_count": 16
        },
        "created_at": "2021-05-18T14:57:23.000Z"
    },
    {
        "id": "1394651843733696513",
        "entities": {
            "annotations": [
                {
                    "start": 22,
                    "end": 35,
                    "probability": 0.986,
                    "type": "Person",
                    "normalized_text": "Kevin McCarthy"
                },
                {
                    "start": 73,
                    "end": 79,
                    "probability": 0.594,
                    "type": "Place",
                    "normalized_text": "Capitol"
                },
                {
                    "start": 107,
                    "end": 117,
                    "probability": 0.9058,
                    "type": "Organization",
                    "normalized_text": "Republicans"
                }
            ],
            "urls": [
                {
                    "start": 150,
                    "end": 173,
                    "url": "https://t.co/Xzj9UskrK1",
                    "expanded_url": "https://cnn.it/2S0Zre0",
                    "display_url": "cnn.it/2S0Zre0"
                }
            ]
        },
        "text": "House Minority Leader Kevin McCarthy says he opposes an inquiry into the Capitol insurrection, siding with Republicans downplaying the January 6 riot https://t.co/Xzj9UskrK1",
        "context_annotations": [
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "963858007305023493",
                    "name": "Kevin McCarthy",
                    "description": "US Representative Kevin McCarthy (CA-23)"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "963858007305023493",
                    "name": "Kevin McCarthy",
                    "description": "US Representative Kevin McCarthy (CA-23)"
                }
            },
            {
                "domain": {
                    "id": "88",
                    "name": "Political Body",
                    "description": "A section of a government, like The Supreme Court"
                },
                "entity": {
                    "id": "961705302700654593",
                    "name": "United States Congress",
                    "description": "United States Congress"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            },
            {
                "domain": {
                    "id": "88",
                    "name": "Political Body",
                    "description": "A section of a government, like The Supreme Court"
                },
                "entity": {
                    "id": "897916387829481472",
                    "name": "United States House of Representatives",
                    "description": "United States House of Representatives"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 210,
            "reply_count": 622,
            "like_count": 687,
            "quote_count": 193
        },
        "created_at": "2021-05-18T13:51:25.000Z"
    },
    {
        "id": "1394462482836688900",
        "entities": {
            "annotations": [
                {
                    "start": 0,
                    "end": 13,
                    "probability": 0.956,
                    "type": "Place",
                    "normalized_text": "South Carolina"
                }
            ],
            "urls": [
                {
                    "start": 141,
                    "end": 164,
                    "url": "https://t.co/3MaJCUjA0A",
                    "expanded_url": "https://www.cnn.com/2021/05/17/politics/south-carolina-death-row-firing-squad-electrocution/index.html",
                    "display_url": "cnn.com/2021/05/17/pol…"
                }
            ]
        },
        "text": "South Carolina will allow death row inmates to elect execution by electric chair or firing squad if lethal injection drugs are not available https://t.co/3MaJCUjA0A",
        "context_annotations": [
            {
                "domain": {
                    "id": "123",
                    "name": "Ongoing News Story",
                    "description": "Ongoing News Stories like 'Brexit'"
                },
                "entity": {
                    "id": "1220701888179359745",
                    "name": "COVID-19"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 248,
            "reply_count": 642,
            "like_count": 991,
            "quote_count": 285
        },
        "created_at": "2021-05-18T01:18:58.000Z"
    },
    {
        "id": "1394461621066608640",
        "entities": {
            "annotations": [
                {
                    "start": 4,
                    "end": 14,
                    "probability": 0.8084,
                    "type": "Place",
                    "normalized_text": "White House"
                },
                {
                    "start": 91,
                    "end": 105,
                    "probability": 0.9014,
                    "type": "Person",
                    "normalized_text": "President Biden"
                }
            ],
            "urls": [
                {
                    "start": 178,
                    "end": 201,
                    "url": "https://t.co/YhI74xyXYI",
                    "expanded_url": "https://www.cnn.com/2021/05/17/politics/biden-pardons-clemency-racial-justice/index.html",
                    "display_url": "cnn.com/2021/05/17/pol…"
                }
            ]
        },
        "text": "The White House is in the process of reviewing clemency applications and has signaled that President Biden will issue acts of clemency before the middle of his presidential term https://t.co/YhI74xyXYI",
        "context_annotations": [
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            },
            {
                "domain": {
                    "id": "88",
                    "name": "Political Body",
                    "description": "A section of a government, like The Supreme Court"
                },
                "entity": {
                    "id": "871795678447456256",
                    "name": "The White House",
                    "description": "Conversation from and about the White House, both as a destination and as political voice"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 103,
            "reply_count": 144,
            "like_count": 571,
            "quote_count": 15
        },
        "created_at": "2021-05-18T01:15:32.000Z"
    },
    {
        "id": "1394424307388985345",
        "entities": {
            "annotations": [
                {
                    "start": 0,
                    "end": 14,
                    "probability": 0.838,
                    "type": "Person",
                    "normalized_text": "President Biden"
                },
                {
                    "start": 83,
                    "end": 88,
                    "probability": 0.9653,
                    "type": "Place",
                    "normalized_text": "Israel"
                },
                {
                    "start": 94,
                    "end": 98,
                    "probability": 0.6545,
                    "type": "Place",
                    "normalized_text": "Hamas"
                },
                {
                    "start": 113,
                    "end": 116,
                    "probability": 0.9933,
                    "type": "Place",
                    "normalized_text": "Gaza"
                }
            ],
            "urls": [
                {
                    "start": 139,
                    "end": 162,
                    "url": "https://t.co/CublYuPds3",
                    "expanded_url": "https://www.cnn.com/2021/05/17/politics/biden-israel-hamas-gaza/index.html",
                    "display_url": "cnn.com/2021/05/17/pol…"
                }
            ]
        },
        "text": "President Biden expresses support for a ceasefire as intensifying violence between Israel and Hamas militants in Gaza enters a second week https://t.co/CublYuPds3",
        "context_annotations": [
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 123,
            "reply_count": 354,
            "like_count": 656,
            "quote_count": 45
        },
        "created_at": "2021-05-17T22:47:16.000Z"
    },
    {
        "id": "1394419212895064067",
        "entities": {
            "annotations": [
                {
                    "start": 4,
                    "end": 14,
                    "probability": 0.7756,
                    "type": "Place",
                    "normalized_text": "White House"
                },
                {
                    "start": 55,
                    "end": 69,
                    "probability": 0.869,
                    "type": "Person",
                    "normalized_text": "President Biden"
                },
                {
                    "start": 75,
                    "end": 95,
                    "probability": 0.9363,
                    "type": "Person",
                    "normalized_text": "Vice President Harris"
                },
                {
                    "start": 155,
                    "end": 169,
                    "probability": 0.9258,
                    "type": "Person",
                    "normalized_text": "President Trump"
                }
            ],
            "urls": [
                {
                    "start": 171,
                    "end": 194,
                    "url": "https://t.co/5r6SVi6tU0",
                    "expanded_url": "https://www.cnn.com/2021/05/17/politics/biden-tax-returns/index.html?c",
                    "display_url": "cnn.com/2021/05/17/pol…"
                }
            ]
        },
        "text": "The White House released the 2020 tax returns for both President Biden and Vice President Harris, restoring a tradition that had been ignored under former President Trump https://t.co/5r6SVi6tU0",
        "context_annotations": [
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "799022225751871488",
                    "name": "Donald Trump",
                    "description": "US President Donald Trump"
                }
            },
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "1339951976994390016",
                    "name": "Donald Trump (Serra training)"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "799022225751871488",
                    "name": "Donald Trump",
                    "description": "US President Donald Trump"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "1339951976994390016",
                    "name": "Donald Trump (Serra training)"
                }
            },
            {
                "domain": {
                    "id": "10",
                    "name": "Person",
                    "description": "Named people in the world like Nelson Mandela"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "35",
                    "name": "Politician",
                    "description": "Politicians in the world, like Joe Biden"
                },
                "entity": {
                    "id": "10040395078",
                    "name": "Joe Biden",
                    "description": "Former US Vice President Joe Biden"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            },
            {
                "domain": {
                    "id": "65",
                    "name": "Interests and Hobbies Vertical",
                    "description": "Top level interests and hobbies groupings, like Food or Travel"
                },
                "entity": {
                    "id": "847529762566230016",
                    "name": "Business and finance",
                    "description": "Business"
                }
            },
            {
                "domain": {
                    "id": "66",
                    "name": "Interests and Hobbies Category",
                    "description": "A grouping of interests and hobbies entities, like Novelty Food or Destinations"
                },
                "entity": {
                    "id": "847888632711061504",
                    "name": "Personal finance",
                    "description": "Personal finance"
                }
            },
            {
                "domain": {
                    "id": "67",
                    "name": "Interests and Hobbies",
                    "description": "Interests, opinions, and behaviors of individuals, groups, or cultures; like Speciality Cooking or Theme Parks"
                },
                "entity": {
                    "id": "847894937601323008",
                    "name": "Tax planning",
                    "description": "Tax planning"
                }
            },
            {
                "domain": {
                    "id": "88",
                    "name": "Political Body",
                    "description": "A section of a government, like The Supreme Court"
                },
                "entity": {
                    "id": "871795678447456256",
                    "name": "The White House",
                    "description": "Conversation from and about the White House, both as a destination and as political voice"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 535,
            "reply_count": 349,
            "like_count": 4100,
            "quote_count": 61
        },
        "created_at": "2021-05-17T22:27:02.000Z"
    },
    {
        "id": "1394415099369201664",
        "entities": {
            "annotations": [
                {
                    "start": 4,
                    "end": 7,
                    "probability": 0.3821,
                    "type": "Organization",
                    "normalized_text": "NYRA"
                },
                {
                    "start": 43,
                    "end": 53,
                    "probability": 0.965,
                    "type": "Person",
                    "normalized_text": "Bob Baffert"
                },
                {
                    "start": 122,
                    "end": 135,
                    "probability": 0.7134,
                    "type": "Organization",
                    "normalized_text": "Belmont Stakes"
                }
            ],
            "urls": [
                {
                    "start": 162,
                    "end": 185,
                    "url": "https://t.co/twvRDHy4oo",
                    "expanded_url": "https://cnn.it/2S1L5dk",
                    "display_url": "cnn.it/2S1L5dk"
                }
            ]
        },
        "text": "The NYRA has temporarily suspended trainer Bob Baffert from entering any horses in races at the track that is host to the Belmont Stakes in less than three weeks https://t.co/twvRDHy4oo",
        "context_annotations": [
            {
                "domain": {
                    "id": "6",
                    "name": "Sports Event"
                },
                "entity": {
                    "id": "1389596088244396038",
                    "name": "Belmont Stakes 2021"
                }
            },
            {
                "domain": {
                    "id": "11",
                    "name": "Sport",
                    "description": "Types of sports, like soccer and basketball"
                },
                "entity": {
                    "id": "847901716024446977",
                    "name": "Horse racing & equestrian",
                    "description": "Horse racing"
                }
            },
            {
                "domain": {
                    "id": "11",
                    "name": "Sport",
                    "description": "Types of sports, like soccer and basketball"
                },
                "entity": {
                    "id": "847901716024446977",
                    "name": "Horse racing & equestrian",
                    "description": "Horse racing"
                }
            },
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 97,
            "reply_count": 90,
            "like_count": 462,
            "quote_count": 27
        },
        "created_at": "2021-05-17T22:10:41.000Z"
    },
    {
        "id": "1394393503627579394",
        "text": "RT @CNNBusiness: The president of the country's largest nurses' union has spoken out against updated federal guidance which says that — wit…",
        "context_annotations": [
            {
                "domain": {
                    "id": "47",
                    "name": "Brand",
                    "description": "Brands and Companies"
                },
                "entity": {
                    "id": "10040667043",
                    "name": "CNN"
                }
            }
        ],
        "public_metrics": {
            "retweet_count": 88,
            "reply_count": 0,
            "like_count": 0,
            "quote_count": 0
        },
        "entities": {
            "mentions": [
                {
                    "start": 3,
                    "end": 15,
                    "username": "CNNBusiness"
                }
            ]
        },
        "created_at": "2021-05-17T20:44:52.000Z"
    }
],
"meta": {
    "oldest_id": "1394393503627579394",
    "newest_id": "1394683703016804358",
    "result_count": 10,
    "next_token": "7140dibdnow9c7btw3w4seexzg8x94gay0hs3a07f9k50"
}
}
"""#.data(using: .unicode)!
