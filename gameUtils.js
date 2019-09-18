require('dotenv').config();
const Web3 = require('web3');
var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = process.env.DEVELOPMENT_MNEMONIC;
var fs = require('fs');
var gameJSON = JSON.parse(fs.readFileSync('./build/contracts/Game.json', 'utf8'));
const GAS = 999999;


var hdprovider = new HDWalletProvider(mnemonic, process.env.DEVELOPMENT_URL);

const transactionObject = {
    from: hdprovider.getAddress(0),
    gas: GAS,
    gasPrice: 0
};



const web3 = new Web3(hdprovider);

const contract = web3.eth.contract(gameJSON.abi);
const contractInstance = contract.at(gameJSON.networks[process.env.ALASTRIA_NETWORKID].address);

//web3.personal.unlockAccount(process.env.ALASTRIA_ACCOUNT,process.env.ALASTRIA_ACCOUNT_PASSWORD, 1000, doStuff);

function doStuff() {
    console.log('Account unlocked!');
   switch(process.argv[2]){
    case 'pause':
        pause();
        break;
    case 'resume':
        resume();
        break;
    case 'code':
        addCode(process.argv[3],parseInt(process.argv[4]));
        break;
    case 'codes':
        getCodes();
        break;
    case 'players':
        getPlayers();
        break;
    case 'clear':
        clear();
        break;
    case 'pointBank':
        pointBank();
        break;
    case 'auction':
        auction();
        break        
    default:
        console.log('no command... pause|resume|clear|codes|players|pointBank|auction|code name value')
   }
}

function pointBank(){
    contractInstance.pointBank.call( transactionObject, (err,result) => { console.log('POINTBANK:',result.toString()); process.exit(0); });
}

function auction(){
    contractInstance.auction.call( transactionObject, (err,result) => { console.log('AUCTION:',result.toString());  process.exit(0); } );
}


function pause(){
    contractInstance.pauseGame.sendTransaction( transactionObject, checkTransaction);
}

function resume(){
    contractInstance.resumeGame.sendTransaction( transactionObject, checkTransaction);
}

function addCode(codeName,codeValue){
    contractInstance.addCode.sendTransaction(codeName,codeValue,transactionObject, checkTransaction);
}

function getCodes(){
    contractInstance.getCodes.call(transactionObject, (err,result) => {console.log(result.toString()); process.exit(0);});
}

function getPlayers(){
    contractInstance.getPlayers.call(transactionObject, (err,result) =>{ console.log(result.toString()); process.exit(0); });
}


function clear(){
    contractInstance.clear.sendTransaction( transactionObject, checkTransaction);
}

function checkTransaction(error, result) {
   if (!error){
    setTimeout( function (){
        web3.eth.getTransactionReceipt(result,
            function(err,status){
                if( GAS== status.gasUsed){
                    //transaction error
                    console.log('KO');
                    process.exit(0);
                } else {
                    console.log('OK');
                    process.exit(0);
                }
            }
        );
    },10000);
   } else {
    console.log(error);
    process.exit(0);
   }
}

doStuff();