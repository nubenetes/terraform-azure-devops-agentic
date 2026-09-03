#!/bin/bash

# https://stackoverflow.com/questions/11255630/how-to-export-all-collections-in-mongodb
# If you want to export your database into JSON you can use mongoexport except you have to do it one collection at a time (this is by design). 
# However I think it's easiest to export the entire database with mongodump and then convert to JSON.

# https://linuxhint.com/prompt-for-input-bash/

echo "This script dumps a mongodb atlas database to both BSON and JSON formats"
echo "There are two toools/commands to restore a mongo database:"
echo "1) mongorestore: BSON files"
echo "2) mongoimport: 1 JSON file per mongodb collection"
echo
read -p 'User name: ' username
read -sp 'Password: ' password    # The keyword “-sp” is used to hide the credential “Password” while entering the shell.
read -p 'Mongo Database: ' mongodatabase
read -p 'Mongo Connection String: ' connectionstring
echo
echo "Username: $username";
echo "MongoDatabase: $mongodatabase";
echo "ConnectionString: $connectionstring";
echo ""
mongodump -vvvv -d $mongodatabase "mongodb+srv://$username:$password@$connectionstring/"
for file in dump/*/*.bson; do bsondump $file > $file.json; done

####################
# Output Example
####################

# $ ./04-mongodump.sh 
# User name: Enterpriseadmin
# Password: 
# Mongo Database: app-db-cluster 
# Mongo Connection String: appcore-client-anon.uuz9c.mongodb.net
#
# Username: Enterpriseadmin
# MongoDatabase: app-db-cluster
# ConnectionString: appcore-client-anon.uuz9c.mongodb.net
#
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    initializing mongodump object
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    will listen for SIGTERM, SIGINT, and SIGKILL
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    starting Dump()
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.executions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.pipeline.executions'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.pipeline.series'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.config.appcore
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.config.appcore'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.definitions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.pipeline.definitions'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.rules
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.series.rules'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.instanceDataTags
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.instanceDataTags'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.standard
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.series.standard'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.subjects
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.subjects'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.standard.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.standard.series'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.standards
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.series.standards'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.configs
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.configs'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.assets
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    enqueued collection 'app-db-cluster.assets'
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    dump phase I: metadata, indexes, users, roles, version
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.subjects`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.standard.series`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.series.standards`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.configs`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.pipeline.series`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.pipeline.definitions`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.series.rules`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.series.standard`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.pipeline.executions`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.config.appcore`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.instanceDataTags`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ            reading indexes for `app-db-cluster.assets`
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    dump phase II: regular collections
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    finalizing intent manager with longest task first prioritizer
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    dumping up to 4 collections in parallel
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    starting dump routine with id=3
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    starting dump routine with id=2
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    starting dump routine with id=1
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    starting dump routine with id=0
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.pipeline.series to dump/app-db-cluster/pipeline.series.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.instanceDataTags to dump/app-db-cluster/instanceDataTags.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.instanceDataTags
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.pipeline.definitions to dump/app-db-cluster/pipeline.definitions.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.definitions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.series.rules to dump/app-db-cluster/series.rules.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.rules
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 55 documents in app-db-cluster.pipeline.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 4917 documents in app-db-cluster.instanceDataTags
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 10 documents in app-db-cluster.pipeline.definitions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 14 documents in app-db-cluster.series.rules
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.pipeline.definitions (10 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.series.rules (14 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.series.standard to dump/app-db-cluster/series.standard.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.standard
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.standard.series to dump/app-db-cluster/standard.series.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.standard.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 5 documents in app-db-cluster.series.standard
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 5 documents in app-db-cluster.standard.series
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.series.standard (5 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.standard.series (5 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.series.standards to dump/app-db-cluster/series.standards.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.series.standards
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.pipeline.executions to dump/app-db-cluster/pipeline.executions.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.pipeline.executions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.pipeline.series (55 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 5 documents in app-db-cluster.series.standards
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 3 documents in app-db-cluster.pipeline.executions
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.subjects to dump/app-db-cluster/subjects.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.subjects
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.series.standards (5 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 2 documents in app-db-cluster.subjects
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.pipeline.executions (3 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.config.appcore to dump/app-db-cluster/config.appcore.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.config.appcore
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.subjects (2 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.assets to dump/app-db-cluster/assets.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.assets
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 2 documents in app-db-cluster.config.appcore
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    writing app-db-cluster.configs to dump/app-db-cluster/configs.bson
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    Getting estimated count for app-db-cluster.configs
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 2 documents in app-db-cluster.assets
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.config.appcore (2 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    ending dump routine with id=2, no more work to do
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    counted 1 document in app-db-cluster.configs
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.assets (2 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    ending dump routine with id=1, no more work to do
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.configs (1 document)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    ending dump routine with id=0, no more work to do
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [........................]  app-db-cluster.instanceDataTags  101/4917  (2.1%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#.......................]  app-db-cluster.instanceDataTags  380/4917  (7.7%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [###.....................]  app-db-cluster.instanceDataTags  683/4917  (13.9%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [###.....................]  app-db-cluster.instanceDataTags  683/4917  (13.9%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [######..................]  app-db-cluster.instanceDataTags  1262/4917  (25.7%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#######.................]  app-db-cluster.instanceDataTags  1565/4917  (31.8%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#######.................]  app-db-cluster.instanceDataTags  1565/4917  (31.8%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#########...............]  app-db-cluster.instanceDataTags  1844/4917  (37.5%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [##########..............]  app-db-cluster.instanceDataTags  2146/4917  (43.6%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [###########.............]  app-db-cluster.instanceDataTags  2449/4917  (49.8%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#############...........]  app-db-cluster.instanceDataTags  2728/4917  (55.5%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [##############..........]  app-db-cluster.instanceDataTags  3031/4917  (61.6%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [################........]  app-db-cluster.instanceDataTags  3333/4917  (67.8%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#################.......]  app-db-cluster.instanceDataTags  3610/4917  (73.4%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [###################.....]  app-db-cluster.instanceDataTags  3911/4917  (79.5%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [####################....]  app-db-cluster.instanceDataTags  4198/4917  (85.4%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#####################...]  app-db-cluster.instanceDataTags  4476/4917  (91.0%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [#######################.]  app-db-cluster.instanceDataTags  4779/4917  (97.2%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    [########################]  app-db-cluster.instanceDataTags  4917/4917  (100.0%)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    done dumping app-db-cluster.instanceDataTags (4917 documents)
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    ending dump routine with id=3, no more work to do
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    dump phase III: the oplog
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    finishing dump
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    2 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    1 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    4917 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    10 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    3 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    55 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    14 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    5 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    5 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    5 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    2 objects found
# YYYY-MM-DDTHH:MM:SS.MMM+ZZZZ    2 objects found

# $ cd dump/
# $ ls
# app-db-cluster
# $ cd app-db-cluster/
# $ ls
# config.appcore.bson                      instanceDataTags.metadata.json         pipeline.series.bson.json               series.standards.bson                   assets.metadata.json
# config.appcore.bson.json                 pipeline.definitions.bson               pipeline.series.metadata.json           series.standards.bson.json              subjects.bson
# config.appcore.metadata.json             pipeline.definitions.bson.json          series.rules.bson                       series.standards.metadata.json          subjects.bson.json
# configs.bson                            pipeline.definitions.metadata.json      series.rules.bson.json                  standard.series.bson                    subjects.metadata.json
# configs.bson.json                       pipeline.executions.bson                series.rules.metadata.json              standard.series.bson.json
# configs.metadata.json                   pipeline.executions.bson.json           series.standard.bson                    standard.series.metadata.json
# instanceDataTags.bson                  pipeline.executions.metadata.json       series.standard.bson.json               assets.bson
# instanceDataTags.bson.json             pipeline.series.bson                    series.standard.metadata.json           assets.bson.json
