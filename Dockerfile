FROM docker.dbc.dk/dbc-solr8-base

COPY --chown=solr conf/conf/solrconfig.xml server/resources
COPY --chown=solr conf/conf/managed-schema server/resources
COPY --chown=solr conf/conf/lang server/resources/lang
COPY --chown=solr conf/conf/protwords.txt server/resources
COPY --chown=solr conf/conf/synonyms.txt server/resources
COPY --chown=solr conf/conf/stopwords.txt server/resources

# make a core called filmstriben
RUN mkdir -p server/solr/filmstriben/conf  && \
	touch server/solr/filmstriben/core.properties

COPY --chown=solr conf/conf/params.json server/solr/filmstriben/conf
COPY --chown=solr data server/solr/filmstriben/data

# start solr in the foreground with a heap size of 4g
CMD ["bin/solr", "start", "-f", "-m", "4g"]

EXPOSE 8983
