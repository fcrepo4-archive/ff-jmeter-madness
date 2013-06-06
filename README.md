# Test harness for exercising Fedora4 and Fedora3

## 1. Launch the candidate applications

### Fedora 3.x:

```bash
$ ...
```

### Fedora 4.x:

Deploy fedora-kitchen-sink webapp 


## Launch JMeter

Add JMeter to your PATH a la:

```bash
export PATH=$PATH:./jmeter/bin
```

You can open JMeter's GUI and load the script to run it interactively (see colored graphs!) or tinker with it. Run JMeter via:

```bash
jmeter
```

Toggle on and off the various threadgroups you want to run. They'll run in parallel (and crunch through the whole data set). IMPORTANT NOTE: Make sure you have enough disk space available to make N copies of the fixtures data.


### Headless JMeter

You can also run JMeter in headless mode.

```
meter -n -t ${BASE}/plans/fedora.jmx -Jfedora_4_server=${HOST} -Jfedora_4_context='fcrepo/rest' -Jnum_threads=${THREADS} -Jloop_count=${LOOPS} -Jfilesize_mean=${FILE_SIZE} -Jfilesize_stddev=${STD_DEV}
```



