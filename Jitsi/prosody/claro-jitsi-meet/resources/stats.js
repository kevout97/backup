const fs = require('fs');
const util = require('util');
const log_date = (new Date()).getTime();
const log_file = fs.createWriteStream(`${__dirname}/bitrate-${log_date}.log`, { flags: 'w' });
const log_stdout = process.stdout;
const args = process.argv.slice(2);
console.log('[AMX DEBUG] Args: ', args);

/*
   El índice se obtiene a partir de la interfaz que se usa para la red su servidor
   Esto se puede consultar haciendo  'sudo nano /proc/net/dev'  en tu servidor.
   en mi caso, la interfaz por defecto es 'enp0s3' la última línea (de 4 líneas del archivo),
   por tanto selecciono el 3.
   ***lo: se refiere al localhost
*/
const INTERFACE_INDEX = args[0]; // Se corresponde a mi interfaz válida
const INTERVAL = args[1] * 1000;

function getArrayWithoutSpaces(line) {
    const _array = line.split(' ');
    cleanArray = _array.filter(item => item !== '');
    return cleanArray;
}

function fileLog(d) {
    console.log(`[AMX DEBUG] Writting to log: ${d}`);
    log_file.write(`${util.format(d)}\n`);
    log_stdout.write(`${util.format(d)}\n`);
}


var data = '';
var oldReceived = 0;
var oldTransmited = 0;

function readNetworkFileData() {

    const dateNow = (new Date()).toISOString();

    console.log('[AMX DEBUG] Retrieving data: ', dateNow);
    const readStream = fs.createReadStream('/proc/net/dev', 'utf8');
    readStream.on('data', chunk => {
        data += chunk;
    }).on('end', () => {

        if (data !== undefined && data.length > 0 && data !== '') {
            const _lines = data.split('\n');
            const lines = _lines.filter(line => line !== '');

            if (lines.length > INTERFACE_INDEX) {

                const line = getArrayWithoutSpaces(lines[INTERFACE_INDEX]);

                console.log('[AMX DEBUG] Line: ', line[0]);

                const bytesReceived = parseInt(line[1]);
                const bytesTransmited = parseInt(line[9]);

                if (bytesReceived && bytesTransmited) {

                    var rateTransmited = bytesTransmited - oldTransmited;
                    if (rateTransmited < 0) {
                        rateTransmited = 0;
                    }
                    var rateReceived = bytesReceived - oldReceived;
                    if (rateReceived < 0) {
                        rateReceived = 0;
                    }

                    fileLog(`${dateNow},${rateReceived},${rateTransmited},${bytesReceived},${bytesTransmited}`);

                    oldTransmited = bytesTransmited;
                    oldReceived = bytesReceived;

                }

                data = '';

            }

        }

    });
}

if (INTERVAL > 0) {
    console.log(`[AMX DEBUG] Executing script at interface: ${INTERFACE_INDEX} | Timeout: ${INTERVAL}`);
    readNetworkFileData();
    setInterval(() => {
        readNetworkFileData();
    }, INTERVAL);
}