FROM openmamba/openmamba:latest

COPY . /srv

RUN dnf update --nogpgcheck --refresh --assumeyes && \
	dnf install --nogpgcheck --assumeyes git make gcc glibc-devel libatomic-devel && \
	git clone --depth=1 https://github.com/vlang/v /opt/v && \
	cd /opt/v && \
	make && \
	cd /srv && \
	/opt/v/v install && \
	/opt/v/v . -o blobly && \
	rm -rf /opt/v && \
	rm -rf /root/.vmodules && \
	dnf remove --assumeyes git make gcc glibc-devel libatomic-devel && \
	dnf clean all

WORKDIR /srv

CMD ["./blobly"]

EXPOSE 8080