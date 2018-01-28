# Eurostat into ELK

This is a project to get data from [Eurostat](http://ec.europa.eu/eurostat/de/data/database).
It is in fact a merge of two approaches, and github projects:
  
# [r-eurostat-refugees](https://github.com/muc-fluechtlingsrat/r-eurostat-refugees) gets and processes the data R. Retrieving the data works like a breeze. Vizualising is less of a breeze. R is great, you can do truly great things. If you are an expert. 
# [elastify-eurostat](https://github.com/muc-fluechtlingsrat/elastify-eurostat) fetches the data from another eurostat API with nodejs and pushes it to an elk stack. Once the data is there, every elastic stack fan is happy and feels at home. However, if anything breaks on the way, you create duplicates, you create gaps, and fixing this is notoriously hard on the fly, or later in elasticsearch.

This time, everything will be smooth. 

We get the data the R way, may process it a bit, store it to csv and push it to elasticsearch using good old logstash. 

## First, follow r-eurostat:

### Prepare
1. Install R and rstudio - e.g. as in https://github.com/muc-fluechtlingsrat/r-eurostat-refugees/blob/master/man/ON_FRESH_UBUNTU.md

2. Open the r-project file \*.Rproj in rstudio as a project (see https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects
3. import and load all libraries by running import_packages.R (there are probably better ways), library(eurostat)

## Get data

To know which eurostat data source to use, check out http://htmlpreview.github.io/?https://github.com/muc-fluechtlingsrat/r-eurostat-refugees/blob/master/man/eurostat_asylum_data_sources.html

Let's work with the annual data, migr_asydcfsta, and go through the steps slowly.
1. load data into R, run in your console: 

> decisions_firstinstance_annual=get_eurostat("migr_asydcfsta", time_format = "date") 

## Process data in R: This step will be added later

## Save to csv: 

> write.table(decisions_firstinstance_annual, "data/migr_asydcfsta.csv", sep=",")

### Install logstash

https://www.elastic.co/guide/en/logstash/current/installing-logstash.html

For example, on a fresh Ubuntu 16 machine, follow logstash_install_ubuntu16.md.

### Configure logstash

grab the coordinates of your source csv and the target elasticsearch, and configure:

xxx
 
