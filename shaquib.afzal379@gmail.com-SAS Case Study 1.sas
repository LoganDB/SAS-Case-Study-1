  /*************************** CASE STUDY 1 ********************************************/

/*Import necessary files*/

proc import datafile='/folders/myfolders/flights.csv' 
  out=flights 
  dbms=csv replace;
  guessingrows=10000;
run;

proc import datafile='/folders/myfolders/weather.csv' 
  out=weather 
  dbms=csv replace;
  guessingrows=10000;
run;

proc import datafile='/folders/myfolders/planes.csv' 
  out=planes 
  dbms=csv replace;
  guessingrows=10000;
run;



/******************* Preparing the data *********************/
proc means data=FLIGHTS nmiss n;  /*************** Number of missing values in numeric variable****************/
run;


/***************************** Calculating Missing Value in Each Variable**************************************/
proc format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
proc freq data=flights; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;


/********************** Deleting the observations consisting of missing values in 3 variables *****************/
data flights;
set flights;
if tailnum=" " then delete;
if arr_time="." then delete;
if dep_time="." then delete;
run;

/********************Rechecking number of missing values********************/
proc freq data=flights; 
format _CHAR_ $missfmt.; 
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

/********************** Changing the time variables *************************/
data flights;
set flights;
finaldep_time=compbl((substr((put(dep_time,z4.)),1,2))||":"||(substr((put(dep_time,z4.)),3,2)));
finalsched_dep_time=compbl((substr((put(sched_dep_time,z4.)),1,2))||":"||(substr((put(sched_dep_time,z4.)),3,2)));
finalarr_time=compbl((substr((put(arr_time,z4.)),1,2))||":"||(substr((put(arr_time,z4.)),3,2)));
finalsched_arr_time=compbl((substr((put(sched_arr_time,z4.)),1,2))||":"||(substr((put(sched_arr_time,z4.)),3,2)));
run;

data flights;
set flights;
finaldep_time1=input(finaldep_time,time5.);
finalsched_dep_time1=input(finalsched_dep_time,time5.);
finalarr_time1=input(finalarr_time,time5.);
finalsched_arr_time1=input(finalsched_arr_time,time5.);
flight1=put(flight,best12.);
format finaldep_time1 timeAMPM8. finalsched_dep_time1 timeAMPM8. finalarr_time1 timeAMPM8. finalsched_arr_time1 timeAMPM8.;
run;


data flights;
set flights;
drop finalsched_dep_time finaldep_time finalarr_time finalsched_arr_time dep_time arr_time sched_dep_time sched_arr_time flight;
rename finaldep_time1=dep_time finalsched_dep_time1=sched_dep_time finalarr_time1=arr_time finalsched_arr_time1=sched_arr_time flight1=flight;
run;



/******************* Question 1-Creating new variables *************************************/
data flights;
set flights;
Year=year(date);
Month=month(date);
Day=day(Date);
Hour=hour(sched_dep_time);         
Hour1=hour(sched_arr_time);
Hour=hms(Hour,0,0);
hour1=hms(Hour1,0,0);
Dep_delay=dep_time-sched_dep_time;
Arr_delay=arr_time-sched_arr_time;
format Dep_delay time5. Arr_delay time5. Hour time. hour1 time. hour2 time. ;
run;


/************** Fixing the 'time' variable in Weathers dataset ***************/
data weather;
set weather;
if length(time)=4 then time="0"||time;
time1=input(time,time5.);

format time1 time.;
run;

data weather;
set weather;
drop time;
rename time1=time;
run;


/***************** QUESTION-2 & QUESTION-8(A)**************************/
proc sql;
create table joined as
select flights.*, weather.*
from flights left join weather
on flights.hour=weather.time and flights.date=weather.date and flights.origin=weather.origin;
quit;

/***************** QUESTION 3 ************************/
data planes;
set planes;
drop speed;
if manufacturing_year="." then delete;
if fuel_cc="." then delete;
fuel_cc=round(fuel_cc);
run;
/********************** QUESTION 4-FORMATTING ***********************/
/************************* Assigning variable and value labels **********************************/
data planes;
set planes;
label plane="Tail Number"
manufacturing_year="Year manufactured"
type="Type of plane"
manufacturer="Manufacturer"
model="Model"
engines="Number of engines"
seats="Number of seats"
engine="Type of engine"
fuel_cc="Average annual fuel consumption cost" ;
run;

data flights;
set flights;
label date='Date of departure'
dep_time='Actual departure time'
arr_time='Actual arrival time'
sched_dep_time='Scheduled departure time'
sched_arr_time='Scheduled arrival time'
carrier='Carrier'
flight='Flight number'
tailnum='Plane tail number'
origin='Origin'
dest='Destination'
distance='Distance flown'
air_time='Amount of time spent in the air, in minutes'
dep_delay='Delay in departure'
arr_delay='Delay in arrival';
run;



PROC FORMAT;
VALUE $ carrier
"9E"='Endeavor Air Inc.'
"AA"='American Airlines Inc.'
"AS"='Alaska Airlines Inc.'
"B6"='JetBlue Airways'
"DL"='Delta Air Lines Inc.'
"EV"='ExpressJet Airlines Inc.'
"F9"='Frontier Airlines Inc.'
"FL"='AirTran Airways Corporation'
"HA"='Hawaiian Airlines Inc.'
"MQ"='Envoy Air'
"OO"='SkyWest Airlines Inc.'
"UA"='United Air Lines Inc.'
"US"='US Airways Inc.'
"VX"='Virgin America'
"WN"='Southwest Airlines Co.'
"YV"='Mesa Airlines Inc.';

