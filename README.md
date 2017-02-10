README – FABTOOLS
Developed by Fabrice MOYEN, Power system benchmark manager, IBM France.
(except lsluns and FCwait developed by Sebastien Chabrolles, IBM France)

-------------------------------------------------------------------------------------
Contact: fabrice_moyen@fr.ibm.com
Readme release v1.0 – September, 5th 2008
-------------------------------------------------------------------------------------

The goal of these little fab-tools is to ease the administration and monitoring of several AIX systems (full scale servers or logical partitions), allowing you to:

  + start an nmon collection on all your servers in one command
  + execute one command on all your servers in one shot
  + gather all the systems / network / disks / nfs / security / devices informations into one txt file (for reporting, traces, etc.).
  + ease the creation / administration of DS8300 flashcopy so that even your customer will be able to resynchronize its data from a flashcopy after ech run. 
  + etc.

-------------------------------------------------------------------------------------
Pre-requisites:
  + Systems with AIX operating systems installed (V5.2 or greater)
  + nmon (Nigel Griffiths monitoring tool) installed on each system.

-------------------------------------------------------------------------------------
Installation:


1)	Login as root onto one of your AIX system. If you have an administrative system (like a “piana” partition), it could be a good idea to use this one.

2)	All the files contained into the fabtools tar file need to be untar into one directory on one of your AIX system (node). Generally /usr/opt/fabtools is a good place to do, but this is not a obligation.
cd /usr/opt ; tar xvf fabtools_V2.37_04Sep08_182907.tar

3)	Create a filesystem for the results of the fnmon tools. Generally, I call it /results, but this is not an obligation. Export it using NFS to the others AIX systems with the root access (so that every systems will be able to write onto it).

4)	Create a filesystem for the results of the tools (except fnmon). Generally, I call it /tools_results, but this is not an obligation. Export it using NFS to the others AIX systems with the root access (so that every systems will be able to write onto it).

5)	The fabtools need to execute commands on all the systems without giving a password. Two options: rsh or ssh. Configure one of them so that you can rsh/ssh as root from each node to all the other nodes.

6)	Then you execute the /usr/opt/fabtools/bin/install_fabtools script. 
It will help you to populate the fabtools/conf/fabtools.conf file with the right configuration infos like results’directory, where to find the nmon command, the nmon arguments to use etc.
   + REP_RACINE = the directory for the fnmon results
   + REP_TOOLS = the directory for all the tools except fnmon
   + USE_SAMPLE = fnmon parameter: if you want to have 2 little nmons running at 1/3 and 2/3 of your run. Generally, keep it null.
   + RSH = rsh or ssh. Your choice.
   + USE_TPROF = fnmon parameter: if you want to have tprof collections at 1/3 and 2/3 of your run.
   + USE_FILEMON = fnmon parameter: if you want to have filemon collections at 1/3 and 2/3 of your run.
   + USE_NETSTAT = not working. Keep to zero.
   + USE_GETINFO = fnmon parameter: if you want to do a getinfo on each node before starting your run.

It will also configure the path in the /.profile file, will add an entry in the local crontab file to start a daily nmon collection (a snapshot every 5 minutes during 24hours), etc.

7)	Check that the rsh/ssh is working fine with the command: doit uname –a
This should give you the uname of all your nodes in return.

8)	Use the fabsync tool to finish the installation. It will generate a new tar file (into REP_TOOLS) containing your configuration and will untar it onto all you nodes. 

9)	The installation is done.

-------------------------------------------------------------------------------------
Into the fabtools directory, you will find several tools. The major part of the tools is available under the fabtools/bin directory.
If you need some help / information about the available options for a specific tool, just use the “-h” option (doit –h, getinfo –h, etc.)

Quite all the tools’ results are sent on screen and into the $REP_TOOLS directory, except for fnmon which is sending its results into the $REP_RACINE directory (see fabtools.conf file).

-------------------------------------------------------------------------------------
Fabtools.conf configuration file:
The configuration of the tools is available under one unique file : fabtools/conf/fabtoools.conf. You shouldn’t need to modify any tool scripts.

There is two ways to modify the fabtools.conf:
    + manually with an editor like “vi”
    + using the “install_fabtools” script (see the installation section of this readme).

-------------------------------------------------------------------------------------
Doit:
This tool will allow you to automatically execute a command onto all the systems defined into the fabtools.conf in one shot.

