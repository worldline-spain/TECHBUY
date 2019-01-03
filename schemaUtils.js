require('dotenv').config();

var HDWalletProvider = require("truffle-hdwallet-provider");
const RLP = require('rlp');

var mnemonic =process.env.ALASTRIA_MNEMONIC;

var fs = require('fs');
var contractJSON = JSON.parse(fs.readFileSync('./build/contracts/Devices.json', 'utf8'));
const GAS = 999999999999999;

const Web3 = require('web3');

Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send;
const _user = process.env.ALASTRIA_USER;
const _password = process.env.ALASTRIA_PASSWORD;
const _auth = 'Basic ' + Buffer.from(_user + ':' + _password).toString('base64');
const _headers = [{name: 'Authorization', value: _auth}];
const _provider = new Web3.providers.HttpProvider(process.env.ALASTRIA_URL, {timeout: 0, headers: _headers });


var hdprovider =new HDWalletProvider(mnemonic, process.env.ALASTRIA_URL); 
hdprovider.engine.stop();
hdprovider.engine._providers[2].provider=_provider
hdprovider.engine.start();

const web3 = new Web3(hdprovider);

const transactionObject = {
    from: hdprovider.getAddress(0),
    gas: GAS,
    gasPrice: 0
  };

  const contractInstance = new web3.eth.Contract(contractJSON.abi, contractJSON.networks[process.env.ALASTRIA_NETWORKID].address);

function doStuff() {
    switch(process.argv[2]){
        case 'get':
            get();
            break;
        case 'add':
            add();
            break;
        default:
            console.log('no command... get|add')
   }
   
   hdprovider.engine.stop();
}

function get(){
    
    contractInstance.methods.getSchema(1).call(transactionObject).then(
        (result) => {
            console.log('GET:',result)
        });
}

function add(){
    // [<expirationDate>,<schemaId>,<amount>,<assetLifeTime>,[ [<percent>,<address>,<description>],[<percent>,<address>,<description>]]]
    const pathValues = [];
    const d = new Date();
    let n = d.getMilliseconds();
    n %= 1000;
    n += 6000;
    pathValues.push(n);
    pathValues.push(1);
    pathValues.push(100);
    pathValues.push(600);
    const clearArray = [];
    clearArray.push([30,'0x6bdb680c6bb2cb1ba8fa3489193ab56c1e999c27','test receptor#1']);
    clearArray.push([70,'0xed8946f8b6c399e10ca95b8deeba7fdd2c9e358d','test receptor#2']);
    pathValues.push(clearArray);
    const encodedData = RLP.encode(pathValues);
    contractInstance.methods.createSchema(1,encodedData).send(transactionObject)
    .then((tx) => {
        console.log('Transaction sent.',tx.transactionHash);
        return checkTransaction(tx.transactionHash);
    },(err)=> console.log(err));
}

function checkTransaction(tx) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            web3.eth.getTransactionReceipt(tx,
                function (err, status) {
                    if (err) {
                        console.log('KO');
                        reject(err);
                    } else if (!status) {
                        console.log('Checking transaction ...');
                        checkTransaction(tx);
                    }
                    else if (GAS == status.gasUsed) {
                        //transaction error
                        console.log('Error','Out of gas.');
                        resolve();
                    } else {
                        console.log('Transaction mined.');
                        resolve();
                    }
                }
            );
        }, 1000);
    });
}


doStuff();
