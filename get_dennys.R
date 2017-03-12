get_url = function(limit, zip_code, radius)
{
  paste0(
    "https://hosted.where2getit.com/dennys/responsive/ajax?&xml_request=%3Crequest%3E%3Cappkey%3E6B962D40-03BA-11E5-BC31-9A51842CA48B%3C%2Fappkey%3E%3Cformdata+id%3D%22locatorsearch%22%3E%3Cdataview%3Estore_default%3C%2Fdataview%3E%3Climit%3E",
    limit,"%3C%2Flimit%3E%3Corder%3Erank%2C_distance%3C%2Forder%3E%3Cgeolocs%3E%3Cgeoloc%3E%3Caddressline%3E",
    zip_code,
    "%3C%2Faddressline%3E%3Clongitude%3E%3C%2Flongitude%3E%3Clatitude%3E%3C%2Flatitude%3E%3Ccountry%3EUS%3C%2Fcountry%3E%3C%2Fgeoloc%3E%3C%2Fgeolocs%3E%3Cstateonly%3E1%3C%2Fstateonly%3E%3Csearchradius%3E",
    radius,
    "%3C%2Fsearchradius%3E%3C%2Fformdata%3E%3C%2Frequest%3E"
  )
}


# We start from the Salt Lake City in Utah, which locates in the middle west of United States.
# We parse dennys that are located in the 5000 miles circle around the city. 

# Next, we focus on dennys on the eastern United States. We choose Washtington DC as our center and 
# parse dennys in 5000 radius around it. 

# Lastly, we parse dennys in Alaska and Hawaii by centering around Fairbank of
# Alaska and Kailua-kona of Hawaii. We choose the radius as 500 miles for these 2 cases.  

# These 4 xml files give us dennys in DC and 50 states of United States, but we accidentally have
# dennys outside of the United States. After removing these dennys and also duplicates, 
# we get all of the distinct dennys in the US. 


# Salt Lake City, Utah
UT = get_url(limit = 1000, zip_code = "84101", radius = 5000)

# Washington DC
DC = get_url(limit = 1000, zip_code = "20019", radius = 5000 )

# Fairbanks, Alaska
AK = get_url(limit = 100, zip_code = "99701", radius = 500)

# Kailua-kona, Hawaii
HI = get_url(limit = 100, zip_code = "96740", radius = 500)

dir.create("data/dennys",recursive = TRUE, showWarnings = FALSE)

download.file(UT, dest="data/dennys/UT.xml")
download.file(DC, dest="data/dennys/DC.xml")
download.file(AK, dest="data/dennys/AK.xml")
download.file(HI, dest="data/dennys/HI.xml")
