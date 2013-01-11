# Test harness for exercising Fedora Futures candiates

- JBoss ModeShape
- Fedora 3.x (baseline)
- Databank

## Expand the fixtures
Init the submodules to get external resources:

```bash
$ git submodule init
$ git submodule update
```

Convert the open-planets data:

```bash
$ cd fixtures
$ git submodule init; git submodule update
$ ./convert-openplanet-corpus-to-fixtures.rb
```


## Launch external services

### JBoss Modeshape:

```bash
pushd jetty ; java -jar start.jar ; popd
```

### Fedora 3.x:

```bash
$ pushd hydra-jetty; java -Djetty.port=8983 -Dsolr.solr.home=`pwd`/solr -Xmx256m -XX:MaxPermSize=128m -jar start.jar; popd
```

### Databank

???


## Launch JMeter

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

