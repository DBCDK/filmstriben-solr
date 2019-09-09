FROM docker.dbc.dk/dbc-solr8-base

# start solr in the foreground with a heap size of 4g
CMD ["bin/solr", "start", "-f", "-m", "4g"]

EXPOSE 8983
