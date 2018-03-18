# Eurostat into ELK

This is a project to get data from [Eurostat](http://ec.europa.eu/eurostat/de/data/database) into an Elastic Stack (Elasticsearch, Logstash and Kibana). First, we will create "tidy" csv tables, then we ask the logstash csv input to push them to elasticsearch. Then we can create visualizations in Kibana.

## First, get the data:

To know which eurostat data source to use, check out http://htmlpreview.github.io/?https://github.com/muc-fluechtlingsrat/r-eurostat-refugees/blob/master/man/eurostat_asylum_data_sources.html

Let's work with the annual application data. For [migr_asyappctza](http://appsso.eurostat.ec.europa.eu/nui/show.do?wai=true&dataset=migr_asyappctza), in full: *Asylum and first time asylum applicants by citizenship, age and sex Annual aggregated data (rounded)*,  you get the data like this:

    wget -O migr_asyappctza.tsv.gz http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/migr_asyappctza.tsv.gz

and gunzip it. You get 450105 rows of mixed comma and tab seperated values - it's some kind of pivot table. Null values are represented by ":".
This is how your data looks like:

    citizen,sex,unit,age,asyl_app,geo\time	2016 	2015 	2014 	2013 	2012 	2011 	2010 	2009 	2008 
    AD,F,PER,TOTAL,ASY_APP,AT	0 	0 	0 	0 	0 	0 	0 	0 	0 
    AD,F,PER,TOTAL,ASY_APP,BE	0 	0 	0 	0 	0 	0 	0 	0 	0 
    AD,F,PER,TOTAL,ASY_APP,BG	0 	0 	0 	0 	0 	0 	0 	0 	0 
    AD,F,PER,TOTAL,ASY_APP,CH	0 	0 	0 	0 	0 	0 	0 	0 	0 

## Transform the data

For human readability, this is quite nice, but it's not useful for creating charts in Kibana. @mitmirzutun wrote this php script to transform the data: https://github.com/mitmirzutun/PHP/blob/master/clear.php, which gets us

    citizen,sex,unit,age,asyl_app,geo,time,amount
    AD,F,PER,TOTAL,ASY_APP,AT,2016,0 
    AD,F,PER,TOTAL,ASY_APP,AT,2015,0 
    AD,F,PER,TOTAL,ASY_APP,AT,2014,0 
    AD,F,PER,TOTAL,ASY_APP,AT,2013,0 
    
Better. Unfortunately, the resulting csv file is too big to upload to github.
To get it into elasticsearch, use a logstash configuration like [logstash_configs/bamf_data.conf] . 

## What's in your data

The explanations of the dimensions are here:
https://www.econdb.com/dataset/MIGR_ASYAPPCTZA/asylum-and-first-time-asylum-applicants-by-citizenship-age-and-sex-annual-aggregated-data-rounded/

### Null Values
We have about 13% null values, where the country of application didn't provide numbers. They were denoted by ":" in the original data, which was replaced by "N/A" by the php script. Either way, it's not an integer, and will be refused by elasticsearch. 
***Caution:*** In the Kibana visualizations, these values will appear in the same way as a zero. We will add an index and with those rows and a visualization warning that data is missing.

### Overlapping counts
Be careful not to count applications twice. Make sure to exclude the totals - or select only the totals.

citizen:
TOTAL
EU28
EXT_EU28

geo:
TOTAL
EU28

age:
TOTAL
Y_LT18 (includes Y_LT14 and Y14-17 - this is a mean one)

sex:
T

asy_app:
ASY_APP are all
NASY_APP are first time applications


### Install logstash

https://www.elastic.co/guide/en/logstash/current/installing-logstash.html

For example, on a fresh Ubuntu 16 machine, follow [logstash_install_ubuntu16.md](./logstash_install_ubuntu16.md).

### Prepare elasticsearch

Prepare elasticsearch - else it will have trouble recognizing your year as a date:
`PUT eurostat-migr_asyappctza/_mapping/doc -d@ migr_asyappctza_unpivot_template.json`
[migr_asyappctza_unpivot_template.json](./migr_asyappctza_unpivot_template.json)

### Configure logstash

grab the coordinates of your source csv and the target elasticsearch. If your cluster is protected by Shield, follow https://www.elastic.co/guide/en/logstash/6.1/ls-security.html#ls-http-auth-basic .

Prepare your csv input: Create a list of column haeders, and remove them from the csv. Now, you rea ready to configure logstash:
Make the date ISO-ish, so that elasticsearch will recognize it as a date. (Alternatively, we could put an index mapping template. But we should use ISO anyway.). Also, tell logstash which columns are integers.

We create a unique key to protect against [duplicates](https://www.elastic.co/blog/logstash-lessons-handling-duplicates).

An example is here: [logstash_configs/migr_asyappctza.conf](./logstash_configs/migr_asyappctza.conf)

 
