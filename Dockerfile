FROM ibmcom/swift-ubuntu:latest
EXPOSE 8090
USER root
RUN apt-get install -y libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev 
COPY ./pcre2-10.20 /root/
RUN cd /root && ./configure && make && make install
RUN cd /root && mkdir swift-helloworld
COPY . /root/swift-helloworld/
RUN cd /root/swift-helloworld && swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
CMD ["/root/swift-helloworld/.build/debug/Resources"]