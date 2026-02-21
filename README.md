# hexo-offline-popup-en

This project is a fork of [Colsrch/hexo-offline-popup](https://github.com/Colsrch/hexo-offline-popup), which has been archived since Aug. 7, 2022. 

I have translated the strings and code comments into English.

# Usage

```bash
# Remove the original hexo-offline-popup first.
cd /path/to/your/hexo
npm uninstall hexo-offline-popup
rm -rf node_modules/hexo-offline-popup

# Package the translated version
git clone https://github.com/hiedanoajuu/hexo-offline-popup-en.git
cd hexo-offline-popup-en
npm install
npm pack

// Install the packaged plugin
cd /path/to/your/hexo
npm install /path/to/hexo-offline-popup-en/hexo-offline-popup-1.0.3.tgz

// Rebuild your site
hexo cl && hexo g
```

# Author
Original Author: Colsrch ([@Colsrch](https://github.com/Colsrch))
Translation: Ajuu Hieda ([@hiedanoajuu](https://github.com/hiedanoajuu))

# License
Licensed under the [ISC License](https://www.isc.org/licenses/).
