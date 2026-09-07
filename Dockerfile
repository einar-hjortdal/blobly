FROM openmamba/openmamba:latest

COPY . /tmp/blobly

RUN dnf install --nogpgcheck --assumeyes git make gcc glibc-devel libatomic-devel libopenssl-devel && \
	git clone --depth=1 https://github.com/vlang/v /tmp/v && \
	cd /tmp/v && \
	make && \
	cd /tmp/blobly && \
	/tmp/v/v install && \
	/tmp/v/v . -o /opt/blobly && \
	rm -rf /tmp/v && \
	rm -rf /tmp/blobly && \
	rm -rf /root/.vmodules && \
	dnf remove --assumeyes git make gcc glibc-devel libatomic-devel libopenssl-devel && \
	dnf clean all && \
	groupadd --system blobly && \
	useradd --system --gid blobly --no-create-home --shell /usr/sbin/nologin blobly && \
	chown blobly:blobly /opt/blobly && \
	mkdir -p /var/lib/blobly/data && \
	chown -R blobly:blobly /var/lib/blobly/data && \
	chmod 750 /var/lib/blobly/data

EXPOSE 8080

USER blobly

CMD ["/opt/blobly"]
