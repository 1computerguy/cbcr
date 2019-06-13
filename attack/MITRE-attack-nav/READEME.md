# ATT&CK<sup>™</sup> Navigator
The ATT&CK Navigator is designed to provide basic navigation and annotation of [ATT&CK](https://attack.mitre.org) matrices, something that people are already doing today in tools like Excel.  We've designed it to be simple and generic - you can use the Navigator to visualize your defensive coverage, your red/blue team planning, the frequency of detected techniques or anything else you want to do.  The Navigator doesn't care - it just allows you to manipulate the cells in the matrix (color coding, adding a comment, assigning a numerical value, etc.).  We thought having a simple tool that everyone could use to visualize the matrix would help make it easy to use ATT&CK.

The principal feature of the Navigator is the ability for users to define layers - custom views of the ATT&CK knowledge base - e.g. showing just those techniques for a particular platform or highlighting techniques a specific adversary has been known to use. Layers can be created interactively within the Navigator or generated programmatically and then visualized via the Navigator.

## Usage
There is an **Install and Run** section below that explains how to get the ATT&CK Navigator up and running. You can also try the Navigator out by pointing your browser [here](https://mitre-attack.github.io/attack-navigator). The default is the [Enterprise ATT&CK](https://attack.mitre.org/matrices/enterprise/) domain, but the [Mobile ATT&CK](https://attack.mitre.org/matrices/mobile) domain can be utilized [here](https://mitre-attack.github.io/attack-navigator/mobile/). See **Enterprise and Mobile Domains** below for information on how to set up the ATT&CK Navigator on local instances to use the two different domains.

**Important Note:** Layer files uploaded when visiting our Navigator instance hosted on GitHub Pages are **NOT** being stored on the server side, as the Navigator is a client-side only application. However, we still recommend installing and running your own instance of the ATT&CK Navigator if your layer files contain any sensitive content.

Use our [GitHub Issue Tracker](https://github.com/mitre-attack/attack-navigator/issues) to let us know of any bugs or others issues that you encounter. We also encourage pull requests if you've extended the Navigator in a cool way and want to share back to the community!

*See [CONTRIBUTING.md](https://github.com/mitre-attack/attack-navigator/blob/master/CONTRIBUTING.md) for more information on making contributions to the ATT&CK Navigator.*

## Running the Docker File
1. Navigate to the **nav-app** directory
2. Run `docker build -t yourcustomname .`
3. Run `docker run -p 4200:4200 yourcustomname`
4. Navigate to `localhost:4200` in browser

## Loading Default Layers Upon Initialization
The Navigator can be configured so as to load a set of layers upon initialization. These layers can be from the web and/or from local files. 
Local files to load should be placed in the `nav-app/src/assets/` directory.
1. Set the `enabled` property in `default_layers` in `src/assets/config.json` to `true`
2. Add the paths to your desired default layers to the `urls` array in `default_layers`. For example,
   ```JSON
   "default_layers": {
        "enabled": true,
        "urls": [
            "assets/example.json", 
            "https://raw.githubusercontent.com/mitre-attack/attack-navigator/master/layers/data/samples/Bear_APT.json"
        ]
    }
   ```
   would load `example.json` from the local assets directory, and `Bear_APT.json` from this repo's sample layer folder on Github.
3. Load/reload the Navigator

A single default layer from the web can also be set using a query string in the Navigator URL. Refer to the in-application help page section "Customizing the Navigator" for more details.

## Disabling Navigator Features
The `features` array in `nav-app/src/assets/config.json` lists Navigator features you may want to disable. Setting the `enabled` field on a feature in the configuration file will hide all control
elements related to that feature.

However, if a layer is uploaded with an annotation or configuration
relating to that feature it will not be hidden. For example, if `comments` are disabled the
ability to add a new comment annotation will be removed, however if a layer is uploaded with
comments present they will still be displayed in tooltips and and marked with an underline.

Features can also be disabled using the _create customized Navigator_ feature. Refer to the in-application help page section "Customizing the Navigator" for more details.

## Embedding the Navigator in a Webpage
If you want to embed the Navigator in a webpage, use an iframe:
```HTML
<iframe src="https://mitre-attack.github.io/attack-navigator/enterprise/" width="1000" height="500"></iframe>
```
If you want to imbed a version of the Navigator with specific features removed (e.g tabs, adding annotations), or with a default layer, we recommend using the _create customized Navigator_ feature. Refer to the in-application help page section "Customizing the Navigator" for more details.

The following is an example iframe which embeds our [*Bear APTs](layers/data/samples/Bear_APT.json) layer with tabs and the ability to add annotations removed:
```HTML
<iframe src="https://mitre-attack.github.io/attack-navigator/enterprise/#layerURL=https%3A%2F%2Fraw.githubusercontent.com%2Fmitre%2Fattack-navigator%2Fmaster%2Flayers%2Fdata%2Fsamples%2FBear_APT.json&tabs=false&selecting_techniques=false" width="1000" height="500"></iframe>
```

## Related MITRE Work
#### CTI
[Cyber Threat Intelligence repository](https://github.com/mitre/cti) of the ATT&CK catalog expressed in STIX 2.0 JSON.

#### ATT&CK
ATT&CK™ is a curated knowledge base and model for cyber adversary behavior, reflecting the various phases of an adversary’s lifecycle and the platforms they are known to target. ATT&CK is useful for understanding security risk against known adversary behavior, for planning security improvements, and verifying defenses work as expected.

https://attack.mitre.org

#### STIX
Structured Threat Information Expression (STIX™) is a language and serialization format used to exchange cyber threat intelligence (CTI).

STIX enables organizations to share CTI with one another in a consistent and machine readable manner, allowing security communities to better understand what computer-based attacks they are most likely to see and to anticipate and/or respond to those attacks faster and more effectively.

STIX is designed to improve many different capabilities, such as collaborative threat analysis, automated threat exchange, automated detection and response, and more.

https://oasis-open.github.io/cti-documentation/

## Notice
Copyright 2018 The MITRE Corporation

Approved for Public Release; Distribution Unlimited. Case Number 18-0128.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

This project makes use of ATT&CK<sup>™</sup>

[ATT&CK Terms of Use](https://attack.mitre.org/resources/terms-of-use/)