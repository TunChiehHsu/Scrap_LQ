

```{r}
load("data/dennys.Rdata")
load("data/lq.Rdata")

```

## Scraping La Quinta

## *Detail*
1. get_lq: We created a directory `lq`, and used the absolute address to download each La Quinta hotel’s HTML file. 

2. parse_lq: First, we retrieve all the paths of from `lq` folder and save them to `files`, then create an empty list `res`.

3. Further, we construct a for-loop to run through all the paths in `files` and use the function `read_html` to obtain the information. We then select the address, phone, and fax number, number of rooms, floors, suites, latitude and longitude as the features and extract these information by using the function `html_nodes`. Notice that different feature has different format, some transformation and string regulation are necessary. After each iteration, we define `res` as a dataframe that contain the extracted information. 

4. After the loop, we use `bind_rows` to combine `res` into a data frame. We then start the tidying part. We start from spliting address into street address, state code, and zip code by using `str_split`. Then we filter out the data that is not in US. First, we get rid of the data that the phone number in which is not start with 1 (Telephone country code for US & Canada). Fruther, we try to filter out the data in Canada. We foung that the zip code for Canada has capital letters in it so we use this clue to remove lq in Canada. After all, rename the feature and get rid of the unnecessary variables, we get the final dataframe. 


## Scraping Denny’s
## *Detail*
1. get_dennys: Scraping the Denny’s site relies on a 3rd party service to display its locations.Thus, we first create a function `get_url` that we can careate the html path for seaching all the restaruant by specific limit, zip_code and radius.

2. We start from the Salt Lake City in Utah, which locates in the middle west of United States. We parse dennys that are located in the 5000 miles circle around the city. 
Next, we focus on dennys on the eastern United States. We choose Washtington DC as our center and parse dennys in 5000 radius around it. 
Lastly, we parse dennys in Alaska and Hawaii by centering around Fairbank of Alaska and Kailua-kona of Hawaii. We choose the radius as 500 miles for these 2 cases.  
These 4 xml files give us dennys in DC and 50 states of United States, but we accidentally have dennys outside of the United States. After removing these dennys and the duplicates, we get all of the distinct dennys in the US. 

3. parse_dennys: We use the technique that is similar to parselq to parse the information from denny's website. However, in the tidying part, we filter out the country that is not in US by deleting the data in which the `state` is blank.  


## Task 3 - Distance Analysis

## *Detail*
1. Calculating distance: 
    + We want to know how far away is each denny's to each La Quinta. So we use 2 for-loop to go through every denny's for each La Quinta. Then we use a package called `geosphere` to calculate the distance between them. The strategy we used here is to find out the nearest denny's for each La Quinta, so we calculate the minimum value of all the distances of every denny's to that one particular La Quinta in the inner for-loop. And the outer loop garuantee us a list of those minimum values, which represents distances from La Quinta to its nearest Denny's.

2. Analysis/Results: 
    + We decided to draw a histogram to show the results, and we found out that it's a left skewness shape, which means most La Quinta do have a relatively close Denny's. But when we narrow down the value that represents "next to" to 5 miles, there're 60% of La Quinta satisfy this condtion and when we narrow down it further to a quarter mile, the percentage is quite low. Thus we have a conclusion here that the claim might not be true. 
    
``` {r}
install.packages("geosphere", repos = "https://cran.r-project.org/")
library(geosphere)

#get numerical form of latitude and longtitude of lq and dennys
lat_lq = as.numeric(unlist(lq$lat))
long_lq = as.numeric(unlist(lq$long))
lat_den = as.numeric(unlist(dennys$lat))
long_den = as.numeric(unlist(dennys$long))


#find the minimum distance of the dennys to each la quinta
min_dist = NULL
for (l in 1:length(lat_lq)) {
  dist = NULL
  for (d in 1:length(lat_den)) {
    
    # havershine method to calculate distance
    # without using any package
    # R = 6371000 
    # lat1 = lat_lq[l] * 180 / pi
    # lat2 = lat_den[d] * 180 / pi
    # long1 = long_lq[l] * 180 / pi
    # long2 = long_den[d] * 180 / pi
    # dellat = lat2 - lat1
    # dellong = long2 - long1
    # a = sin(dellat/2) * sin(dellat/2) + cos(lat2) * cos(lat1) * sin(dellong/2) * sin(dellong/2)
    # a1 = sqrt(a)
    # a2 = sqrt(1-a)
    # c = 2 * atan2(a1, a2)
    # dis_temp   = R * c
    
    # havershine with package
    dis_temp = distm(c(long_den[d], lat_den[d]), c(long_lq[l], lat_lq[l]), fun = distHaversine)
    dist = c(dist,dis_temp)
  }
  min_temp = min(dist)
  min_dist = c(min_dist,min_temp)
}

# convert m to mile
min_dist = min_dist / 1000 / 1.60934

#plot
hist(min_dist)

# Let's say 5 miles is a good representation of "next to"
# as usually 5 mile is the distance between two exits of highway
# we can see there's 60% of la quinta have a denny's next to them
percentage = sum(min_dist < 5) / length(min_dist)


# However, if we use Reiser's definition where next to is about less than a quarter mile, then the percentage is quite low
percentages =  sum(min_dist < 0.25) / length(min_dist)
```