VALUE $ airportname
"04G"= "Lansdowne Airport "
"06A"= "Moton Field Municipal Airport "
"06C"= "Schaumburg Regional "
"06N"= "Randall Airport "
"09J"= "Jekyll Island Airport "
"0A9"= "Elizabethton Municipal Airport "
"0G6"= "Williams County Airport "
"0G7"= "Finger Lakes Regional Airport "
"0P2"= "Shoestring Aviation Airfield "
"0S9"= "Jefferson County Intl "
"0W3"= "Harford County Airport "
"10C"= "Galt Field Airport "
"17G"= "Port Bucyrus-Crawford County Airport "
"19A"= "Jackson County Airport "
"1A3"= "Martin Campbell Field Airport "
"1B9"= "Mansfield Municipal "
"1C9"= "Frazier Lake Airpark "
"1CS"= "Clow International Airport "
"1G3"= "Kent State Airport "
"1OH"= "Fortman Airport "
"1RL"= "Point Roberts Airpark "
"24C"= "Lowell City Airport "
"24J"= "Suwannee County Airport "
"25D"= "Forest Lake Airport "
"29D"= "Grove City Airport "
"2A0"= "Mark Anton Airport "
"2G2"= "Jefferson County Airpark "
"2G9"= "Somerset County Airport "
"2J9"= "Quincy Municipal Airport "
"369"= "Atmautluak Airport "
"36U"= "Heber City Municipal Airport "
"38W"= "Lynden Airport "
"3D2"= "Ephraim-Gibraltar Airport "
"3G3"= "Wadsworth Municipal "
"3G4"= "Ashland County Airport "
"3J1"= "Ridgeland Airport "
"3W2"= "Put-in-Bay Airport "
"40J"= "Perry-Foley Airport "
"41N"= "Braceville Airport "
"47A"= "Cherokee County Airport "
"49A"= "Gilmer County Airport "
"49X"= "Chemehuevi Valley "
"4A4"= "Polk County Airport - Cornelius Moore Field "
"4A7"= "Clayton County Tara Field "
"4A9"= "Isbell Field Airport "
"4B8"= "Robertson Field "
"4G0"= "Pittsburgh-Monroeville Airport "
"4G2"= "Hamburg Inc Airport "
"4G4"= "Youngstown Elser Metro Airport "
"4I7"= "Putnam County Airport "
"4U9"= "Dell Flight Strip "
"52A"= "Madison GA Municipal Airport "
"54J"= "DeFuniak Springs Airport "
"55J"= "Fernandina Beach Municipal Airport "
"57C"= "East Troy Municipal Airport "
"60J"= "Ocean Isle Beach Airport "
"6A2"= "Griffin-Spalding County Airport "
"6K8"= "Tok Junction Airport "
"6S0"= "Big Timber Airport "
"6S2"= "Florence "
"6Y8"= "Welke Airport "
"70J"= "Cairo-Grady County Airport "
"70N"= "Spring Hill Airport "
"7A4"= "Foster Field "
"7D9"= "Germack Airport "
"7N7"= "Spitfire Aerodrome "
"8M8"= "Garland Airport "
"93C"= "Richland Airport "
"99N"= "Bamberg County Airport "
"9A1"= "Covington Municipal Airport "
"9A5"= "Barwick Lafayette Airport "
"A39"= "Phoenix Regional Airport "
"AAF"= "Apalachicola Regional Airport "
"ABE"= "Lehigh Valley Intl "
"ABI"= "Abilene Rgnl "
"ABL"= "Ambler Airport "
"ABQ"= "Albuquerque International Sunport "
"ABR"= "Aberdeen Regional Airport "
"ABY"= "Southwest Georgia Regional Airport "
"ACK"= "Nantucket Mem "
"ACT"= "Waco Rgnl "
"ACV"= "Arcata "
"ACY"= "Atlantic City Intl "
"ADK"= "Adak Airport "
"ADM"= "Ardmore Muni "
"ADQ"= "Kodiak "
"ADS"= "Addison "
"ADW"= "Andrews Afb "
"AET"= "Allakaket Airport "
"AEX"= "Alexandria Intl "
"AFE"= "Kake Airport "
"AFW"= "Fort Worth Alliance Airport "
"AGC"= "Allegheny County Airport "
"AGN"= "Angoon Seaplane Base "
"AGS"= "Augusta Rgnl At Bush Fld "
"AHN"= "Athens Ben Epps Airport "
"AIA"= "Alliance Municipal Airport "
"AIK"= "Municipal Airport "
"AIN"= "Wainwright Airport "
"AIZ"= "Lee C Fine Memorial Airport "
"AKB"= "Atka Airport "
"AKC"= "Akron Fulton Intl "
"AKI"= "Akiak Airport "
"AKK"= "Akhiok Airport "
"AKN"= "King Salmon "
"AKP"= "Anaktuvuk Pass Airport "
"ALB"= "Albany Intl "
"ALI"= "Alice Intl "
"ALM"= "Alamogordo White Sands Regional Airport "
"ALO"= "Waterloo Regional Airport "
"ALS"= "San Luis Valley Regional Airport "
"ALW"= "Walla Walla Regional Airport "
"ALX"= "Alexandria "
"ALZ"= "Alitak Seaplane Base "
"AMA"= "Rick Husband Amarillo Intl "
"ANB"= "Anniston Metro "
"ANC"= "Ted Stevens Anchorage Intl "
"AND"= "Anderson Rgnl "
"ANI"= "Aniak Airport "
"ANN"= "Annette Island "
"ANP"= "Lee Airport "
"ANQ"= "Tri-State Steuben County Airport "
"ANV"= "Anvik Airport "
"AOH"= "Lima Allen County Airport "
"AOO"= "Altoona Blair Co "
"AOS"= "Amook Bay Seaplane Base "
"APA"= "Centennial "
"APC"= "Napa County Airport "
"APF"= "Naples Muni "
"APG"= "Phillips Aaf "
"APN"= "Alpena County Regional Airport "
"AQC"= "Klawock Seaplane Base "
"ARA"= "Acadiana Rgnl "
"ARB"= "Ann Arbor Municipal Airport "
"ARC"= "Arctic Village Airport "
"ART"= "Watertown Intl "
"ARV"= "Lakeland "
"ASE"= "Aspen Pitkin County Sardy Field "
"ASH"= "Boire Field Airport "
"AST"= "Astoria Regional Airport "
"ATK"= "Atqasuk Edward Burnell Sr Memorial Airport "
"ATL"= "Hartsfield Jackson Atlanta Intl "
"ATT"= "Camp Mabry Austin City "
"ATW"= "Appleton "
"ATY"= "Watertown Regional Airport "
"AUG"= "Augusta State "
"AUK"= "Alakanuk Airport "
"AUS"= "Austin Bergstrom Intl "
"AUW"= "Wausau Downtown Airport "
"AVL"= "Asheville Regional Airport "
"AVO"= "Executive "
"AVP"= "Wilkes Barre Scranton Intl "
"AVW"= "Marana Regional "
"AVX"= "Avalon "
"AZA"= "Phoenix-Mesa Gateway "
"AZO"= "Kalamazoo "
"BAB"= "Beale Afb "
"BAD"= "Barksdale Afb "
"BAF"= "Barnes Municipal "
"BBX"= "Wings Field "
"BCE"= "Bryce Canyon "
"BCT"= "Boca Raton "
"BDE"= "Baudette Intl "
"BDL"= "Bradley Intl "
"BDR"= "Igor I Sikorsky Mem "
"BEC"= "Beech Factory Airport "
"BED"= "Laurence G Hanscom Fld "
"BEH"= "Southwest Michigan Regional Airport "
"BET"= "Bethel "
"BFD"= "Bradford Regional Airport "
"BFF"= "Western Nebraska Regional Airport "
"BFI"= "Boeing Fld King Co Intl "
"BFL"= "Meadows Fld "
"BFM"= "Mobile Downtown "
"BFP"= "Beaver Falls "
"BFT"= "Beaufort "
"BGE"= "Decatur County Industrial Air Park "
"BGM"= "Greater Binghamton Edwin A Link Fld "
"BGR"= "Bangor Intl "
"BHB"= "Hancock County - Bar Harbor "
"BHM"= "Birmingham Intl "
"BID"= "Block Island State Airport "
"BIF"= "Biggs Aaf "
"BIG"= "Allen Aaf "
"BIL"= "Billings Logan International Airport "
"BIS"= "Bismarck Municipal Airport "
"BIV"= "Tulip City Airport "
"BIX"= "Keesler Afb "
"BJC"= "Rocky Mountain Metropolitan Airport "
"BJI"= "Bemidji Regional Airport "
"BKC"= "Buckland Airport "
"BKD"= "Stephens Co "
"BKF"= "Buckley Afb "
"BKG"= "Branson LLC "
"BKH"= "Barking Sands Pmrf "
"BKL"= "Burke Lakefront Airport "
"BKW"= "Raleigh County Memorial Airport "
"BKX"= "Brookings Regional Airport "
"BLD"= "Boulder City Municipal Airport "
"BLF"= "Mercer County Airport "
"BLH"= "Blythe Airport "
"BLI"= "Bellingham Intl "
"BLV"= "Scott Afb Midamerica "
"BMC"= "Brigham City "
"BMG"= "Monroe County Airport "
"BMI"= "Central Illinois Rgnl "
"BMX"= "Big Mountain Afs "
"BNA"= "Nashville Intl "
"BOI"= "Boise Air Terminal "
"BOS"= "General Edward Lawrence Logan Intl "
"BOW"= "Bartow Municipal Airport "
"BPT"= "Southeast Texas Rgnl "
"BQK"= "Brunswick Golden Isles Airport "
"BRD"= "Brainerd Lakes Rgnl "
"BRL"= "Southeast Iowa Regional Airport "
"BRO"= "Brownsville South Padre Island Intl "
"BRW"= "Wiley Post Will Rogers Mem "
"BSF"= "Bradshaw Aaf "
"BTI"= "Barter Island Lrrs "
"BTM"= "Bert Mooney Airport "
"BTR"= "Baton Rouge Metro Ryan Fld "
"BTT"= "Bettles "
"BTV"= "Burlington Intl "
"BUF"= "Buffalo Niagara Intl "
"BUR"= "Bob Hope "
"BUU"= "Municipal Airport "
"BUY"= "Burlington-Alamance Regional Airport "
"BVY"= "Beverly Municipal Airport "
"BWD"= "KBWD "
"BWG"= "Bowling Green-Warren County Regional Airport "
"BWI"= "Baltimore Washington Intl "
"BXK"= "Buckeye Municipal Airport "
"BXS"= "Borrego Valley Airport "
"BYH"= "Arkansas Intl "
"BYS"= "Bicycle Lake Aaf "
"BYW"= "Blakely Island Airport "
"BZN"= "Gallatin Field "
"C02"= "Grand Geneva Resort Airport "
"C16"= "Frasca Field "
"C47"= "Portage Municipal Airport "
"C65"= "Plymouth Municipal Airport "
"C89"= "Sylvania Airport "
"C91"= "Dowagiac Municipal Airport "
"CAE"= "Columbia Metropolitan "
"CAK"= "Akron Canton Regional Airport "
"CAR"= "Caribou Muni "
"CBE"= "Greater Cumberland Rgnl. "
"CBM"= "Columbus Afb "
"CCO"= "Coweta County Airport "
"CCR"= "Buchanan Field Airport "
"CDB"= "Cold Bay "
"CDC"= "Cedar City Rgnl "
"CDI"= "Cambridge Municipal Airport "
"CDK"= "CedarKey "
"CDN"= "Woodward Field "
"CDR"= "Chadron Municipal Airport "
"CDS"= "Childress Muni "
"CDV"= "Merle K Mudhole Smith "
"CDW"= "Caldwell Essex County Airport "
"CEC"= "Del Norte County Airport "
"CEF"= "Westover Arb Metropolitan "
"CEM"= "Central Airport "
"CEU"= "Clemson "
"CEW"= "Bob Sikes "
"CEZ"= "Cortez Muni "
"CFD"= "Coulter Fld "
"CGA"= "Craig Seaplane Base "
"CGF"= "Cuyahoga County "
"CGI"= "Cape Girardeau Regional Airport "
"CGX"= "Meigs Field "
"CGZ"= "Casa Grande Municipal Airport "
"CHA"= "Lovell Fld "
"CHI"= "All Airports "
"CHO"= "Charlottesville-Albemarle "
"CHS"= "Charleston Afb Intl "
"CHU"= "Chuathbaluk Airport "
"CIC"= "Chico Muni "
"CID"= "Cedar Rapids "
"CIK"= "Chalkyitsik Airport "
"CIL"= "Council Airport "
"CIU"= "Chippewa County International Airport "
"CKB"= "Harrison Marion Regional Airport "
"CKD"= "Crooked Creek Airport "
"CKF"= "Crisp County Cordele Airport "
"CKV"= "Clarksville-Montgomery County Regional Airport "
"CLC"= "Clear Lake Metroport "
"CLD"= "McClellan-Palomar Airport "
"CLE"= "Cleveland Hopkins Intl "
"CLL"= "Easterwood Fld "
"CLM"= "William R Fairchild International Airport "
"CLT"= "Charlotte Douglas Intl "
"CLW"= "Clearwater Air Park "
"CMH"= "Port Columbus Intl "
"CMI"= "Champaign "
"CMX"= "Houghton County Memorial Airport "
"CNM"= "Cavern City Air Terminal "
"CNW"= "Tstc Waco "
"CNY"= "Canyonlands Field "
"COD"= "Yellowstone Rgnl "
"COF"= "Patrick Afb "
"CON"= "Concord Municipal "
"COS"= "City Of Colorado Springs Muni "
"COT"= "Cotulla Lasalle Co "
"COU"= "Columbia Rgnl "
"CPR"= "Natrona Co Intl "
"CPS"= "St. Louis Downtown Airport "
"CRE"= "Grand Strand Airport "
"CRP"= "Corpus Christi Intl "
"CRW"= "Yeager "
"CSG"= "Columbus Metropolitan Airport "
"CTB"= "Cut Bank Muni "
"CTH"= "Chester County G O Carlson Airport "
"CTJ"= "West Georgia Regional Airport - O V Gray Field "
"CTY"= "Cross City "
"CVG"= "Cincinnati Northern Kentucky Intl "
"CVN"= "Clovis Muni "
"CVS"= "Cannon Afb "
"CVX"= "Charlevoix Municipal Airport "
"CWA"= "Central Wisconsin "
"CWI"= "Clinton Municipal "
"CXF"= "Coldfoot Airport "
"CXL"= "Calexico Intl "
"CXO"= "Lone Star Executive "
"CXY"= "Capital City Airport "
"CYF"= "Chefornak Airport "
"CYM"= "Chatham Seaplane Base "
"CYS"= "Cheyenne Rgnl Jerry Olson Fld "
"CYT"= "Yakataga Airport "
"CZF"= "Cape Romanzof Lrrs "
"CZN"= "Chisana Airport "
"DAB"= "Daytona Beach Intl "
"DAL"= "Dallas Love Fld "
"DAY"= "James M Cox Dayton Intl "
"DBQ"= "Dubuque Rgnl "
"DCA"= "Ronald Reagan Washington Natl "
"DDC"= "Dodge City Regional Airport "
"DEC"= "Decatur "
"DEN"= "Denver Intl "
"DET"= "Coleman A Young Muni "
"DFW"= "Dallas Fort Worth Intl "
"DGL"= "Douglas Municipal Airport "
"DHN"= "Dothan Rgnl "
"DHT"= "Dalhart Muni "
"DIK"= "Dickinson Theodore Roosevelt Regional Airport "
"DKB"= "De Kalb Taylor Municipal Airport "
"DKK"= "Chautauqua County-Dunkirk Airport "
"DKX"= "Knoxville Downtown Island Airport "
"DLF"= "Laughlin Afb "
"DLG"= "Dillingham "
"DLH"= "Duluth Intl "
"DLL"= "Baraboo Wisconsin Dells Airport "
"DMA"= "Davis Monthan Afb "
"DNL"= "Daniel Field Airport "
"DNN"= "Dalton Municipal Airport "
"DOV"= "Dover Afb "
"DPA"= "Dupage "
"DQH"= "Douglas Municipal Airport "
"DRG"= "Deering Airport "
"DRI"= "Beauregard Rgnl "
"DRM"= "Drummond Island Airport "
"DRO"= "Durango La Plata Co "
"DRT"= "Del Rio Intl "
"DSM"= "Des Moines Intl "
"DTA"= "Delta Municipal Airport "
"DTS"= "Destin "
"DTW"= "Detroit Metro Wayne Co "
"DUC"= "Halliburton Field Airport "
"DUG"= "Bisbee Douglas Intl "
"DUJ"= "DuBois Regional Airport "
"DUT"= "Unalaska "
"DVL"= "Devils Lake Regional Airport "
"DVT"= "Deer Valley Municipal Airport "
"DWA"= "Yolo County Airport "
"DWH"= "David Wayne Hooks Field "
"DWS"= "Orlando "
"DXR"= "Danbury Municipal Airport "
"DYS"= "Dyess Afb "
"E25"= "Wickenburg Municipal Airport "
"E51"= "Bagdad Airport "
"E55"= "Ocean Ridge Airport "
"E63"= "Gila Bend Municipal Airport "
"E91"= "Chinle Municipal Airport "
"EAA"= "Eagle Airport "
"EAR"= "Kearney Municipal Airport "
"EAT"= "Pangborn Field "
"EAU"= "Chippewa Valley Regional Airport "
"ECA"= "Iosco County "
"ECG"= "Elizabeth City Cgas Rgnl "
"ECP"= "Panama City-NW Florida Bea. "
"EDF"= "Elmendorf Afb "
"EDW"= "Edwards Afb "
"EEK"= "Eek Airport "
"EEN"= "Dillant Hopkins Airport "
"EET"= "Shelby County Airport "
"EFD"= "Ellington Fld "
"EGA"= "Eagle County Airport "
"EGE"= "Eagle Co Rgnl "
"EGT"= "Wellington Municipal "
"EGV"= "Eagle River "
"EGX"= "Egegik Airport "
"EHM"= "Cape Newenham Lrrs "
"EIL"= "Eielson Afb "
"EKI"= "Elkhart Municipal "
"EKN"= "Elkins Randolph Co Jennings Randolph "
"EKO"= "Elko Regional Airport "
"ELD"= "South Arkansas Rgnl At Goodwin Fld "
"ELI"= "Elim Airport "
"ELM"= "Elmira Corning Rgnl "
"ELP"= "El Paso Intl "
"ELV"= "Elfin Cove Seaplane Base "
"ELY"= "Ely Airport "
"EMK"= "Emmonak Airport "
"EMP"= "Emporia Municipal Airport "
"ENA"= "Kenai Muni "
"END"= "Vance Afb "
"ENV"= "Wendover "
"ENW"= "Kenosha Regional Airport "
"EOK"= "Keokuk Municipal Airport "
"EPM"= "Eastport Municipal Airport "
"EQY"= "Monroe Reqional Airport "
"ERI"= "Erie Intl Tom Ridge Fld "
"ERV"= "Kerrville Municipal Airport "
"ERY"= "Luce County Airport "
"ESC"= "Delta County Airport "
"ESD"= "Orcas Island Airport "
"ESF"= "Esler Rgnl "
"ESN"= "Easton-Newnam Field Airport "
"EUG"= "Mahlon Sweet Fld "
"EVV"= "Evansville Regional "
"EWB"= "New Bedford Regional Airport "
"EWN"= "Craven Co Rgnl "
"EWR"= "Newark Liberty Intl "
"EXI"= "Excursion Inlet Seaplane Base "
"EYW"= "Key West Intl "
"F57"= "Seaplane Base "
"FAF"= "Felker Aaf "
"FAI"= "Fairbanks Intl "
"FAR"= "Hector International Airport "
"FAT"= "Fresno Yosemite Intl "
"FAY"= "Fayetteville Regional Grannis Field "
"FBG"= "Fredericksburg Amtrak Station "
"FBK"= "Ladd Aaf "
"FBS"= "Friday Harbor Seaplane Base "
"FCA"= "Glacier Park Intl "
"FCS"= "Butts Aaf "
"FDY"= "Findlay Airport "
"FFA"= "First Flight Airport "
"FFC"= "Atlanta Regional Airport - Falcon Field "
"FFO"= "Wright Patterson Afb "
"FFT"= "Capital City Airport "
"FFZ"= "Mesa Falcon Field "
"FHU"= "Sierra Vista Muni Libby Aaf "
"FIT"= "Fitchburg Municipal Airport "
"FKL"= "Franklin "
"FLD"= "Fond Du Lac County Airport "
"FLG"= "Flagstaff Pulliam Airport "
"FLL"= "Fort Lauderdale Hollywood Intl "
"FLO"= "Florence Rgnl "
"FLV"= "Sherman Aaf "
"FME"= "Tipton "
"FMH"= "Otis Angb "
"FMN"= "Four Corners Rgnl "
"FMY"= "Page Fld "
"FNL"= "Fort Collins Loveland Muni "
"FNR"= "Funter Bay Seaplane Base "
"FNT"= "Bishop International "
"FOD"= "Fort Dodge Rgnl "
"FOE"= "Forbes Fld "
"FOK"= "Francis S Gabreski "
"FRD"= "Friday Harbor Airport "
"FRI"= "Marshall Aaf "
"FRN"= "Bryant Ahp "
"FRP"= "St Lucie County International Airport "
"FSD"= "Sioux Falls "
"FSI"= "Henry Post Aaf "
"FSM"= "Fort Smith Rgnl "
"FST"= "Fort Stockton Pecos Co "
"FTK"= "Godman Aaf "
"FTW"= "Fort Worth Meacham Intl "
"FTY"= "Fulton County Airport Brown Field "
"FUL"= "Fullerton Municipal Airport "
"FWA"= "Fort Wayne "
"FXE"= "Fort Lauderdale Executive "
"FYU"= "Fort Yukon "
"FYV"= "Drake Fld "
"FZG"= "Fitzgerald Municipal Airport "
"GAD"= "Northeast Alabama Regional Airport "
"GAI"= "Montgomery County Airpark "
"GAL"= "Edward G Pitka Sr "
"GAM"= "Gambell Airport "
"GBN"= "Great Bend Municipal "
"GCC"= "Gillette-Campbell County Airport "
"GCK"= "Garden City Rgnl "
"GCN"= "Grand Canyon National Park Airport "
"GCW"= "Grand Canyon West Airport "
"GDV"= "Dawson Community Airport "
"GDW"= "Gladwin Zettel Memorial Airport "
"GED"= "Sussex Co "
"GEG"= "Spokane Intl "
"GEU"= "Glendale Municipal Airport "
"GFK"= "Grand Forks Intl "
"GGE"= "Georgetown County Airport "
"GGG"= "East Texas Rgnl "
"GGW"= "Wokal Field Glasgow International Airport "
"GHG"= "Marshfield Municipal Airport "
"GIF"= "Gilbert Airport "
"GJT"= "Grand Junction Regional "
"GKN"= "Gulkana "
"GKY"= "Arlington Municipal "
"GLD"= "Renner Fld "
"GLH"= "Mid Delta Regional Airport "
"GLS"= "Scholes Intl At Galveston "
"GLV"= "Golovin Airport "
"GNT"= "Grants Milan Muni "
"GNU"= "Goodnews Airport "
"GNV"= "Gainesville Rgnl "
"GON"= "Groton New London "
"GPT"= "Gulfport-Biloxi "
"GPZ"= "Grand Rapids Itasca County "
"GQQ"= "Galion Municipal Airport "
"GRB"= "Austin Straubel Intl "
"GRF"= "Gray Aaf "
"GRI"= "Central Nebraska Regional Airport "
"GRK"= "Robert Gray Aaf "
"GRM"= "Grand Marais Cook County Airport "
"GRR"= "Gerald R Ford Intl "
"GSB"= "Seymour Johnson Afb "
"GSO"= "Piedmont Triad "
"GSP"= "Greenville-Spartanburg International "
"GST"= "Gustavus Airport "
"GTB"= "Wheeler Sack Aaf "
"GTF"= "Great Falls Intl "
"GTR"= "Golden Triangle Regional Airport "
"GTU"= "Georgetown Municipal Airport "
"GUC"= "Gunnison - Crested Butte "
"GUP"= "Gallup Muni "
"GUS"= "Grissom Arb "
"GVL"= "Lee Gilmer Memorial Airport "
"GVQ"= "Genesee County Airport "
"GVT"= "Majors "
"GWO"= "Greenwood Leflore "
"GYY"= "Gary Chicago International Airport "
"HBG"= "Hattiesburg Bobby L. Chain Municipal Airport "
"HBR"= "Hobart Muni "
"HCC"= "Columbia County "
"HCR"= "Holy Cross Airport "
"HDH"= "Dillingham "
"HDI"= "Hardwick Field Airport "
"HDN"= "Yampa Valley "
"HDO"= "Hondo Municipal Airport "
"HFD"= "Hartford Brainard "
"HGR"= "Hagerstown Regional Richard A Henson Field "
"HHH"= "Hilton Head "
"HHI"= "Wheeler Aaf "
"HHR"= "Jack Northrop Fld Hawthorne Muni "
"HIB"= "Chisholm Hibbing "
"HIF"= "Hill Afb "
"HII"= "Lake Havasu City Airport "
"HIO"= "Portland Hillsboro "
"HKB"= "Healy River Airport "
"HKY"= "Hickory Rgnl "
"HLG"= "Wheeling Ohio County Airport "
"HLN"= "Helena Rgnl "
"HLR"= "Hood Aaf "
"HMN"= "Holloman Afb "
"HNH"= "Hoonah Airport "
"HNL"= "Honolulu Intl "
"HNM"= "Hana "
"HNS"= "Haines Airport "
"HOB"= "Lea Co Rgnl "
"HOM"= "Homer "
"HON"= "Huron Rgnl "
"HOP"= "Campbell Aaf "
"HOT"= "Memorial Field "
"HOU"= "William P Hobby "
"HPB"= "Hooper Bay Airport "
"HPN"= "Westchester Co "
"HQM"= "Bowerman Field "
"HQU"= "McDuffie County Airport "
"HRL"= "Valley Intl "
"HRO"= "Boone Co "
"HRT"= "Hurlburt Fld "
"HSH"= "Henderson Executive Airport "
"HSL"= "Huslia Airport "
"HST"= "Homestead Arb "
"HSV"= "Huntsville International Airport-Carl T Jones Field "
"HTL"= "Roscommon Co "
"HTS"= "Tri State Milton J Ferguson Field "
"HUA"= "Redstone Aaf "
"HUF"= "Terre Haute Intl Hulman Fld "
"HUL"= "Houlton Intl "
"HUS"= "Hughes Airport "
"HUT"= "Hutchinson Municipal Airport "
"HVN"= "Tweed-New Haven Airport "
"HVR"= "Havre City Co "
"HWD"= "Hayward Executive Airport "
"HWO"= "North Perry "
"HXD"= "Hilton Head Airport "
"HYA"= "Barnstable Muni Boardman Polando Fld "
"HYG"= "Hydaburg Seaplane Base "
"HYL"= "Hollis Seaplane Base "
"HYS"= "Hays Regional Airport "
"HZL"= "Hazleton Municipal "
"IAB"= "Mc Connell Afb "
"IAD"= "Washington Dulles Intl "
"IAG"= "Niagara Falls Intl "
"IAH"= "George Bush Intercontinental "
"IAN"= "Bob Baker Memorial Airport "
"ICT"= "Wichita Mid Continent "
"ICY"= "Icy Bay Airport "
"IDA"= "Idaho Falls Rgnl "
"IDL"= "Idlewild Intl "
"IFP"= "Laughlin-Bullhead Intl "
"IGG"= "Igiugig Airport "
"IGM"= "Kingman Airport "
"IGQ"= "Lansing Municipal "
"IJD"= "Windham Airport "
"IKK"= "Greater Kankakee "
"IKO"= "Nikolski Air Station "
"IKR"= "Kirtland Air Force Base "
"IKV"= "Ankeny Regl Airport "
"ILG"= "New Castle "
"ILI"= "Iliamna "
"ILM"= "Wilmington Intl "
"ILN"= "Wilmington Airborne Airpark "
"IMM"= "Immokalee "
"IMT"= "Ford Airport "
"IND"= "Indianapolis Intl "
"INJ"= "Hillsboro Muni "
"INK"= "Winkler Co "
"INL"= "Falls Intl "
"INS"= "Creech Afb "
"INT"= "Smith Reynolds "
"INW"= "Winslow-Lindbergh Regional Airport "
"IOW"= "Iowa City Municipal Airport "
"IPL"= "Imperial Co "
"IPT"= "Williamsport Rgnl "
"IRC"= "Circle City Airport "
"IRK"= "Kirksville Regional Airport "
"ISM"= "Kissimmee Gateway Airport "
"ISN"= "Sloulin Fld Intl "
"ISO"= "Kinston Regional Jetport "
"ISP"= "Long Island Mac Arthur "
"ISW"= "Alexander Field South Wood County Airport "
"ITH"= "Ithaca Tompkins Rgnl "
"ITO"= "Hilo Intl "
"IWD"= "Gogebic Iron County Airport "
"IWS"= "West Houston "
"IYK"= "Inyokern Airport "
"JAC"= "Jackson Hole Airport "
"JAN"= "Jackson Evers Intl "
"JAX"= "Jacksonville Intl "
"JBR"= "Jonesboro Muni "
"JCI"= "New Century AirCenter Airport "
"JEF"= "Jefferson City Memorial Airport "
"JES"= "Jesup-Wayne County Airport "
"JFK"= "John F Kennedy Intl "
"JGC"= "Grand Canyon Heliport "
"JHM"= "Kapalua "
"JHW"= "Chautauqua County-Jamestown "
"JKA"= "Jack Edwards Airport "
"JLN"= "Joplin Rgnl "
"JMS"= "Jamestown Regional Airport "
"JNU"= "Juneau Intl "
"JOT"= "Regional Airport "
"JRA"= "West 30th St. Heliport "
"JRB"= "Wall Street Heliport "
"JST"= "John Murtha Johnstown-Cambria County Airport "
"JVL"= "Southern Wisconsin Regional Airport "
"JXN"= "Reynolds Field "
"JYL"= "Plantation Airpark "
"JYO"= "Leesburg Executive Airport "
"JZP"= "Pickens County Airport "
"K03"= "Wainwright As "
"KAE"= "Kake Seaplane Base "
"KAL"= "Kaltag Airport "
"KBC"= "Birch Creek Airport "
"KBW"= "Chignik Bay Seaplane Base "
"KCC"= "Coffman Cove Seaplane Base "
"KCL"= "Chignik Lagoon Airport "
"KCQ"= "Chignik Lake Airport "
"KEH"= "Kenmore Air Harbor Inc Seaplane Base "
"KEK"= "Ekwok Airport "
"KFP"= "False Pass Airport "
"KGK"= "Koliganek Airport "
"KGX"= "Grayling Airport "
"KKA"= "Koyuk Alfred Adams Airport "
"KKB"= "Kitoi Bay Seaplane Base "
"KKH"= "Kongiganak Airport "
"KLG"= "Kalskag Airport "
"KLL"= "Levelock Airport "
"KLN"= "Larsen Bay Airport "
"KLS"= "Kelso Longview "
"KLW"= "Klawock Airport "
"KMO"= "Manokotak Airport "
"KMY"= "Moser Bay Seaplane Base "
"KNW"= "New Stuyahok Airport "
"KOA"= "Kona Intl At Keahole "
"KOT"= "Kotlik Airport "
"KOY"= "Olga Bay Seaplane Base "
"KOZ"= "Ouzinkie Airport "
"KPB"= "Point Baker Seaplane Base "
"KPC"= "Port Clarence Coast Guard Station "
"KPN"= "Kipnuk Airport "
"KPR"= "Port Williams Seaplane Base "
"KPV"= "Perryville Airport "
"KPY"= "Port Bailey Seaplane Base "
"KQA"= "Akutan Seaplane Base "
"KSM"= "St Marys Airport "
"KTB"= "Thorne Bay Seaplane Base "
"KTN"= "Ketchikan Intl "
"KTS"= "Brevig Mission Airport "
"KUK"= "Kasigluk Airport "
"KVC"= "King Cove Airport "
"KVL"= "Kivalina Airport "
"KWK"= "Kwigillingok Airport "
"KWN"= "Quinhagak Airport "
"KWP"= "West Point Village Seaplane Base "
"KWT"= "Kwethluk Airport "
"KYK"= "Karuluk Airport "
"KYU"= "Koyukuk Airport "
"KZB"= "Zachar Bay Seaplane Base "
"L06"= "Furnace Creek "
"L35"= "Big Bear City "
"LAA"= "Lamar Muni "
"LAF"= "Purude University Airport "
"LAL"= "Lakeland Linder Regional Airport "
"LAM"= "Los Alamos Airport "
"LAN"= "Capital City "
"LAR"= "Laramie Regional Airport "
"LAS"= "Mc Carran Intl "
"LAW"= "Lawton-Fort Sill Regional Airport "
"LAX"= "Los Angeles Intl "
"LBB"= "Lubbock Preston Smith Intl "
"LBE"= "Arnold Palmer Regional Airport "
"LBF"= "North Platte Regional Airport Lee Bird Field "
"LBL"= "Liberal Muni "
"LBT"= "Municipal Airport "
"LCH"= "Lake Charles Rgnl "
"LCK"= "Rickenbacker Intl "
"LCQ"= "Lake City Municipal Airport "
"LDJ"= "Linden Airport "
"LEB"= "Lebanon Municipal Airport "
"LEW"= "Lewiston Maine "
"LEX"= "Blue Grass "
"LFI"= "Langley Afb "
"LFK"= "Angelina Co "
"LFT"= "Lafayette Rgnl "
"LGA"= "La Guardia "
"LGB"= "Long Beach "
"LGC"= "LaGrange-Callaway Airport "
"LGU"= "Logan-Cache "
"LHD"= "Lake Hood Seaplane Base "
"LHV"= "William T. Piper Mem. "
"LHX"= "La Junta Muni "
"LIH"= "Lihue "
"LIT"= "Adams Fld "
"LIV"= "Livingood Airport "
"LKE"= "Kenmore Air Harbor Seaplane Base "
"LKP"= "Lake Placid Airport "
"LMT"= "Klamath Falls Airport "
"LNA"= "Palm Beach Co Park "
"LNK"= "Lincoln "
"LNN"= "Lost Nation Municipal Airport "
"LNR"= "Tri-County Regional Airport "
"LNS"= "Lancaster Airport "
"LNY"= "Lanai "
"LOT"= "Lewis University Airport "
"LOU"= "Bowman Fld "
"LOZ"= "London-Corbin Airport-MaGee Field "
"LPC"= "Lompoc Airport "
"LPR"= "Lorain County Regional Airport "
"LPS"= "Lopez Island Airport "
"LRD"= "Laredo Intl "
"LRF"= "Little Rock Afb "
"LRU"= "Las Cruces Intl "
"LSE"= "La Crosse Municipal "
"LSF"= "Lawson Aaf "
"LSV"= "Nellis Afb "
"LTS"= "Altus Afb "
"LUF"= "Luke Afb "
"LUK"= "Cincinnati Muni Lunken Fld "
"LUP"= "Kalaupapa Airport "
"LUR"= "Cape Lisburne Lrrs "
"LVK"= "Livermore Municipal "
"LVM"= "Mission Field Airport "
"LVS"= "Las Vegas Muni "
"LWA"= "South Haven Area Regional Airport "
"LWB"= "Greenbrier Valley Airport "
"LWC"= "Lawrence Municipal "
"LWM"= "Lawrence Municipal Airport "
"LWS"= "Lewiston Nez Perce Co "
"LWT"= "Lewistown Municipal Airport "
"LXY"= "Mexia - Limestone County Airport "
"LYH"= "Lynchburg Regional Preston Glenn Field "
"LYU"= "Ely Municipal "
"LZU"= "Gwinnett County Airport-Briscoe Field "
"MAE"= "Madera Municipal Airport "
"MAF"= "Midland Intl "
"MBL"= "Manistee County-Blacker Airport "
"MBS"= "Mbs Intl "
"MCC"= "Mc Clellan Afld "
"MCD"= "Mackinac Island Airport "
"MCE"= "Merced Municipal Airport "
"MCF"= "Macdill Afb "
"MCG"= "McGrath Airport "
"MCI"= "Kansas City Intl "
"MCK"= "McCook Regional Airport "
"MCL"= "McKinley National Park Airport "
"MCN"= "Middle Georgia Rgnl "
"MCO"= "Orlando Intl "
"MCW"= "Mason City Municipal "
"MDT"= "Harrisburg Intl "
"MDW"= "Chicago Midway Intl "
"ME5"= "Banks Airport "
"MEI"= "Key Field "
"MEM"= "Memphis Intl "
"MER"= "Castle "
"MFD"= "Mansfield Lahm Regional "
"MFE"= "Mc Allen Miller Intl "
"MFI"= "Marshfield Municipal Airport "
"MFR"= "Rogue Valley Intl Medford "
"MGC"= "Michigan City Municipal Airport "
"MGE"= "Dobbins Arb "
"MGJ"= "Orange County Airport "
"MGM"= "Montgomery Regional Airport "
"MGR"= "Moultrie Municipal Airport "
"MGW"= "Morgantown Muni Walter L Bill Hart Fld "
"MGY"= "Dayton-Wright Brothers Airport "
"MHK"= "Manhattan Reigonal "
"MHM"= "Minchumina Airport "
"MHR"= "Sacramento Mather "
"MHT"= "Manchester Regional Airport "
"MHV"= "Mojave "
"MIA"= "Miami Intl "
"MIB"= "Minot Afb "
"MIE"= "Delaware County Airport "
"MIV"= "Millville Muni "
"MKC"= "Downtown "
"MKE"= "General Mitchell Intl "
"MKG"= "Muskegon County Airport "
"MKK"= "Molokai "
"MKL"= "Mc Kellar Sipes Rgnl "
"MKO"= "Davis Fld "
"MLB"= "Melbourne Intl "
"MLC"= "Mc Alester Rgnl "
"MLD"= "Malad City "
"MLI"= "Quad City Intl "
"MLJ"= "Baldwin County Airport "
"MLL"= "Marshall Don Hunter Sr. Airport "
"MLS"= "Frank Wiley Field "
"MLT"= "Millinocket Muni "
"MLU"= "Monroe Rgnl "
"MLY"= "Manley Hot Springs Airport "
"MMH"= "Mammoth Yosemite Airport "
"MMI"= "McMinn Co "
"MMU"= "Morristown Municipal Airport "
"MMV"= "Mc Minnville Muni "
"MNM"= "Menominee Marinette Twin Co "
"MNT"= "Minto Airport "
"MOB"= "Mobile Rgnl "
"MOD"= "Modesto City Co Harry Sham "
"MOT"= "Minot Intl "
"MOU"= "Mountain Village Airport "
"MPB"= "Miami Seaplane Base "
"MPI"= "MariposaYosemite "
"MPV"= "Edward F Knapp State "
"MQB"= "Macomb Municipal Airport "
"MQT"= "Sawyer International Airport "
"MRB"= "Eastern WV Regional Airport "
"MRI"= "Merrill Fld "
"MRK"= "Marco Islands "
"MRN"= "Foothills Regional Airport "
"MRY"= "Monterey Peninsula "
"MSL"= "Northwest Alabama Regional Airport "
"MSN"= "Dane Co Rgnl Truax Fld "
"MSO"= "Missoula Intl "
"MSP"= "Minneapolis St Paul Intl "
"MSS"= "Massena Intl Richards Fld "
"MSY"= "Louis Armstrong New Orleans Intl "
"MTC"= "Selfridge Angb "
"MTH"= "Florida Keys Marathon Airport "
"MTJ"= "Montrose Regional Airport "
"MTM"= "Metlakatla Seaplane Base "
"MUE"= "Waimea Kohala "
"MUI"= "Muir Aaf "
"MUO"= "Mountain Home Afb "
"MVL"= "Morrisville Stowe State Airport "
"MVY"= "Martha\\'s Vineyard "
"MWA"= "Williamson Country Regional Airport "
"MWC"= "Lawrence J Timmerman Airport "
"MWH"= "Grant Co Intl "
"MWL"= "Mineral Wells "
"MWM"= "Windom Municipal Airport "
"MXF"= "Maxwell Afb "
"MXY"= "McCarthy Airport "
"MYF"= "Montgomery Field "
"MYL"= "McCall Municipal Airport "
"MYR"= "Myrtle Beach Intl "
"MYU"= "Mekoryuk Airport "
"MYV"= "Yuba County Airport "
"MZJ"= "Pinal Airpark "
"N53"= "Stroudsburg-Pocono Airport "
"N69"= "Stormville Airport "
"N87"= "Trenton-Robbinsville Airport "
"NBG"= "New Orleans Nas Jrb "
"NBU"= "Naval Air Station "
"NCN"= "Chenega Bay Airport "
"NEL"= "Lakehurst Naes "
"NFL"= "Fallon Nas "
"NGF"= "Kaneohe Bay Mcaf "
"NGP"= "Corpus Christi NAS "
"NGU"= "Norfolk Ns "
"NGZ"= "NAS Alameda "
"NHK"= "Patuxent River Nas "
"NIB"= "Nikolai Airport "
"NID"= "China Lake Naws "
"NIP"= "Jacksonville Nas "
"NJK"= "El Centro Naf "
"NKT"= "Cherry Point Mcas "
"NKX"= "Miramar Mcas "
"NLC"= "Lemoore Nas "
"NLG"= "Nelson Lagoon "
"NME"= "Nightmute Airport "
"NMM"= "Meridian Nas "
"NNL"= "Nondalton Airport "
"NOW"= "Port Angeles Cgas "
"NPA"= "Pensacola Nas "
"NPZ"= "Porter County Municipal Airport "
"NQA"= "Millington Rgnl Jetport "
"NQI"= "Kingsville Nas "
"NQX"= "Key West Nas "
"NSE"= "Whiting Fld Nas North "
"NTD"= "Point Mugu Nas "
"NTU"= "Oceana Nas "
"NUI"= "Nuiqsut Airport "
"NUL"= "Nulato Airport "
"NUP"= "Nunapitchuk Airport "
"NUQ"= "Moffett Federal Afld "
"NUW"= "Whidbey Island Nas "
"NXP"= "Twentynine Palms Eaf "
"NXX"= "Willow Grove Nas Jrb "
"NY9"= "Long Lake "
"NYC"= "All Airports "
"NYG"= "Quantico Mcaf "
"NZC"= "Cecil Field "
"NZJ"= "El Toro "
"NZY"= "North Island Nas "
"O03"= "Morgantown Airport "
"O27"= "Oakdale Airport "
"OAJ"= "Albert J Ellis "
"OAK"= "Metropolitan Oakland Intl "
"OAR"= "Marina Muni "
"OBE"= "County "
"OBU"= "Kobuk Airport "
"OCA"= "Key Largo "
"OCF"= "International Airport "
"OEB"= "Branch County Memorial Airport "
"OFF"= "Offutt Afb "
"OGG"= "Kahului "
"OGS"= "Ogdensburg Intl "
"OKC"= "Will Rogers World "
"OLF"= "LM Clayton Airport "
"OLH"= "Old Harbor Airport "
"OLM"= "Olympia Regional Airpor "
"OLS"= "Nogales Intl "
"OLV"= "Olive Branch Muni "
"OMA"= "Eppley Afld "
"OME"= "Nome "
"OMN"= "Ormond Beach municipal Airport "
"ONH"= "Oneonta Municipal Airport "
"ONP"= "Newport Municipal Airport "
"ONT"= "Ontario Intl "
"OOK"= "Toksook Bay Airport "
"OPF"= "Opa Locka "
"OQU"= "Quonset State Airport "
"ORD"= "Chicago Ohare Intl "
"ORF"= "Norfolk Intl "
"ORH"= "Worcester Regional Airport "
"ORI"= "Port Lions Airport "
"ORL"= "Executive "
"ORT"= "Northway "
"ORV"= "Robert Curtis Memorial Airport "
"OSC"= "Oscoda Wurtsmith "
"OSH"= "Wittman Regional Airport "
"OSU"= "Ohio State University Airport "
"OTH"= "Southwest Oregon Regional Airport "
"OTS"= "Anacortes Airport "
"OTZ"= "Ralph Wien Mem "
"OWB"= "Owensboro Daviess County Airport "
"OWD"= "Norwood Memorial Airport "
"OXC"= "Waterbury-Oxford Airport "
"OXD"= "Miami University Airport "
"OXR"= "Oxnard - Ventura County "
"OZA"= "Ozona Muni "
"P08"= "Coolidge Municipal Airport "
"P52"= "Cottonwood Airport "
"PAE"= "Snohomish Co "
"PAH"= "Barkley Regional Airport "
"PAM"= "Tyndall Afb "
"PAO"= "Palo Alto Airport of Santa Clara County "
"PAQ"= "Palmer Muni "
"PBF"= "Grider Fld "
"PBG"= "Plattsburgh Intl "
"PBI"= "Palm Beach Intl "
"PBV"= "St George "
"PBX"= "Pike County Airport - Hatcher Field "
"PCW"= "Erie-Ottawa Regional Airport "
"PCZ"= "Waupaca Municipal Airport "
"PDB"= "Pedro Bay Airport "
"PDK"= "Dekalb-Peachtree Airport "
"PDT"= "Eastern Oregon Regional Airport "
"PDX"= "Portland Intl "
"PEC"= "Pelican Seaplane Base "
"PEQ"= "Pecos Municipal Airport "
"PFN"= "Panama City Bay Co Intl "
"PGA"= "Page Municipal Airport "
"PGD"= "Charlotte County-Punta Gorda Airport "
"PGV"= "Pitt-Greenville Airport "
"PHD"= "Harry Clever Field Airport "
"PHF"= "Newport News Williamsburg Intl "
"PHK"= "Pahokee Airport "
"PHL"= "Philadelphia Intl "
"PHN"= "St Clair Co Intl "
"PHO"= "Point Hope Airport "
"PHX"= "Phoenix Sky Harbor Intl "
"PIA"= "Peoria Regional "
"PIB"= "Hattiesburg Laurel Regional Airport "
"PIE"= "St Petersburg Clearwater Intl "
"PIH"= "Pocatello Regional Airport "
"PIM"= "Harris County Airport "
"PIP"= "Pilot Point Airport "
"PIR"= "Pierre Regional Airport "
"PIT"= "Pittsburgh Intl "
"PIZ"= "Point Lay Lrrs "
"PKB"= "Mid-Ohio Valley Regional Airport "
"PLN"= "Pellston Regional Airport of Emmet County Airport "
"PMB"= "Pembina Muni "
"PMD"= "Palmdale Rgnl Usaf Plt 42 "
"PML"= "Port Moller Airport "
"PMP"= "Pompano Beach Airpark "
"PNC"= "Ponca City Rgnl "
"PNE"= "Northeast Philadelphia "
"PNM"= "Princeton Muni "
"PNS"= "Pensacola Rgnl "
"POB"= "Pope Field "
"POC"= "Brackett Field "
"POE"= "Polk Aaf "
"POF"= "Poplar Bluff Municipal Airport "
"PPC"= "Prospect Creek Airport "
"PPV"= "Port Protection Seaplane Base "
"PQI"= "Northern Maine Rgnl At Presque Isle "
"PQS"= "Pilot Station Airport "
"PRC"= "Ernest A Love Fld "
"PSC"= "Tri Cities Airport "
"PSG"= "Petersburg James A. Johnson "
"PSM"= "Pease International Tradeport "
"PSP"= "Palm Springs Intl "
"PSX"= "Palacios Muni "
"PTB"= "Dinwiddie County Airport "
"PTH"= "Port Heiden Airport "
"PTK"= "Oakland Co. Intl "
"PTU"= "Platinum "
"PUB"= "Pueblo Memorial "
"PUC"= "Carbon County Regional-Buck Davis Field "
"PUW"= "Pullman-Moscow Rgnl "
"PVC"= "Provincetown Muni "
"PVD"= "Theodore Francis Green State "
"PVU"= "Provo Municipal Airport "
"PWK"= "Chicago Executive "
"PWM"= "Portland Intl Jetport "
"PWT"= "Bremerton National "
"PYM"= "Plymouth Municipal Airport "
"PYP"= "Centre-Piedmont-Cherokee County Regional Airport "
"R49"= "Ferry County Airport "
"RAC"= "John H. Batten Airport "
"RAL"= "Riverside Muni "
"RAP"= "Rapid City Regional Airport "
"RBD"= "Dallas Executive Airport "
"RBK"= "French Valley Airport "
"RBM"= "Robinson Aaf "
"RBN"= "Fort Jefferson "
"RBY"= "Ruby Airport "
"RCA"= "Ellsworth Afb "
"RCE"= "Roche Harbor Seaplane Base "
"RCZ"= "Richmond County Airport "
"RDD"= "Redding Muni "
"RDG"= "Reading Regional Carl A Spaatz Field "
"RDM"= "Roberts Fld "
"RDR"= "Grand Forks Afb "
"RDU"= "Raleigh Durham Intl "
"RDV"= "Red Devil Airport "
"REI"= "Redlands Municipal Airport "
"RFD"= "Chicago Rockford International Airport "
"RHI"= "Rhinelander Oneida County Airport "
"RIC"= "Richmond Intl "
"RID"= "Richmond Municipal Airport "
"RIF"= "Richfield Minicipal Airport "
"RIL"= "Garfield County Regional Airport "
"RIR"= "Flabob Airport "
"RIU"= "Rancho Murieta "
"RIV"= "March Arb "
"RIW"= "Riverton Regional "
"RKD"= "Knox County Regional Airport "
"RKH"= "Rock Hill York Co Bryant Airport "
"RKP"= "Aransas County Airport "
"RKS"= "Rock Springs Sweetwater County Airport "
"RME"= "Griffiss Afld "
"RMG"= "Richard B Russell Airport "
"RMP"= "Rampart Airport "
"RMY"= "Brooks Field Airport "
"RND"= "Randolph Afb "
"RNM"= "Ramona Airport "
"RNO"= "Reno Tahoe Intl "
"RNT"= "Renton "
"ROA"= "Roanoke Regional "
"ROC"= "Greater Rochester Intl "
"ROW"= "Roswell Intl Air Center "
"RSH"= "Russian Mission Airport "
"RSJ"= "Rosario Seaplane Base "
"RST"= "Rochester "
"RSW"= "Southwest Florida Intl "
"RUT"= "Rutland State Airport "
"RVS"= "Richard Lloyd Jones Jr Airport "
"RWI"= "Rocky Mount Wilson Regional Airport "
"RWL"= "Rawlins Municipal Airport-Harvey Field "
"RYY"= "Cobb County Airport-Mc Collum Field "
"S46"= "Port O\\'Connor Airfield "
"SAA"= "Shively Field Airport "
"SAC"= "Sacramento Executive "
"SAD"= "Safford Regional Airport "
"SAF"= "Santa Fe Muni "
"SAN"= "San Diego Intl "
"SAT"= "San Antonio Intl "
"SAV"= "Savannah Hilton Head Intl "
"SBA"= "Santa Barbara Muni "
"SBD"= "San Bernardino International Airport "
"SBM"= "Sheboygan County Memorial Airport "
"SBN"= "South Bend Rgnl "
"SBO"= "Emanuel Co "
"SBP"= "San Luis County Regional Airport "
"SBS"= "Steamboat Springs Airport-Bob Adams Field "
"SBY"= "Salisbury Ocean City Wicomico Rgnl "
"SCC"= "Deadhorse "
"SCE"= "University Park Airport "
"SCH"= "Stratton ANGB - Schenectady County Airpor "
"SCK"= "Stockton Metropolitan "
"SCM"= "Scammon Bay Airport "
"SDC"= "Williamson-Sodus Airport "
"SDF"= "Louisville International Airport "
"SDM"= "Brown Field Municipal Airport "
"SDP"= "Sand Point Airport "
"SDX"= "Sedona "
"SDY"= "Sidney-Richland Municipal Airport "
"SEA"= "Seattle Tacoma Intl "
"SEE"= "Gillespie "
"SEF"= "Regional - Hendricks AAF "
"SEM"= "Craig Fld "
"SES"= "Selfield Airport "
"SFB"= "Orlando Sanford Intl "
"SFF"= "Felts Fld "
"SFM"= "Sanford Regional "
"SFO"= "San Francisco Intl "
"SFZ"= "North Central State "
"SGF"= "Springfield Branson Natl "
"SGH"= "Springfield-Beckly Municipal Airport "
"SGJ"= "St. Augustine Airport "
"SGR"= "Sugar Land Regional Airport "
"SGU"= "St George Muni "
"SGY"= "Skagway Airport "
"SHD"= "Shenandoah Valley Regional Airport "
"SHG"= "Shungnak Airport "
"SHH"= "Shishmaref Airport "
"SHR"= "Sheridan County Airport "
"SHV"= "Shreveport Rgnl "
"SHX"= "Shageluk Airport "
"SIK"= "Sikeston Memorial Municipal "
"SIT"= "Sitka Rocky Gutierrez "
"SJC"= "Norman Y Mineta San Jose Intl "
"SJT"= "San Angelo Rgnl Mathis Fld "
"SKA"= "Fairchild Afb "
"SKF"= "Lackland Afb Kelly Fld Annex "
"SKK"= "Shaktoolik Airport "
"SKY"= "Griffing Sandusky "
"SLC"= "Salt Lake City Intl "
"SLE"= "McNary Field "
"SLK"= "Adirondack Regional Airport "
"SLN"= "Salina Municipal Airport "
"SLQ"= "Sleetmute Airport "
"SMD"= "Smith Fld "
"SME"= "Lake Cumberland Regional Airport "
"SMF"= "Sacramento Intl "
"SMK"= "St. Michael Airport "
"SMN"= "Lemhi County Airport "
"SMO"= "Santa Monica Municipal Airport "
"SMX"= "Santa Maria Pub Cpt G Allan Hancock Airport "
"SNA"= "John Wayne Arpt Orange Co "
"SNP"= "St Paul Island "
"SNY"= "Sidney Muni Airport "
"SOP"= "Moore County Airport "
"SOW"= "Show Low Regional Airport "
"SPB"= "Scappoose Industrial Airpark "
"SPF"= "Black Hills Airport-Clyde Ice Field "
"SPG"= "Albert Whitted "
"SPI"= "Abraham Lincoln Capital "
"SPS"= "Sheppard Afb Wichita Falls Muni "
"SPW"= "Spencer Muni "
"SPZ"= "Silver Springs Airport "
"SQL"= "San Carlos Airport "
"SRQ"= "Sarasota Bradenton Intl "
"SRR"= "Sierra Blanca Regional Airport "
"SRV"= "Stony River 2 Airport "
"SSC"= "Shaw Afb "
"SSI"= "McKinnon Airport "
"STC"= "Saint Cloud Regional Airport "
"STE"= "Stevens Point Municipal Airport "
"STG"= "St. George Airport "
"STJ"= "Rosecrans Mem "
"STK"= "Sterling Municipal Airport "
"STL"= "Lambert St Louis Intl "
"STS"= "Charles M Schulz Sonoma Co "
"SUA"= "Witham Field Airport "
"SUE"= "Door County Cherryland Airport "
"SUN"= "Friedman Mem "
"SUS"= "Spirit Of St Louis "
"SUU"= "Travis Afb "
"SUX"= "Sioux Gateway Col Bud Day Fld "
"SVA"= "Savoonga Airport "
"SVC"= "Grant County Airport "
"SVH"= "Regional Airport "
"SVN"= "Hunter Aaf "
"SVW"= "Sparrevohn Lrrs "
"SWD"= "Seward Airport "
"SWF"= "Stewart Intl "
"SXP"= "Sheldon Point Airport "
"SXQ"= "Soldotna Airport "
"SYA"= "Eareckson As "
"SYB"= "Seal Bay Seaplane Base "
"SYR"= "Syracuse Hancock Intl "
"SZL"= "Whiteman Afb "
"TAL"= "Tanana Airport "
"TAN"= "Taunton Municipal Airport - King Field "
"TBN"= "Waynesville Rgnl Arpt At Forney Fld "
"TCC"= "Tucumcari Muni "
"TCL"= "Tuscaloosa Rgnl "
"TCM"= "Mc Chord Afb "
"TCS"= "Truth Or Consequences Muni "
"TCT"= "Takotna Airport "
"TEB"= "Teterboro "
"TEK"= "Tatitlek Airport "
"TEX"= "Telluride "
"TIK"= "Tinker Afb "
"TIW"= "Tacoma Narrows Airport "
"TKA"= "Talkeetna "
"TKE"= "Tenakee Seaplane Base "
"TKF"= "Truckee-Tahoe Airport "
"TKI"= "Collin County Regional Airport at Mc Kinney "
"TLA"= "Teller Airport "
"TLH"= "Tallahassee Rgnl "
"TLJ"= "Tatalina Lrrs "
"TLT"= "Tuluksak Airport "
"TMA"= "Henry Tift Myers Airport "
"TMB"= "Kendall Tamiami Executive "
"TNC"= "Tin City LRRS Airport "
"TNK"= "Tununak Airport "
"TNT"= "Dade Collier Training And Transition "
"TNX"= "Tonopah Test Range "
"TOA"= "Zamperini Field Airport "
"TOC"= "Toccoa RG Letourneau Field Airport "
"TOG"= "Togiak Airport "
"TOL"= "Toledo "
"TOP"= "Philip Billard Muni "
"TPA"= "Tampa Intl "
"TPL"= "Draughon Miller Central Texas Rgnl "
"TRI"= "Tri-Cities Regional Airport "
"TRM"= "Jacqueline Cochran Regional Airport "
"TSS"= "East 34th Street Heliport "
"TTD"= "Portland Troutdale "
"TTN"= "Trenton Mercer "
"TUL"= "Tulsa Intl "
"TUP"= "Tupelo Regional Airport "
"TUS"= "Tucson Intl "
"TVC"= "Cherry Capital Airport "
"TVF"= "Thief River Falls "
"TVI"= "Thomasville Regional Airport "
"TVL"= "Lake Tahoe Airport "
"TWA"= "Twin Hills Airport "
"TWD"= "Jefferson County Intl "
"TWF"= "Magic Valley Regional Airport "
"TXK"= "Texarkana Rgnl Webb Fld "
"TYE"= "Tyonek Airport "
"TYR"= "Tyler Pounds Rgnl "
"TYS"= "Mc Ghee Tyson "
"U76"= "Mountain Home Municipal Airport "
"UDD"= "Bermuda Dunes Airport "
"UDG"= "Darlington County Jetport "
"UES"= "Waukesha County Airport "
"UGN"= "Waukegan Rgnl "
"UIN"= "Quincy Regional Baldwin Field "
"UMP"= "Indianapolis Metropolitan Airport "
"UNK"= "Unalakleet Airport "
"UPP"= "Upolu "
"UST"= "St. Augustine Airport "
"UTM"= "Tunica Municipal Airport "
"UTO"= "Indian Mountain Lrrs "
"UUK"= "Ugnu-Kuparuk Airport "
"UUU"= "Newport State "
"UVA"= "Garner Field "
"VAD"= "Moody Afb "
"VAK"= "Chevak Airport "
"VAY"= "South Jersey Regional Airport "
"VBG"= "Vandenberg Afb "
"VCT"= "Victoria Regional Airport "
"VCV"= "Southern California Logistics "
"VDF"= "Tampa Executive Airport "
"VDZ"= "Valdez Pioneer Fld "
"VEE"= "Venetie Airport "
"VEL"= "Vernal Regional Airport "
"VGT"= "North Las Vegas Airport "
"VIS"= "Visalia Municipal Airport "
"VLD"= "Valdosta Regional Airport "
"VNW"= "Van Wert County Airport "
"VNY"= "Van Nuys "
"VOK"= "Volk Fld "
"VPC"= "Cartersville Airport "
"VPS"= "Eglin Afb "
"VRB"= "Vero Beach Muni "
"VSF"= "Hartness State "
"VYS"= "Illinois Valley Regional "
"W13"= "Eagle's Nest Airport "
"WAA"= "Wales Airport "
"WAL"= "Wallops Flight Facility "
"WAS"= "All Airports "
"WBB"= "Stebbins Airport "
"WBQ"= "Beaver Airport "
"WBU"= "Boulder Municipal "
"WBW"= "Wilkes-Barre Wyoming Valley Airport "
"WDR"= "Barrow County Airport "
"WFB"= "Ketchikan harbor Seaplane Base "
"WFK"= "Northern Aroostook Regional Airport "
"WHD"= "Hyder Seaplane Base "
"WHP"= "Whiteman Airport "
"WIH"= "Wishram Amtrak Station "
"WKK"= "Aleknagik Airport "
"WKL"= "Waikoloa Heliport "
"WLK"= "Selawik Airport "
"WMO"= "White Mountain Airport "
"WRB"= "Robins Afb "
"WRG"= "Wrangell Airport "
"WRI"= "Mc Guire Afb "
"WRL"= "Worland Municipal Airport "
"WSD"= "Condron Aaf "
"WSJ"= "San Juan - Uganik Seaplane Base "
"WSN"= "South Naknek Airport "
"WST"= "Westerly State Airport "
"WSX"= "Westsound Seaplane Base "
"WTK"= "Noatak Airport "
"WTL"= "Tuntutuliak Airport "
"WWD"= "Cape May Co "
"WWP"= "North Whale Seaplane Base "
"WWT"= "Newtok Airport "
"WYS"= "Yellowstone Airport "
"X01"= "Everglades Airpark "
"X07"= "Lake Wales Municipal Airport "
"X21"= "Arthur Dunn Airpark "
"X39"= "Tampa North Aero Park "
"X49"= "South Lakeland Airport "
"XFL"= "Flagler County Airport "
"XNA"= "NW Arkansas Regional "
"XZK"= "Amherst Amtrak Station AMM "
"Y51"= "Municipal Airport "
"Y72"= "Bloyer Field "
"YAK"= "Yakutat "
"YIP"= "Willow Run "
"YKM"= "Yakima Air Terminal McAllister Field "
"YKN"= "Chan Gurney "
"YNG"= "Youngstown Warren Rgnl "
"YUM"= "Yuma Mcas Yuma Intl "
"Z84"= "Clear "
"ZBP"= "Penn Station "
"ZFV"= "Philadelphia 30th St Station "
"ZPH"= "Municipal Airport "
"ZRA"= "Atlantic City Rail Terminal "
"ZRD"= "Train Station "
"ZRP"= "Newark Penn Station "
"ZRT"= "Hartford Union Station "
"ZRZ"= "New Carrollton Rail Station "
"ZSF"= "Springfield Amtrak Station "
"ZSY"= "Scottsdale Airport "
"ZTF"= "Stamford Amtrak Station "
"ZTY"= "Boston Back Bay Station "
"ZUN"= "Black Rock "
"ZVE"= "New Haven Rail Station "
"ZWI"= "Wilmington Amtrak Station "
"ZWU"= "Washington Union Station "
"ZYP"= "Penn Station "
;
run;

