# RITA (Real Intelligence Threat Analytics)

Brought to you by [Active Countermeasures](https://www.activecountermeasures.com/).

[![Build Status](https://travis-ci.org/activecm/rita.svg?branch=master)](https://travis-ci.org/activecm/rita)

---
### What is Here

RITA is an open source framework for network traffic analysis.

The framework ingests [Bro/Zeek Logs](https://www.zeek.org/) in TSV format, and currently supports the following major features:
 - **Beaconing Detection**: Search for signs of beaconing behavior in and out of your network
 - **DNS Tunneling Detection** Search for signs of DNS based covert channels
 - **Blacklist Checking**: Query blacklists to search for suspicious domains and hosts

#### Configuration File
RITA's config file is located at `/etc/rita/config.yaml` though you can specify a custom path on individual commands with the `-c` command line flag.

:exclamation: **IMPORTANT** :exclamation:
* The `Filtering: InternalSubnets` section *must* be configured or you will not see any results in certain modules (e.g. beacons, long connections). If your network uses the standard RFC1918 internal IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) you just need uncomment the default `InternalSubnets` section already in the config file. Otherwise, adjust this section to match your environment. RITA's main purpose is to find the signs of a compromised internal system talking to an external system and will automatically exclude internal to internal connections and external to external connections from parts of the analysis.

You may also wish to change the defaults for the following option:
* `Filtering: AlwaysInclude` - Ranges listed here are exempt from the filtering applied by the `InternalSubnets` setting. The main use for this is to include internal DNS servers so that you can see the source of any DNS queries made.

Note that any value listed in the `Filtering` section should be in CIDR format. So a single IP of `192.168.1.1` would be written as `192.168.1.1/32`.

#### Obtaining Data (Generating Bro/Zeek Logs):
  * **Option 1**: Generate PCAPs outside of Bro/Zeek
    * Generate PCAP files with a packet sniffer ([tcpdump](http://www.tcpdump.org/), [wireshark](https://www.wireshark.org/), etc.)
    * (Optional) Merge multiple PCAP files into one PCAP file
      * `mergecap -w outFile.pcap inFile1.pcap inFile2.pcap`
    * Generate Bro/Zeek logs from the PCAP files
      * ```bro -r pcap_to_log.pcap local "Log::default_rotation_interval = 1 day"```

  * **Option 2**: Install Bro/Zeek and let it monitor an interface directly [[instructions](https://www.zeek.org/sphinx/quickstart/)]
      * You may wish to [compile Bro/Zeek from source](https://www.zeek.org/sphinx/install/install.html) for performance reasons. [This script](https://github.com/activecm/bro-install) can help automate the process.
      * The automated installer for RITA installs pre-compiled Bro/Zeek binaries by default
        * Provide the `--disable-bro` flag when running the installer if you intend to compile Bro/Zeek from source

#### Importing and Analyzing Data With RITA
  After installing RITA, setting up the `InternalSubnets` section of the config file, and collecting some Bro/Zeek logs, you are ready to begin hunting.

  Filtering and whitelisting happens at import time. These optional settings can be found alongside `InternalSubnets` in the configuration file.

  RITA will process Bro/Zeek TSV logs in both plaintext and gzip compressed formats. Note, if you are using Security Onion or Bro's JSON log output you will need to [switch back to traditional TSV output](https://securityonion.readthedocs.io/en/latest/bro.html#tsv).

  * **Option 1**: Create a One-Off Dataset
      * `rita import path/to/your/bro_logs dataset_name` creates a dataset from a collection of Bro/Zeek logs in a directory
      * Every log file directly in the supplied directory will be imported into a dataset with the given name
      * Once a dataset has been created in this fashion, no other data may be imported into the dataset
  * **Option 2**: Create a Rolling Dataset
      * Rolling datasets allow you to progressively analyze the last 24 hours of log data
      * RITA cycles data into and out of rolling databases in "chunks". Chunks are even divisions of a day.
          * For example, a rolling database configured to hold data in 4 chunks will import logs 6 hours at a time
      * `rita import --rolling --numchunks # --chunk # path/to/your/bro_logs dataset_name` imports the logs in a given directory which match the period of time derived from the `numchunks` and `chunk` arguments
      * `numchunks` controls how much data will be processed each time a rolling import is ran
          * The value supplied for `numchunks` must evenly divide 24
          * Valid choices are 1, 2, 3, 4, 6, 8, 12, and 24
          * Each choice will process new data in 24, 12, 8, 4, 3, 2, and 1 hour periods, respectively
      * `chunk` tells RITA which period of data to import
          * The value supplied for `chunk` must be between 1 and `numchunks` (inclusive)
          * If `numchunks` is set to 4, and `chunk` is set to 2, RITA will import logs from 6 am to noon
      * Rolling databases should be routinely updated with new data
          * `numchunks` should remain constant each time `import` is ran on the same rolling dataset
          * `chunk` should loop through 1 to `numchunks` (inclusive) as new data becomes available
          * `chunk` should be reset to 1 once the last chunk has been imported. This causes the previous chunk 1 to be removed from the dataset before the new data is imported and ensures that the rolling dataset always contains at most 24 hours worth of data.
      * RITA depends on the default naming scheme Bro/Zeek uses for hourly rotated logs. If your logs have been renamed, rolling imports will not work. In this case you should use Option 1 for creating a one-off dataset instead.

#### Examining Data With RITA
  * Use the **show-X** commands
      * `show-databases`: Print the datasets currently stored
      * `show-beacons`: Print hosts which show signs of C2 software
      * `show-bl-hostnames`: Print blacklisted hostnames which received connections
      * `show-bl-source-ips`: Print blacklisted IPs which initiated connections
      * `show-bl-dest-ips`: Print blacklisted IPs which received connections
      * `show-exploded-dns`:  Print dns analysis. Exposes covert dns channels
      * `show-long-connections`: Print long connections and relevant information
      * `show-strobes`: Print connections which occurred with excessive frequency
      * `show-useragents`: Print user agent information
  * By default RITA displays data in CSV format
      * `-H` displays the data in a human readable format
      * Piping the human readable results through `less -S` prevents word wrapping
          * Ex: `rita show-beacons dataset_name -H | less -S`
  * Create a html report with `html-report`


# Docker Usage

You can run RITA using Docker! You have several options depending on your specific needs.
* Running RITA with Docker Compose - This is the simplest option and requires the least setup. You will have to provide your own Bro logs.
* Running RITA with Docker Using External Mongo - This option is useful if you do not want to use Docker Compose or you have an external Mongo server you wish to use.
* Using Docker to Build RITA - You can use Docker to build a standalone RITA binary that runs on any Linux 64-bit CPU. This is useful if you want a portable binary but don't want to use Docker to actually run RITA.

## Obtaining the RITA Docker Image

The easiest way is to pull down the pre-built image.

```
docker pull quay.io/activecm/rita:master
```

You can also build the image from source.

```
docker build -t quay.io/activecm/rita:master .
```

## Running RITA with Docker Compose

At the very least, you will have to provide RITA with the path to your Bro log files using the `BRO_LOGS` environment variable.

```
export BRO_LOGS=/path/to/your/logs
docker-compose run --rm rita import
docker-compose run --rm rita analyze
```

You can also call it this way if you wish.

```
BRO_LOGS=/path/to/your/logs docker-compose run --rm rita import
BRO_LOGS=/path/to/your/logs docker-compose run --rm rita analyze
```

RITA will use the default `config.yaml` file which will work out of the box. If you wish to specify your own config file you can do so like this:

```
export BRO_LOGS=/path/to/your/logs
docker-compose run --rm -v /path/to/your/rita/config.yaml:/etc/rita/config.yaml rita show-databases
```

Note: If you'd like to use a different version of RITA than the default `master` you can do so using the `RITA_VERSION` variable.

```
export RITA_VERSION=dev
export BRO_LOGS=/path/to/your/logs
docker-compose run --rm -v /path/to/your/rita/config.yaml:/etc/rita/config.yaml rita show-databases
```

## Running RITA with Docker Using External Mongo

If you don't need/want the convenience of Docker Compose running the Mongo server for you, you can also use RITA without it. You will need to modify RITA's config file to point to your external Mongo server.

```
docker run -it --rm \
	-v /path/to/your/bro/logs:/opt/bro/logs/:ro \
	-v /path/to/your/rita/config.yaml:/etc/rita/config.yaml:ro \
	quay.io/activecm/rita:master import
docker run -it --rm \
	-v /path/to/your/bro/logs:/opt/bro/logs/:ro \
	-v /path/to/your/rita/config.yaml:/etc/rita/config.yaml:ro \
	quay.io/activecm/rita:master analyze
```

## Using Docker to Build RITA

You can use Docker to build a statically linked RITA binary for you. This binary should be portable between Linux 64-bit systems. Once you've obtained the RITA docker image (see the "Obtaining the RITA Docker Image" section above) you can run the following commands to copy the binary to your host system.

```
docker create --name rita quay.io/activecm/rita:master
docker cp rita:/rita ./rita
docker rm rita
```

Note that you will have to manually install the `config.yaml` files into `/etc/rita/` as well as create any directories referenced inside the `config.yaml` file.

### Getting help
Please create an issue on GitHub if you have any questions or concerns.

### Contributing to RITA
To contribute to RITA visit our [Contributing Guide](Contributing.md)

### License
GNU GPL V3
&copy; Active Countermeasures &trade;