# Test harness for exercising Fedora Futures candiates

- JBoss ModeShape
- Fedora 3.x (baseline)
- Databank
- Lily


## 1. Expand the fixtures

The fixtures directory is linked into this project as a git submodule. First, you need to get that data:

```bash
$ git submodule init
$ git submodule update
```

One of the dependencies of the fixtures project is the python bagit client:

```bash
$ pip install bagit
```

Then, grab the digital corpora data:

```bash
$ cd fixtures
$ BAGIT_PY=./path/to/bagit.py ./get-digitalcorpora-corpus.sh #this may take some time.
```


## 2. Launch the candidate applications

### JBoss Modeshape:

```bash
pushd jetty ; java -jar start.jar ; popd
```

### Fedora 3.x:

```bash
$ pushd hydra-jetty; java -Djetty.port=8983 -Dsolr.solr.home=`pwd`/solr -Xmx256m -XX:MaxPermSize=128m -jar start.jar; popd
```

### Databank

```bash
```

### Lily

```bash
$ curl -O http://lilyproject.org/release/1.3/lily-1.3.tar.gz
$ tar -xvzf lily-1.3.tar.gz
$ cd lily-1.3; bin/launch-test-lily
```

## Launch JMeter

Add JMeter to your PATH a la:

```bash
export PATH=$PATH:~/jmeter/bin
```

You can open JMeter's GUI and load the script to run it interactively (see colored graphs!) or tinker with it. Run JMeter via:

```bash
jmeter
```

Toggle on and off the various threadgroups you want to run. They'll run in parallel (and crunch through the whole data set). IMPORTANT NOTE: Make sure you have enough disk space available to make N copies of the fixtures data.



### Headless JMeter

You can also run JMeter in headless mode.

```
meter -Jnumthreads=[number-of-threads-defaults-to-1] -n -t ModeShapeMadness.jmx -l [where-you-want-the-general-logfile]
```

It will finish with several logs. The most interesting are nodecreate.log, which describes the creation of JCR nodes, and binaryload.log, which describes how binary content got loaded. 


