/**
 * @file run sw-precache
 * @author mj(zoumiaojiang@gmail.com)
 * @author Ajuu Hieda(hieda@ajuu.org)
 */

/* global public_dir */
/* eslint-disable fecs-camelcase */
import fs from 'fs';
import path from 'path';
import {
    SW_FILE_NAME
} from './config';


/**
 * For a number less than 10, pad left with zeros.
 *
 * @param  {number} value A number
 * @return {string}       Padded string
 */
function padding(value) {
    return value < 10 ? `0${value}` : value;
}

/**
 * Get timestamp version
 *
 * @return {string} The version
 */
function versionGenerator() {
    let d = new Date();

    return ''
        + d.getFullYear()
        + padding(d.getMonth() + 1)
        + padding(d.getDate())
        + padding(d.getHours())
        + padding(d.getMinutes())
        + padding(d.getSeconds());
}

export default function () {
    let swRegisterTemplatePath = path.resolve(__dirname, 'templates', 'sw-register.tpl.js');
    let swRegisterTempleteCon = fs.readFileSync(swRegisterTemplatePath, 'utf-8');
    let swRegisterCon = swRegisterTempleteCon
        .replace('__ServiceWorkerName__', SW_FILE_NAME)
        .replace('__BuildVersion__', versionGenerator())
        ;

    let swRegisterDistPath = path.resolve(this.public_dir, 'sw-register.js');

    fs.writeFileSync(swRegisterDistPath, swRegisterCon);

    return Promise.resolve();
}
