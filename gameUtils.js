require('dotenv').config();

var fs = require('fs');
var gameJSON = JSON.parse(fs.readFileSync('./build/contracts/Game.json', 'utf8'));
const GAS = 999999999999999;

const transactionObject = {
    from: process.env.ALASTRIA_ACCOUNT,
    gas: GAS,
    gasPrice: 0
  };

const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider(process.env.ALASTRIA_URL, 0, process.env.ALASTRIA_USER, process.env.ALASTRIA_PASSWORD));

const contract = web3.eth.contract(gameJSON.abi);
const contractInstance = contract.at(gameJSON.networks[process.env.ALASTRIA_NETWORKID].address);

web3.personal.unlockAccount(process.env.ALASTRIA_ACCOUNT,process.env.ALASTRIA_ACCOUNT_PASSWORD, 1000, doStuff);

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
    default:
        console.log('no command... pause|resume|clear|code name value')
   }

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
    contractInstance.getCodes.call(transactionObject, (err,result) => console.log(result.toString()));
}

function getPlayers(){
    contractInstance.getPlayers.call(transactionObject, (err,result) => console.log(result.toString()));
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
                } else {
                    console.log('OK');
                }
            }
        );
    },2000);
   } else {
    console.log(error);
   }
}
