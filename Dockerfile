FROM docker.elastic.co/elasticsearch/elasticsearch:6.6.1

RUN yum update -y && yum clean all

COPY hook-wrapper.sh /usr/local/bin/

ENV trap_signals "INT TERM HUP"
ENV prestart_hook ""
ENV poststart_hook ""
ENV prestop_hook ""
ENV poststop_hook ""

ENV entrypoint_original "/usr/local/bin/docker-entrypoint.sh"
ENV cmd_original "eswrapper"

ENTRYPOINT ["hook-wrapper.sh"]
CMD ["eswrapper"]
