Script for running Apache JMeter against JBoss ModeShape.

Includes pre-configured Jetty with ModeShape installed.

To run, create a file with one-per-line filenames (to be used as uploads). See files.txt for an example.

Then start Jetty with:

pushd jetty ; java -jar start.jar ; popd

Add JMeter to your PATH a la:

export PATH=$PATH:~/jmeter/bin

and run the script via:

meter -Jcatalog=[your-catalog-of-files] -n -t ModeShapeMadness.jmx -l [where-you-want-the-general-logfile]

It will finish with several logs. The most interesting are nodecreate.log, which describes the creation of JCR nodes, and binaryload.log, which describes how binary content got loaded. 


Or you can open JMeter's GUI and load the script to run it interactively (see colored graphs!) or tinker with it.
