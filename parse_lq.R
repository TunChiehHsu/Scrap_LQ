library(rvest)
library(stringr)
library(tibble)
library(dplyr)
library(tidyr)

# read file names 
files = dir("data/lq/", "html", full.names = TRUE)

res = list()

for(i in seq_along(files))
{
  file = files[i]
  
  page = read_html(file)
  
  # parse location name 
  location_name = page %>%
    html_nodes("h1") %>%
    html_text()
  
  # parse address, phone, and fax number 
  hotel_info = page %>% 
    html_nodes(".hotelDetailsBasicInfoTitle p") %>%
    html_text() %>% 
    str_split("\n") %>% 
    .[[1]] %>% 
    str_trim() %>%
    .[. != ""]
  
  # Google link includes latitude first then longitude
  lat_long = page %>%
    html_nodes(".minimap") %>%
    html_attr("src") %>%
    str_match("\\|(-?[0-9]{1,2}\\.[0-9]+),(-?[0-9]{1,3}\\.[0-9]+)&")
  
  # parse number of rooms
  n_rooms = page %>% 
    html_nodes(".hotelFeatureList li:nth-child(2)") %>%
    html_text() %>%
    str_trim() %>%
    str_replace("Rooms: ", "") %>%
    as.integer()
  
  # parse floors
  floors = page %>%
    html_nodes(".hotelFeatureList li:nth-child(1)") %>%
    html_text() %>%
    str_trim() %>%
    str_replace("Floors: ", "") %>%
    as.integer()
  
  # parse suites
  suites = page %>%
    html_nodes(".hotelFeatureList li:nth-child(3)") %>%
    html_text() %>%
    str_trim() %>%
    str_replace("Suites: ", "") %>%
    as.integer()
  
  
  # create data frame for each lq
  res[[i]] = data_frame(
    location_name = location_name,
    address = paste(hotel_info[1:2],collapse="\n"),
    phone = hotel_info[3] %>% str_replace("Phone: ", ""), 
    fax   = hotel_info[4] %>% str_replace("Fax: ", ""),
    lat   = lat_long[,2],
    long  = lat_long[,3],
    n_rooms = n_rooms,
    floors = floors
  )

}

# combine res into a data frame
lq = bind_rows(res)

# split address into street address, state code, and zip code
lq = lq %>% 
  mutate(Address = 0) %>%
  mutate(City_zip = 0)

for(i in seq_along(lq$address)){
  lq$Address[i] = unlist(str_split(lq$address[i], ",\n", n = 2))[1]
  lq$City_zip[i] = unlist(str_split(lq$address[i], ",\n", n = 2))[2]
}

lq = lq %>% 
  separate(City_zip, c("City","State"), sep = "\\,", remove=TRUE)

statecode = matrix(NA, length(lq$State),1)  
zip = matrix(NA, length(lq$State),1)  
for(i in 1:length(lq$State))
{
  d = lq$State[i]
  statecode[i,1] = strsplit(d, " ")[[1]][2]
  zip[i,1] = strsplit(d, " ")[[1]][3]
}
lq = cbind(lq, statecode, zip)

# use phone number to select us hotels
phones = lq %>%
  select(phone)

index = NULL
for (i in 1:nrow(phones)) {
  phone_n = phones[i,1]
  country_n = substring(phone_n,1,1)
  if (country_n != 1) {
    index = c(index,i)
  }
}

lq = lq[-index,]

# zip code for Canada has capital letters in it. 
# we use this clue to remove lq in Canada.
lq = lq[is.na(str_match(lq$zip, "[A-Z]")),]

# drop unnecessary variables
lq = lq %>% select(-c(address, State))

# rename variables
lq = lq %>% rename(address = Address, city = City, state = statecode)


# save lq.Rdata
dir.create("data/",showWarnings = FALSE)
save(lq, file="data/lq.Rdata")
