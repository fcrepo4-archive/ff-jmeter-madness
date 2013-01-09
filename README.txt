Script for running Apache JMeter against JBoss ModeShape.

Includes pre-configured Jetty with ModeShape installed.

To run, create a file with one-per-line filenames (to be used as uploads). See files.txt for an example.

Then start Jetty with:

```bash
pushd jetty ; java -jar start.jar ; popd
```

Add JMeter to your PATH a la:

```bash
export PATH=$PATH:~/jmeter/bin
```

and run the script via:

```bash
meter -Jcatalog=[your-catalog-of-files] -Jnumthreads=[number-of-threads-defaults-to-1] -n -t ModeShapeMadness.jmx -l [where-you-want-the-general-logfile]
```
Each thread competes equally for files, so if your file catalog is 10,000 files and you ask for ten threads, each will get about a thousand files.

It will finish with several logs. The most interesting are nodecreate.log, which describes the creation of JCR nodes, and binaryload.log, which describes how binary content got loaded. 


Or you can open JMeter's GUI and load the script to run it interactively (see colored graphs!) or tinker with it.


## Hydra-jetty

Init the submodule:

```bash
$ git submodule init
$ git submodule update
```

Start hydra-jetty with:

```bash
$ pushd hydra-jetty; java -Djetty.port=8983 -Dsolr.solr.home=`pwd`/solr -Xmx256m -XX:MaxPermSize=128m -jar start.jar; popd
```
