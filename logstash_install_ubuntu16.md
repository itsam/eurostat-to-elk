## Install logstash on Ubuntu 16.4

Get Java 8 (not supported for Java 9)

follow https://wiki.ubuntuusers.de/Java/Installation/Oracle_Java/Java_8/

e.g. on a fresh install without java 9, in Jan 2018:

get jdk-8u161-linux-x64.tar.gz from http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html 

> VERSION=161
> gunzip jdk-8u${VERSION}-linux-x64.tar.gz
> tar -xvf jdk-8u${VERSION}-linux-x64.tar
> sudo mkdir /opt/Oracle_Java
> sudo mv jdk1.8.0_${VERSION} /opt/Oracle_Java/
> 
> sudo update-alternatives --install "/usr/bin/java" "java" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/java" 1
> sudo update-alternatives --install "/usr/bin/javac" "javac" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/javac" 1
> sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/javaws" 1
> sudo update-alternatives --install "/usr/bin/jar" "jar" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/jar" 1 
> sudo update-alternatives --set "java" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/java"
> sudo update-alternatives --set "javac" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/javac"
> sudo update-alternatives --set "javaws" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/javaws"
> sudo update-alternatives --set "jar" "/opt/Oracle_Java/jdk1.8.0_${VERSION}/bin/jar" 

Now, this should come back with something like `java version "1.8.0_161"
`:

> java -version

Now, install logstash - Just follow https://www.elastic.co/guide/en/logstash/current/installing-logstash.html#_apt .

Next, configure logstash:

To test locally, put this into a file in /etc/logstash/conf.d/

> input {
>     file {
>         path => "/path/to/r-eurostat-refugees/data/migr_asydcfsta.csv"
>         start_position => "beginning"
>     }
> }
> 
> filter {
>     csv {
>         autodetect_column_names => true
>     }
> }
> 
> output {
>     file {
>         path => "/tmp/logstash.out"
>     }
> }

Start the service, and, with a little patience, wait for the output file to appear. If it doesn't, check the logs.
This isn't good enough for elasticsearch, though - the integers will arrive as strings in your index. Also, I recommend cutting the header and giving the column names explicitly. See our logstash configuration examples.