/********************** Exploring the Data ******************************/
/******** QUESTION 5*/
data flights1;
set flights;
format origin airportname. dest airportname.;
route=origin||" "||dest;
run;

/************ QUESTION-5 (A) *******************/
proc freq data=flights1 order=freq;
table route;
by year;
run;
/********** QUESTION 5 (B) *******/
proc sql;
CREATE TABLE QUESTION6 AS
select route, count(flight) as no_of_flights,carrier from flights1
where route in ("JFK LAX","LGA ATL"	,"LGA ORD"	,"JFK SFO"	,"LGA CLT") 
group by carrier, route;
quit;


/**************** QUESTION 6 (A) ******************/
proc sql;
create table question6A as
select hour,count(flight) as noofflights,carrier
from flights
group by carrier,hour;
run;

proc sql;
create table question6B as
select hour1,count(flight) as noofflights1,carrier
from flights
group by carrier,hour1;
run;

proc sql;
create table joined2 as
select question6A.*,question6B.* from question6A left join question6B on
question6A.carrier=question6B.carrier and question6A.hour=question6B.hour1 ;
quit;

data joined2;
set joined2;
total_flights=noofflights+noofflights1;   
drop noofflights noofflights1;
run;
/**************** QUESTION 6 (B) ******************/

proc sql;
create table question6B1 as
select hour,count(flight) as noofflights,carrier
from flights
where dest in ("JFK","LGA","EWR")
group by carrier,hour;
run;

