// from https://developers.google.com/public-data/docs/canonical/countries_csv

const countryData = [
    {
      "country_code": "AD",
      "country": "Andorra",
      "latitude": "42.546245",
      "longitude": "1.601554"
    },
    {
      "country_code": "AE",
      "country": "United Arab Emirates",
      "latitude": "23.424076",
      "longitude": "53.847818"
    },
    {
      "country_code": "AF",
      "country": "Afghanistan",
      "latitude": "33.93911",
      "longitude": "67.709953"
    },
    {
      "country_code": "AG",
      "country": "Antigua and Barbuda",
      "latitude": "17.060816",
      "longitude": "-61.796428"
    },
    {
      "country_code": "AI",
      "country": "Anguilla",
      "latitude": "18.220554",
      "longitude": "-63.068615"
    },
    {
      "country_code": "AL",
      "country": "Albania",
      "latitude": "41.153332",
      "longitude": "20.168331"
    },
    {
      "country_code": "AM",
      "country": "Armenia",
      "latitude": "40.069099",
      "longitude": "45.038189"
    },
    {
      "country_code": "AN",
      "country": "Netherlands Antilles",
      "latitude": "12.226079",
      "longitude": "-69.060087"
    },
    {
      "country_code": "AO",
      "country": "Angola",
      "latitude": "-11.202692",
      "longitude": "17.873887"
    },
    {
      "country_code": "AQ",
      "country": "Antarctica",
      "latitude": "-75.250973",
      "longitude": "-0.071389"
    },
    {
      "country_code": "AR",
      "country": "Argentina",
      "latitude": "-38.416097",
      "longitude": "-63.616672"
    },
    {
      "country_code": "AS",
      "country": "American Samoa",
      "latitude": "-14.270972",
      "longitude": "-170.132217"
    },
    {
      "country_code": "AT",
      "country": "Austria",
      "latitude": "47.516231",
      "longitude": "14.550072"
    },
    {
      "country_code": "AU",
      "country": "Australia",
      "latitude": "-25.274398",
      "longitude": "133.775136"
    },
    {
      "country_code": "AW",
      "country": "Aruba",
      "latitude": "12.52111",
      "longitude": "-69.968338"
    },
    {
      "country_code": "AZ",
      "country": "Azerbaijan",
      "latitude": "40.143105",
      "longitude": "47.576927"
    },
    {
      "country_code": "BA",
      "country": "Bosnia and Herzegovina",
      "latitude": "43.915886",
      "longitude": "17.679076"
    },
    {
      "country_code": "BB",
      "country": "Barbados",
      "latitude": "13.193887",
      "longitude": "-59.543198"
    },
    {
      "country_code": "BD",
      "country": "Bangladesh",
      "latitude": "23.684994",
      "longitude": "90.356331"
    },
    {
      "country_code": "BE",
      "country": "Belgium",
      "latitude": "50.503887",
      "longitude": "4.469936"
    },
    {
      "country_code": "BF",
      "country": "Burkina Faso",
      "latitude": "12.238333",
      "longitude": "-1.561593"
    },
    {
      "country_code": "BG",
      "country": "Bulgaria",
      "latitude": "42.733883",
      "longitude": "25.48583"
    },
    {
      "country_code": "BH",
      "country": "Bahrain",
      "latitude": "25.930414",
      "longitude": "50.637772"
    },
    {
      "country_code": "BI",
      "country": "Burundi",
      "latitude": "-3.373056",
      "longitude": "29.918886"
    },
    {
      "country_code": "BJ",
      "country": "Benin",
      "latitude": "9.30769",
      "longitude": "2.315834"
    },
    {
      "country_code": "BM",
      "country": "Bermuda",
      "latitude": "32.321384",
      "longitude": "-64.75737"
    },
    {
      "country_code": "BN",
      "country": "Brunei",
      "latitude": "4.535277",
      "longitude": "114.727669"
    },
    {
      "country_code": "BO",
      "country": "Bolivia",
      "latitude": "-16.290154",
      "longitude": "-63.588653"
    },
    {
      "country_code": "BR",
      "country": "Brazil",
      "latitude": "-14.235004",
      "longitude": "-51.92528"
    },
    {
      "country_code": "BS",
      "country": "Bahamas",
      "latitude": "25.03428",
      "longitude": "-77.39628"
    },
    {
      "country_code": "BT",
      "country": "Bhutan",
      "latitude": "27.514162",
      "longitude": "90.433601"
    },
    {
      "country_code": "BV",
      "country": "Bouvet Island",
      "latitude": "-54.423199",
      "longitude": "3.413194"
    },
    {
      "country_code": "BW",
      "country": "Botswana",
      "latitude": "-22.328474",
      "longitude": "24.684866"
    },
    {
      "country_code": "BY",
      "country": "Belarus",
      "latitude": "53.709807",
      "longitude": "27.953389"
    },
    {
      "country_code": "BZ",
      "country": "Belize",
      "latitude": "17.189877",
      "longitude": "-88.49765"
    },
    {
      "country_code": "CA",
      "country": "Canada",
      "latitude": "56.130366",
      "longitude": "-106.346771"
    },
    {
      "country_code": "CC",
      "country": "Cocos [Keeling] Islands",
      "latitude": "-12.164165",
      "longitude": "96.870956"
    },
    {
      "country_code": "CD",
      "country": "Congo [DRC]",
      "latitude": "-4.038333",
      "longitude": "21.758664"
    },
    {
      "country_code": "CF",
      "country": "Central African Republic",
      "latitude": "6.611111",
      "longitude": "20.939444"
    },
    {
      "country_code": "CG",
      "country": "Congo [Republic]",
      "latitude": "-0.228021",
      "longitude": "15.827659"
    },
    {
      "country_code": "CH",
      "country": "Switzerland",
      "latitude": "46.818188",
      "longitude": "8.227512"
    },
    {
      "country_code": "CI",
      "country": "Côte d'Ivoire",
      "latitude": "7.539989",
      "longitude": "-5.54708"
    },
    {
      "country_code": "CK",
      "country": "Cook Islands",
      "latitude": "-21.236736",
      "longitude": "-159.777671"
    },
    {
      "country_code": "CL",
      "country": "Chile",
      "latitude": "-35.675147",
      "longitude": "-71.542969"
    },
    {
      "country_code": "CM",
      "country": "Cameroon",
      "latitude": "7.369722",
      "longitude": "12.354722"
    },
    {
      "country_code": "CN",
      "country": "China",
      "latitude": "35.86166",
      "longitude": "104.195397"
    },
    {
      "country_code": "CO",
      "country": "Colombia",
      "latitude": "4.570868",
      "longitude": "-74.297333"
    },
    {
      "country_code": "CR",
      "country": "Costa Rica",
      "latitude": "9.748917",
      "longitude": "-83.753428"
    },
    {
      "country_code": "CU",
      "country": "Cuba",
      "latitude": "21.521757",
      "longitude": "-77.781167"
    },
    {
      "country_code": "CV",
      "country": "Cape Verde",
      "latitude": "16.002082",
      "longitude": "-24.013197"
    },
    {
      "country_code": "CX",
      "country": "Christmas Island",
      "latitude": "-10.447525",
      "longitude": "105.690449"
    },
    {
      "country_code": "CY",
      "country": "Cyprus",
      "latitude": "35.126413",
      "longitude": "33.429859"
    },
    {
      "country_code": "CZ",
      "country": "Czech Republic",
      "latitude": "49.817492",
      "longitude": "15.472962"
    },
    {
      "country_code": "DE",
      "country": "Germany",
      "latitude": "51.165691",
      "longitude": "10.451526"
    },
    {
      "country_code": "DJ",
      "country": "Djibouti",
      "latitude": "11.825138",
      "longitude": "42.590275"
    },
    {
      "country_code": "DK",
      "country": "Denmark",
      "latitude": "56.26392",
      "longitude": "9.501785"
    },
    {
      "country_code": "DM",
      "country": "Dominica",
      "latitude": "15.414999",
      "longitude": "-61.370976"
    },
    {
      "country_code": "DO",
      "country": "Dominican Republic",
      "latitude": "18.735693",
      "longitude": "-70.162651"
    },
    {
      "country_code": "DZ",
      "country": "Algeria",
      "latitude": "28.033886",
      "longitude": "1.659626"
    },
    {
      "country_code": "EC",
      "country": "Ecuador",
      "latitude": "-1.831239",
      "longitude": "-78.183406"
    },
    {
      "country_code": "EE",
      "country": "Estonia",
      "latitude": "58.595272",
      "longitude": "25.013607"
    },
    {
      "country_code": "EG",
      "country": "Egypt",
      "latitude": "26.820553",
      "longitude": "30.802498"
    },
    {
      "country_code": "EH",
      "country": "Western Sahara",
      "latitude": "24.215527",
      "longitude": "-12.885834"
    },
    {
      "country_code": "ER",
      "country": "Eritrea",
      "latitude": "15.179384",
      "longitude": "39.782334"
    },
    {
      "country_code": "ES",
      "country": "Spain",
      "latitude": "40.463667",
      "longitude": "-3.74922"
    },
    {
      "country_code": "ET",
      "country": "Ethiopia",
      "latitude": "9.145",
      "longitude": "40.489673"
    },
    {
      "country_code": "FI",
      "country": "Finland",
      "latitude": "61.92411",
      "longitude": "25.748151"
    },
    {
      "country_code": "FJ",
      "country": "Fiji",
      "latitude": "-16.578193",
      "longitude": "179.414413"
    },
    {
      "country_code": "FK",
      "country": "Falkland Islands [Islas Malvinas]",
      "latitude": "-51.796253",
      "longitude": "-59.523613"
    },
    {
      "country_code": "FM",
      "country": "Micronesia",
      "latitude": "7.425554",
      "longitude": "150.550812"
    },
    {
      "country_code": "FO",
      "country": "Faroe Islands",
      "latitude": "61.892635",
      "longitude": "-6.911806"
    },
    {
      "country_code": "FR",
      "country": "France",
      "latitude": "46.227638",
      "longitude": "2.213749"
    },
    {
      "country_code": "GA",
      "country": "Gabon",
      "latitude": "-0.803689",
      "longitude": "11.609444"
    },
    {
      "country_code": "GB",
      "country": "United Kingdom",
      "latitude": "55.378051",
      "longitude": "-3.435973"
    },
    {
      "country_code": "GD",
      "country": "Grenada",
      "latitude": "12.262776",
      "longitude": "-61.604171"
    },
    {
      "country_code": "GE",
      "country": "Georgia",
      "latitude": "42.315407",
      "longitude": "43.356892"
    },
    {
      "country_code": "GF",
      "country": "French Guiana",
      "latitude": "3.933889",
      "longitude": "-53.125782"
    },
    {
      "country_code": "GG",
      "country": "Guernsey",
      "latitude": "49.465691",
      "longitude": "-2.585278"
    },
    {
      "country_code": "GH",
      "country": "Ghana",
      "latitude": "7.946527",
      "longitude": "-1.023194"
    },
    {
      "country_code": "GI",
      "country": "Gibraltar",
      "latitude": "36.137741",
      "longitude": "-5.345374"
    },
    {
      "country_code": "GL",
      "country": "Greenland",
      "latitude": "71.706936",
      "longitude": "-42.604303"
    },
    {
      "country_code": "GM",
      "country": "Gambia",
      "latitude": "13.443182",
      "longitude": "-15.310139"
    },
    {
      "country_code": "GN",
      "country": "Guinea",
      "latitude": "9.945587",
      "longitude": "-9.696645"
    },
    {
      "country_code": "GP",
      "country": "Guadeloupe",
      "latitude": "16.995971",
      "longitude": "-62.067641"
    },
    {
      "country_code": "GQ",
      "country": "Equatorial Guinea",
      "latitude": "1.650801",
      "longitude": "10.267895"
    },
    {
      "country_code": "GR",
      "country": "Greece",
      "latitude": "39.074208",
      "longitude": "21.824312"
    },
    {
      "country_code": "GS",
      "country": "South Georgia and the South Sandwich Islands",
      "latitude": "-54.429579",
      "longitude": "-36.587909"
    },
    {
      "country_code": "GT",
      "country": "Guatemala",
      "latitude": "15.783471",
      "longitude": "-90.230759"
    },
    {
      "country_code": "GU",
      "country": "Guam",
      "latitude": "13.444304",
      "longitude": "144.793731"
    },
    {
      "country_code": "GW",
      "country": "Guinea-Bissau",
      "latitude": "11.803749",
      "longitude": "-15.180413"
    },
    {
      "country_code": "GY",
      "country": "Guyana",
      "latitude": "4.860416",
      "longitude": "-58.93018"
    },
    {
      "country_code": "GZ",
      "country": "Gaza Strip",
      "latitude": "31.354676",
      "longitude": "34.308825"
    },
    {
      "country_code": "HK",
      "country": "Hong Kong",
      "latitude": "22.396428",
      "longitude": "114.109497"
    },
    {
      "country_code": "HM",
      "country": "Heard Island and McDonald Islands",
      "latitude": "-53.08181",
      "longitude": "73.504158"
    },
    {
      "country_code": "HN",
      "country": "Honduras",
      "latitude": "15.199999",
      "longitude": "-86.241905"
    },
    {
      "country_code": "HR",
      "country": "Croatia",
      "latitude": "45.1",
      "longitude": "15.2"
    },
    {
      "country_code": "HT",
      "country": "Haiti",
      "latitude": "18.971187",
      "longitude": "-72.285215"
    },
    {
      "country_code": "HU",
      "country": "Hungary",
      "latitude": "47.162494",
      "longitude": "19.503304"
    },
    {
      "country_code": "ID",
      "country": "Indonesia",
      "latitude": "-0.789275",
      "longitude": "113.921327"
    },
    {
      "country_code": "IE",
      "country": "Ireland",
      "latitude": "53.41291",
      "longitude": "-8.24389"
    },
    {
      "country_code": "IL",
      "country": "Israel",
      "latitude": "31.046051",
      "longitude": "34.851612"
    },
    {
      "country_code": "IM",
      "country": "Isle of Man",
      "latitude": "54.236107",
      "longitude": "-4.548056"
    },
    {
      "country_code": "IN",
      "country": "India",
      "latitude": "20.593684",
      "longitude": "78.96288"
    },
    {
      "country_code": "IO",
      "country": "British Indian Ocean Territory",
      "latitude": "-6.343194",
      "longitude": "71.876519"
    },
    {
      "country_code": "IQ",
      "country": "Iraq",
      "latitude": "33.223191",
      "longitude": "43.679291"
    },
    {
      "country_code": "IR",
      "country": "Iran",
      "latitude": "32.427908",
      "longitude": "53.688046"
    },
    {
      "country_code": "IS",
      "country": "Iceland",
      "latitude": "64.963051",
      "longitude": "-19.020835"
    },
    {
      "country_code": "IT",
      "country": "Italy",
      "latitude": "41.87194",
      "longitude": "12.56738"
    },
    {
      "country_code": "JE",
      "country": "Jersey",
      "latitude": "49.214439",
      "longitude": "-2.13125"
    },
    {
      "country_code": "JM",
      "country": "Jamaica",
      "latitude": "18.109581",
      "longitude": "-77.297508"
    },
    {
      "country_code": "JO",
      "country": "Jordan",
      "latitude": "30.585164",
      "longitude": "36.238414"
    },
    {
      "country_code": "JP",
      "country": "Japan",
      "latitude": "36.204824",
      "longitude": "138.252924"
    },
    {
      "country_code": "KE",
      "country": "Kenya",
      "latitude": "-0.023559",
      "longitude": "37.906193"
    },
    {
      "country_code": "KG",
      "country": "Kyrgyzstan",
      "latitude": "41.20438",
      "longitude": "74.766098"
    },
    {
      "country_code": "KH",
      "country": "Cambodia",
      "latitude": "12.565679",
      "longitude": "104.990963"
    },
    {
      "country_code": "KI",
      "country": "Kiribati",
      "latitude": "-3.370417",
      "longitude": "-168.734039"
    },
    {
      "country_code": "KM",
      "country": "Comoros",
      "latitude": "-11.875001",
      "longitude": "43.872219"
    },
    {
      "country_code": "KN",
      "country": "Saint Kitts and Nevis",
      "latitude": "17.357822",
      "longitude": "-62.782998"
    },
    {
      "country_code": "KP",
      "country": "North Korea",
      "latitude": "40.339852",
      "longitude": "127.510093"
    },
    {
      "country_code": "KR",
      "country": "South Korea",
      "latitude": "35.907757",
      "longitude": "127.766922"
    },
    {
      "country_code": "KW",
      "country": "Kuwait",
      "latitude": "29.31166",
      "longitude": "47.481766"
    },
    {
      "country_code": "KY",
      "country": "Cayman Islands",
      "latitude": "19.513469",
      "longitude": "-80.566956"
    },
    {
      "country_code": "KZ",
      "country": "Kazakhstan",
      "latitude": "48.019573",
      "longitude": "66.923684"
    },
    {
      "country_code": "LA",
      "country": "Laos",
      "latitude": "19.85627",
      "longitude": "102.495496"
    },
    {
      "country_code": "LB",
      "country": "Lebanon",
      "latitude": "33.854721",
      "longitude": "35.862285"
    },
    {
      "country_code": "LC",
      "country": "Saint Lucia",
      "latitude": "13.909444",
      "longitude": "-60.978893"
    },
    {
      "country_code": "LI",
      "country": "Liechtenstein",
      "latitude": "47.166",
      "longitude": "9.555373"
    },
    {
      "country_code": "LK",
      "country": "Sri Lanka",
      "latitude": "7.873054",
      "longitude": "80.771797"
    },
    {
      "country_code": "LR",
      "country": "Liberia",
      "latitude": "6.428055",
      "longitude": "-9.429499"
    },
    {
      "country_code": "LS",
      "country": "Lesotho",
      "latitude": "-29.609988",
      "longitude": "28.233608"
    },
    {
      "country_code": "LT",
      "country": "Lithuania",
      "latitude": "55.169438",
      "longitude": "23.881275"
    },
    {
      "country_code": "LU",
      "country": "Luxembourg",
      "latitude": "49.815273",
      "longitude": "6.129583"
    },
    {
      "country_code": "LV",
      "country": "Latvia",
      "latitude": "56.879635",
      "longitude": "24.603189"
    },
    {
      "country_code": "LY",
      "country": "Libya",
      "latitude": "26.3351",
      "longitude": "17.228331"
    },
    {
      "country_code": "MA",
      "country": "Morocco",
      "latitude": "31.791702",
      "longitude": "-7.09262"
    },
    {
      "country_code": "MC",
      "country": "Monaco",
      "latitude": "43.750298",
      "longitude": "7.412841"
    },
    {
      "country_code": "MD",
      "country": "Moldova",
      "latitude": "47.411631",
      "longitude": "28.369885"
    },
    {
      "country_code": "ME",
      "country": "Montenegro",
      "latitude": "42.708678",
      "longitude": "19.37439"
    },
    {
      "country_code": "MG",
      "country": "Madagascar",
      "latitude": "-18.766947",
      "longitude": "46.869107"
    },
    {
      "country_code": "MH",
      "country": "Marshall Islands",
      "latitude": "7.131474",
      "longitude": "171.184478"
    },
    {
      "country_code": "MK",
      "country": "Macedonia [FYROM]",
      "latitude": "41.608635",
      "longitude": "21.745275"
    },
    {
      "country_code": "ML",
      "country": "Mali",
      "latitude": "17.570692",
      "longitude": "-3.996166"
    },
    {
      "country_code": "MM",
      "country": "Myanmar [Burma]",
      "latitude": "21.913965",
      "longitude": "95.956223"
    },
    {
      "country_code": "MN",
      "country": "Mongolia",
      "latitude": "46.862496",
      "longitude": "103.846656"
    },
    {
      "country_code": "MO",
      "country": "Macau",
      "latitude": "22.198745",
      "longitude": "113.543873"
    },
    {
      "country_code": "MP",
      "country": "Northern Mariana Islands",
      "latitude": "17.33083",
      "longitude": "145.38469"
    },
    {
      "country_code": "MQ",
      "country": "Martinique",
      "latitude": "14.641528",
      "longitude": "-61.024174"
    },
    {
      "country_code": "MR",
      "country": "Mauritania",
      "latitude": "21.00789",
      "longitude": "-10.940835"
    },
    {
      "country_code": "MS",
      "country": "Montserrat",
      "latitude": "16.742498",
      "longitude": "-62.187366"
    },
    {
      "country_code": "MT",
      "country": "Malta",
      "latitude": "35.937496",
      "longitude": "14.375416"
    },
    {
      "country_code": "MU",
      "country": "Mauritius",
      "latitude": "-20.348404",
      "longitude": "57.552152"
    },
    {
      "country_code": "MV",
      "country": "Maldives",
      "latitude": "3.202778",
      "longitude": "73.22068"
    },
    {
      "country_code": "MW",
      "country": "Malawi",
      "latitude": "-13.254308",
      "longitude": "34.301525"
    },
    {
      "country_code": "MX",
      "country": "Mexico",
      "latitude": "23.634501",
      "longitude": "-102.552784"
    },
    {
      "country_code": "MY",
      "country": "Malaysia",
      "latitude": "4.210484",
      "longitude": "101.975766"
    },
    {
      "country_code": "MZ",
      "country": "Mozambique",
      "latitude": "-18.665695",
      "longitude": "35.529562"
    },
    {
      "country_code": "NA",
      "country": "Namibia",
      "latitude": "-22.95764",
      "longitude": "18.49041"
    },
    {
      "country_code": "NC",
      "country": "New Caledonia",
      "latitude": "-20.904305",
      "longitude": "165.618042"
    },
    {
      "country_code": "NE",
      "country": "Niger",
      "latitude": "17.607789",
      "longitude": "8.081666"
    },
    {
      "country_code": "NF",
      "country": "Norfolk Island",
      "latitude": "-29.040835",
      "longitude": "167.954712"
    },
    {
      "country_code": "NG",
      "country": "Nigeria",
      "latitude": "9.081999",
      "longitude": "8.675277"
    },
    {
      "country_code": "NI",
      "country": "Nicaragua",
      "latitude": "12.865416",
      "longitude": "-85.207229"
    },
    {
      "country_code": "NL",
      "country": "Netherlands",
      "latitude": "52.132633",
      "longitude": "5.291266"
    },
    {
      "country_code": "NO",
      "country": "Norway",
      "latitude": "60.472024",
      "longitude": "8.468946"
    },
    {
      "country_code": "NP",
      "country": "Nepal",
      "latitude": "28.394857",
      "longitude": "84.124008"
    },
    {
      "country_code": "NR",
      "country": "Nauru",
      "latitude": "-0.522778",
      "longitude": "166.931503"
    },
    {
      "country_code": "NU",
      "country": "Niue",
      "latitude": "-19.054445",
      "longitude": "-169.867233"
    },
    {
      "country_code": "NZ",
      "country": "New Zealand",
      "latitude": "-40.900557",
      "longitude": "174.885971"
    },
    {
      "country_code": "OM",
      "country": "Oman",
      "latitude": "21.512583",
      "longitude": "55.923255"
    },
    {
      "country_code": "PA",
      "country": "Panama",
      "latitude": "8.537981",
      "longitude": "-80.782127"
    },
    {
      "country_code": "PE",
      "country": "Peru",
      "latitude": "-9.189967",
      "longitude": "-75.015152"
    },
    {
      "country_code": "PF",
      "country": "French Polynesia",
      "latitude": "-17.679742",
      "longitude": "-149.406843"
    },
    {
      "country_code": "PG",
      "country": "Papua New Guinea",
      "latitude": "-6.314993",
      "longitude": "143.95555"
    },
    {
      "country_code": "PH",
      "country": "Philippines",
      "latitude": "12.879721",
      "longitude": "121.774017"
    },
    {
      "country_code": "PK",
      "country": "Pakistan",
      "latitude": "30.375321",
      "longitude": "69.345116"
    },
    {
      "country_code": "PL",
      "country": "Poland",
      "latitude": "51.919438",
      "longitude": "19.145136"
    },
    {
      "country_code": "PM",
      "country": "Saint Pierre and Miquelon",
      "latitude": "46.941936",
      "longitude": "-56.27111"
    },
    {
      "country_code": "PN",
      "country": "Pitcairn Islands",
      "latitude": "-24.703615",
      "longitude": "-127.439308"
    },
    {
      "country_code": "PR",
      "country": "Puerto Rico",
      "latitude": "18.220833",
      "longitude": "-66.590149"
    },
    {
      "country_code": "PS",
      "country": "Palestinian Territories",
      "latitude": "31.952162",
      "longitude": "35.233154"
    },
    {
      "country_code": "PT",
      "country": "Portugal",
      "latitude": "39.399872",
      "longitude": "-8.224454"
    },
    {
      "country_code": "PW",
      "country": "Palau",
      "latitude": "7.51498",
      "longitude": "134.58252"
    },
    {
      "country_code": "PY",
      "country": "Paraguay",
      "latitude": "-23.442503",
      "longitude": "-58.443832"
    },
    {
      "country_code": "QA",
      "country": "Qatar",
      "latitude": "25.354826",
      "longitude": "51.183884"
    },
    {
      "country_code": "RE",
      "country": "Réunion",
      "latitude": "-21.115141",
      "longitude": "55.536384"
    },
    {
      "country_code": "RO",
      "country": "Romania",
      "latitude": "45.943161",
      "longitude": "24.96676"
    },
    {
      "country_code": "RS",
      "country": "Serbia",
      "latitude": "44.016521",
      "longitude": "21.005859"
    },
    {
      "country_code": "RU",
      "country": "Russia",
      "latitude": "61.52401",
      "longitude": "105.318756"
    },
    {
      "country_code": "RW",
      "country": "Rwanda",
      "latitude": "-1.940278",
      "longitude": "29.873888"
    },
    {
      "country_code": "SA",
      "country": "Saudi Arabia",
      "latitude": "23.885942",
      "longitude": "45.079162"
    },
    {
      "country_code": "SB",
      "country": "Solomon Islands",
      "latitude": "-9.64571",
      "longitude": "160.156194"
    },
    {
      "country_code": "SC",
      "country": "Seychelles",
      "latitude": "-4.679574",
      "longitude": "55.491977"
    },
    {
      "country_code": "SD",
      "country": "Sudan",
      "latitude": "12.862807",
      "longitude": "30.217636"
    },
    {
      "country_code": "SE",
      "country": "Sweden",
      "latitude": "60.128161",
      "longitude": "18.643501"
    },
    {
      "country_code": "SG",
      "country": "Singapore",
      "latitude": "1.352083",
      "longitude": "103.819836"
    },
    {
      "country_code": "SH",
      "country": "Saint Helena",
      "latitude": "-24.143474",
      "longitude": "-10.030696"
    },
    {
      "country_code": "SI",
      "country": "Slovenia",
      "latitude": "46.151241",
      "longitude": "14.995463"
    },
    {
      "country_code": "SJ",
      "country": "Svalbard and Jan Mayen",
      "latitude": "77.553604",
      "longitude": "23.670272"
    },
    {
      "country_code": "SK",
      "country": "Slovakia",
      "latitude": "48.669026",
      "longitude": "19.699024"
    },
    {
      "country_code": "SL",
      "country": "Sierra Leone",
      "latitude": "8.460555",
      "longitude": "-11.779889"
    },
    {
      "country_code": "SM",
      "country": "San Marino",
      "latitude": "43.94236",
      "longitude": "12.457777"
    },
    {
      "country_code": "SN",
      "country": "Senegal",
      "latitude": "14.497401",
      "longitude": "-14.452362"
    },
    {
      "country_code": "SO",
      "country": "Somalia",
      "latitude": "5.152149",
      "longitude": "46.199616"
    },
    {
      "country_code": "SR",
      "country": "Suriname",
      "latitude": "3.919305",
      "longitude": "-56.027783"
    },
    {
      "country_code": "ST",
      "country": "São Tomé and Príncipe",
      "latitude": "0.18636",
      "longitude": "6.613081"
    },
    {
      "country_code": "SV",
      "country": "El Salvador",
      "latitude": "13.794185",
      "longitude": "-88.89653"
    },
    {
      "country_code": "SY",
      "country": "Syria",
      "latitude": "34.802075",
      "longitude": "38.996815"
    },
    {
      "country_code": "SZ",
      "country": "Swaziland",
      "latitude": "-26.522503",
      "longitude": "31.465866"
    },
    {
      "country_code": "TC",
      "country": "Turks and Caicos Islands",
      "latitude": "21.694025",
      "longitude": "-71.797928"
    },
    {
      "country_code": "TD",
      "country": "Chad",
      "latitude": "15.454166",
      "longitude": "18.732207"
    },
    {
      "country_code": "TF",
      "country": "French Southern Territories",
      "latitude": "-49.280366",
      "longitude": "69.348557"
    },
    {
      "country_code": "TG",
      "country": "Togo",
      "latitude": "8.619543",
      "longitude": "0.824782"
    },
    {
      "country_code": "TH",
      "country": "Thailand",
      "latitude": "15.870032",
      "longitude": "100.992541"
    },
    {
      "country_code": "TJ",
      "country": "Tajikistan",
      "latitude": "38.861034",
      "longitude": "71.276093"
    },
    {
      "country_code": "TK",
      "country": "Tokelau",
      "latitude": "-8.967363",
      "longitude": "-171.855881"
    },
    {
      "country_code": "TL",
      "country": "Timor-Leste",
      "latitude": "-8.874217",
      "longitude": "125.727539"
    },
    {
      "country_code": "TM",
      "country": "Turkmenistan",
      "latitude": "38.969719",
      "longitude": "59.556278"
    },
    {
      "country_code": "TN",
      "country": "Tunisia",
      "latitude": "33.886917",
      "longitude": "9.537499"
    },
    {
      "country_code": "TO",
      "country": "Tonga",
      "latitude": "-21.178986",
      "longitude": "-175.198242"
    },
    {
      "country_code": "TR",
      "country": "Turkey",
      "latitude": "38.963745",
      "longitude": "35.243322"
    },
    {
      "country_code": "TT",
      "country": "Trinidad and Tobago",
      "latitude": "10.691803",
      "longitude": "-61.222503"
    },
    {
      "country_code": "TV",
      "country": "Tuvalu",
      "latitude": "-7.109535",
      "longitude": "177.64933"
    },
    {
      "country_code": "TW",
      "country": "Taiwan",
      "latitude": "23.69781",
      "longitude": "120.960515"
    },
    {
      "country_code": "TZ",
      "country": "Tanzania",
      "latitude": "-6.369028",
      "longitude": "34.888822"
    },
    {
      "country_code": "UA",
      "country": "Ukraine",
      "latitude": "48.379433",
      "longitude": "31.16558"
    },
    {
      "country_code": "UG",
      "country": "Uganda",
      "latitude": "1.373333",
      "longitude": "32.290275"
    },
    {
      "country_code": "UM",
      "country": "U.S. Minor Outlying Islands",
      "latitude": "",
      "longitude": ""
    },
    {
      "country_code": "US",
      "country": "United States",
      "latitude": "37.09024",
      "longitude": "-95.712891"
    },
    {
      "country_code": "UY",
      "country": "Uruguay",
      "latitude": "-32.522779",
      "longitude": "-55.765835"
    },
    {
      "country_code": "UZ",
      "country": "Uzbekistan",
      "latitude": "41.377491",
      "longitude": "64.585262"
    },
    {
      "country_code": "VA",
      "country": "Vatican City",
      "latitude": "41.902916",
      "longitude": "12.453389"
    },
    {
      "country_code": "VC",
      "country": "Saint Vincent and the Grenadines",
      "latitude": "12.984305",
      "longitude": "-61.287228"
    },
    {
      "country_code": "VE",
      "country": "Venezuela",
      "latitude": "6.42375",
      "longitude": "-66.58973"
    },
    {
      "country_code": "VG",
      "country": "British Virgin Islands",
      "latitude": "18.420695",
      "longitude": "-64.639968"
    },
    {
      "country_code": "VI",
      "country": "U.S. Virgin Islands",
      "latitude": "18.335765",
      "longitude": "-64.896335"
    },
    {
      "country_code": "VN",
      "country": "Vietnam",
      "latitude": "14.058324",
      "longitude": "108.277199"
    },
    {
      "country_code": "VU",
      "country": "Vanuatu",
      "latitude": "-15.376706",
      "longitude": "166.959158"
    },
    {
      "country_code": "WF",
      "country": "Wallis and Futuna",
      "latitude": "-13.768752",
      "longitude": "-177.156097"
    },
    {
      "country_code": "WS",
      "country": "Samoa",
      "latitude": "-13.759029",
      "longitude": "-172.104629"
    },
    {
      "country_code": "XK",
      "country": "Kosovo",
      "latitude": "42.602636",
      "longitude": "20.902977"
    },
    {
      "country_code": "YE",
      "country": "Yemen",
      "latitude": "15.552727",
      "longitude": "48.516388"
    },
    {
      "country_code": "YT",
      "country": "Mayotte",
      "latitude": "-12.8275",
      "longitude": "45.166244"
    },
    {
      "country_code": "ZA",
      "country": "South Africa",
      "latitude": "-30.559482",
      "longitude": "22.937506"
    },
    {
      "country_code": "ZM",
      "country": "Zambia",
      "latitude": "-13.133897",
      "longitude": "27.849332"
    },
    {
      "country_code": "ZW",
      "country": "Zimbabwe",
      "latitude": "-19.015438",
      "longitude": "29.154857"
    }
  ];
