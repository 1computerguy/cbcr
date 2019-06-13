const scrape = require('website-scraper');
const PuppeteerPlugin = require('website-scraper-puppeteer');
scrapeUrl = process.env.URL;

// Set default save location for web scrapes
if(process.env.SAVE_LOCATION) {
  saveLocation = process.env.SAVE_LOCATION;
} else {
  saveLocation = '/web/output';
}

// Default protocol to https, but allow user to pass environment variable to change it
if(process.env.PROTOCOL) {
  protocol = process.env.PROTOCOL;
} else {
  protocol = 'https';
}

class PuppeteerAction {
  apply(registerAction) {
    registerAction('getReference', ({resource, parentResource, originalReference}) => {
      if (!resource) {
        return { reference: parentResource.url + originalReference };
      }
      return { reference: utils.getRelativePath(parentResource.filename, resource.filename) };
    });
  }
}

scrape({
    urls: [ protocol + '://' + scrapeUrl],
    directory: saveLocation + '/' + scrapeUrl,
    recursive: true,
    maxRecursiveDepth: 1,
    //filenameGenerator: 'bySiteStructure',
    ignoreErrors: false,
    request: {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36'
      }
    },
    plugins: [ new PuppeteerPlugin() ],
    plugins: [ new PuppeteerAction() ]
});