proc sql;
create table question6B2 as
select hour1,count(flight) as noofflights1,carrier
from flights
where dest in ("JFK","LGA","EWR")
group by carrier,hour1;
run;

proc sql;
create table joined3 as
select question6B1.*,question6B2.* from question6A1 left join question6B2 on
question6A1.carrier=question6B2.carrier and question6A1.hour=question6B2.hour1 ;
quit;

data joined3;
set joined3;
total_flights=noofflights+noofflights1;   /****GIVES THE BUSIEST TIME GROUPED BY EACH CARRIER *******/ 
drop noofflights noofflights1;
run;


proc sql;
create table question6ABC as
select hour,count(flight) as noofflights,carrier
from flights
group by carrier,hour;
run;


/*************** 	QUESTION 7 (a)******************/
PROC SQL;
SELECT COUNT(dep_DELAY) AS TOTAL_COUNT, 
SUM(CASE WHEN dep_DELAY>0 THEN 1 ELSE 0 END) as count, ((calculated count)/(calculated total_count)*100) as percentage
FROM FLIGHTS
WHERE origin='JFK';
QUIT;
/************* QUESTION 7 (B) ******************************/
PROC SQL;
SELECT origin,COUNT(dep_DELAY) AS TOTAL_COUNT, 
SUM(CASE WHEN dep_DELAY>0 THEN 1 ELSE 0 END) as count, ((calculated count)/(calculated total_count)*100) as percentage
FROM FLIGHTS
group by origin;
QUIT;
/************* QUESTION 7 (C) ******************************/
PROC SQL;
SELECT dest,COUNT(arr_DELAY) AS TOTAL_COUNT, 
SUM(CASE WHEN arr_DELAY>0 THEN 1 ELSE 0 END) as count, ((calculated count)/(calculated total_count)*100) as percentage
FROM FLIGHTS
group by dest;
QUIT;


