library(stringr)
library(rvest)
library(dplyr)
library(methods)

# get file names from data/dennys
files = dir("data/dennys/", "xml", full.names = TRUE)

res = list()
for (i in seq_along(files))
{
     file = read_xml(files[i])
  
     # parse address
     address1 = file %>% 
       html_nodes("address1") %>%
       html_text()
     address2 = file %>%
       html_nodes("address2") %>%
       html_text()
     
     # parse city
     city = file %>%
       html_nodes("city") %>%
       html_text()
     
     # parse state
     state = file %>%
       html_nodes("state") %>%
       html_text()
     
     # parse zip code
     zip_code = file %>%
       html_nodes("postalcode") %>%
       html_text()
     
     # parse phone number
     phone = file %>%
       html_nodes("phone") %>%
       html_text()
     
     # parse latitude 
      lat = file %>%
       html_nodes("latitude") %>%
       html_text()
      
     # parse longitude
      lon = file %>%
        html_nodes("longitude") %>%
        html_text()
  
   res[[i]] = data_frame(
    address = paste(address1, address2) %>% str_trim(),
    city = city, 
    state = state,
    zip_code = zip_code,
    phone   = phone,
    lat   = lat,
    long  = lon)
}

# combine res into a data frame
dennys = bind_rows(res)

# drop dennys with no state (dennys not in US)
dennys = dennys %>% filter(state != "")

# remove duplicate dennys
dennys = unique(dennys)

# save file
dir.create("data/",showWarnings = FALSE)
save(dennys, file="data/dennys.Rdata")
