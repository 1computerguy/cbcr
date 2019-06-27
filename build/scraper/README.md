# Site Scraper (Downloader)

### This is a website scraper using Puppeteer, headless Chrome, Docker. To run manually use the following commands.

```
docker build -t puppeteer-chrome-linux .
docker run --rm -i --init -d -e URL=google.com -u root \
            --cap-add=SYS_ADMIN -v /web:/web/output \
            --name get-google puppeteer-chrome-linux:scraper \
            node -e "`cat scrape.js`"
```

You can pass in a number of environment variables to configure this how you want.
```
SAVE_LOCATION=<volume mounted dir if different than /web/output>
URL=<URL to scrape>
PROTOCOL=<http or https> (defaults to https)
```