/***************** Question 8-(b) *************************/
data joined;
set joined;
temp1=input(temp,best12.);
dewp1=input(dewp,best12.);
humid1=input(humid,best12.);
wind_dir1=input(wind_dir,best12.);
wind_speed1=input(wind_speed,best12.);
wind_gust1=input(wind_gust,best12.);
pressure1=input(pressure,best12.);
run;

data joined;
set joined;
drop temp dewp humid wind_dir wind_speed wind_gust pressure;
rename temp1=temp dewp1=dewp humid1=humid wind_dir1=wind_dir wind_speed1=wind_speed wind_gust1=wind_gust pressure1=pressure;
run;

/************************* Comparing the weather variables with the departure delay **************************/
proc sql;
select mean(dep_delay) as Departure_Delay, mean(temp) as avg_temp, mean(dewp) as avg_dewp,
mean(humid) as avg_humidity, mean(wind_dir) as avg_wind_dir, mean(wind_speed) as avg_windspeed,
mean(wind_gust) as avg_wind_gust
from joined
group by month;
quit;



/*********** QUESTION-9 Relationship between fuel and manufacturing year ********************/
/*********** Older planes do consume more fuel as it can be seen in the result, less no. of planes were
manufactured but the fuel consumption was high, whereas in the years that follow, more planes were manufactured
and the consumption was less. I also notice a deviation in the years 2011,2012,2013-less planes, huge fuel
consumption*********/

proc sql;
select manufacturing_year, mean(fuel_cc) as Average, count(plane)
from planes
group by manufacturing_year;
quit;
/********************* QUESTION-9(b) ***************************/
proc sql;
select manufacturing_year,  engine, engines, mean(fuel_cc) as Average, 
from planes
group by manufacturing_year, engine, engines;
quit;

/************************* Question 10 *******************************/
/*************** Delays increase till from 5AM to 8PM and then starts to decrease again after 8 PM ****/
proc sql;
select hour,  mean(dep_delay) as avg_delay 
from flights
group by hour;
quit;







































