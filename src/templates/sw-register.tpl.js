/**
 * @file offline-popup register template
 * @author colsrch(colsrch@foxmail.com)
 * @author hiedanoajuu(hieda@ajuu.org)
 */

/* global navigator, document */

// 注册的地址为 sw-precache-webpack-pulgin 生成的 service-worker.js 或者自己手动维护的 service worker 文件
if (navigator.serviceWorker) {
    navigator.serviceWorker.register('/__ServiceWorkerName__?v=__BuildVersion__').then(function () {
        navigator.serviceWorker.addEventListener('message', function (e) {

            // service-worker.js 如果更新成功会 postMessage 给页面，内容为 'sw.update'
            if (e.data === 'sw.update') {
                let themeColor = document.querySelector('meta[name=theme-color]');
                let dom = document.createElement('div');

                themeColor && (themeColor.content = '#000');

                /* eslint-disable max-len */
                dom.innerHTML = ''
                    + '<div>'
                        + '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/Colsrch/CDN/hexo-offline-popup.css">'
                        + '<div class="c-message animated animated-lento slideInRight">'
                            + '<i class=" c-message--icon c-message--success"></i>'
                            + '<div class="el-notification__group">'
                                + '<h2 class="c-message__title">System Updated</h2>'
                                + '<div class="el-notification__content">Refreshing...</div>'
                                + '<div class="c-message--close" onclick="location.reload()">×</div>'
                            + '</div>'
                        + '</div>'
                    + '</div>'
                ;
                /* eslint-enable max-len */

                document.body.appendChild(dom);
                setTimeout(function () {
                    document.getElementById('app-refresh').className += ' app-refresh-show';
                }, 16);
            }
        });
    });
}
