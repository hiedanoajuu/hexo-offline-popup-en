'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

exports.default = function () {
    var swRegisterTemplatePath = _path2.default.resolve(__dirname, 'templates', 'sw-register.tpl.js');
    var swRegisterTempleteCon = _fs2.default.readFileSync(swRegisterTemplatePath, 'utf-8');
    var swRegisterCon = swRegisterTempleteCon.replace('__ServiceWorkerName__', _config.SW_FILE_NAME).replace('__BuildVersion__', versionGenerator());

    var swRegisterDistPath = _path2.default.resolve(this.public_dir, 'sw-register.js');

    _fs2.default.writeFileSync(swRegisterDistPath, swRegisterCon);

    return Promise.resolve();
};

var _fs = require('fs');

var _fs2 = _interopRequireDefault(_fs);

var _path = require('path');

var _path2 = _interopRequireDefault(_path);

var _config = require('./config');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/**
 * For a number less than 10, pad left with zeros.
 *
 * @param  {number} value a Number
 * @return {string}       Padded string
 */
function padding(value) {
    return value < 10 ? `0${value}` : value;
}

/**
 * Get timestamp version
 *
 * @return {string} version
 */
/**
 * @file run sw-precache
 * @author mj(zoumiaojiang@gmail.com)
 * @authoe Ajuu Hieda(hieda@ajuu.org)
 */

/* global public_dir */
/* eslint-disable fecs-camelcase */
function versionGenerator() {
    var d = new Date();

    return '' + d.getFullYear() + padding(d.getMonth() + 1) + padding(d.getDate()) + padding(d.getHours()) + padding(d.getMinutes()) + padding(d.getSeconds());
}