Example:
doit uname –a
doit df –gP 
doit « ps –ef | grep oracle | awk ‘{print $1}’ »
doit –nodes as1,as2 ls –latr (doit will use this nodes’ list instead of the fabtools.conf list)

-------------------------------------------------------------------------------------
fnetperf :
fnetperf will allow you to test the network bandwidth between the local nodes and all the other nodes defined into the fabtools.conf. This is important to check your gigabit Ethernet is really working at 100 MB/s.

You can combine fnetperf with the doit tool to make testing from all nodes to all nodes.:
    + doit /usr/opt/fabtools/bin/fnetperf

It is also possible to give to fnetperf suffix or prefix to the nodes names known into the fabtools.conf.
Let’s imagine you have three nodes: as1, as2 and db with two networks : injection and administration networks. Then, if you defined your IP aliases like that : 
    + as1 and as1_adm
    + as2 and as2_adm
    + db and db_adm
If “NODES=as1,as2 and db” into the fabtools.conf

“fnetperf ” will do testing onto the injection network
“fnetperf –p _adm” will do testing onto the administration network

-------------------------------------------------------------------------------------
getinfo :
This tool will gather a lot of informations about the AIX system onto it is running like : 
   + prtconf
   + network configuration
   + filesets configuration
   + no, vmo, ioo, nfso, schedo
   + disks configuration
   + etc.

This simple tool is usefull as you can then give all the AIX configuration onto your report.

You can combine getinfo with the doit tool to make gathering for all nodes:
    + doit /usr/opt/fabtools/bin/getinfo

It is also possible to combine getinfo with the fnmon tool so you’ll do a getinfo onto all the AIX systems before starting each run (USE_GETINFO=1 into the fabtools.conf file)

-------------------------------------------------------------------------------------
fnmon/fnmoncheck/fnmonstop
These 3 scripts are linked and will operate with nmon (the Nigel Griffiths monitoring tool)
   + fnmon is used to start a nmon collection onto all the NODES in one shot
   + fnmoncheck is used to check if the nmon collection is running onto all NODES
   + fnmonstop is used to stop nmon collection onto all NODES in one shot

Please see the fabtools/fnmon/fnmon_README.txt and the fnmon –h, fnmoncheck –h and fnmonstop –h for more informations on how to use these tools.

-------------------------------------------------------------------------------------
myscreen
When you are using the powerfull “screen” utility, a miss still exists : it is impossible to know if you are actually connected to a screen. The myscreen will give you the name of the screen you are connected. 

Example:
{admin:root}/usr/opt/fabtools/bin # myscreen
        348268.Fab1     (Attached)

-------------------------------------------------------------------------------------
mkFCscripts
The mkFCscripts will generate for you all the needed scripts when using DS8000 flashcopy mechanisms.
  + the scripts to make flashcopy paires
  + the scripts to make permanent flashcopy paires
  + the scripts to resynchronize flashcopy paires
  + the scripts to remove flashcopy paires

All these scripts are generated for both directions (source -> target and target -> source) and different scripts are created for: 
   + dscli (with “dscli –script <script_name>” command)
   + AIX ksh (with “ksh <script_name> comman)
   + easy_dscli on windows (with the windows carriage return : ^M)

-------------------------------------------------------------------------------------
FCwait
This script has been created by Sebastien Chabrolles and as it is useful, I’ve included it onto my fabtools. It allows you to wait for flashcopy synchronization, giving you an estimation of the time needed to end the synchronization (always low estimation) and telling you when the synchronization is done.
Pre-requisite: have dscli installed and configured for your DS8000.

-------------------------------------------------------------------------------------
lsluns
Another useful script developed by Sebastien Chabrolles. Lsluns gives you all the information needed onto your luns (lunid, hdisk, size, etc.).
Pre-requisite: have dscli installed and configured for your DS8000.

-------------------------------------------------------------------------------------
fabsync
This is a fabtools administrative tool. It allows you, when you’re doing a modification on the fabtools (fabtools.conf modification, scripts modification) to synchronise all your nodes with this modification.

The way it works: It generates a tar file containing all the fabtools directory, then it removes all the fabtools directories onto all nodes except the local one and untar the tar file onto these nodes. 

-------------------------------------------------------------------------------------
install_fabtools
This is a fabtools administrative tool. It will allow you to install the fabtools on all your nodes: 
  + install all the scripts into the fabtools directory
  + configure the fabtools.conf file
  + update the crontab to do a daily nmon collection
  + add the fabtools/bin path into the /.profile
  + create a /.screenrc file (to use logging, set the toolbar depth, etc.)
