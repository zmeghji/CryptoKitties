var web3 = new Web3(Web3.givenProvider);

var instance;
var user;
var contractAddress = "0xf63A840c2D587797AFa967A5A583E904e17622a6";

$(document).ready(function(){
    window.ethereum.enable().then(function(accounts){
        instance = new web3.eth.Contract(abi, contractAddress, {from: accounts[0]})
        user = accounts[0];

        console.log(instance);

        instance.once('Birth', {}, function(error, event){

            console.log(event); 

            const kittenId = event.returnValues.kittenId; 
            const mumId = event.returnValues.mumId;
            const dadId = event.returnValues.dadId;
            const genes = event.returnValues.genes;
            const owner = event.returnValues.owner;

            $("#kittyCreation").css("display", "block");
            $("#kittyCreation").text("owner:" + owner
                                    +" kittyId:" + kittenId
                                    +" mumId:" + mumId
                                    +" dadId:" + dadId
                                    +" genes:" + genes)

        });

    })
})


function createKitty(){
    var dnaStr = getDna();
    instance.methods.createKittyGen0(dnaStr).send({}, function(error, txHash){
        if(error)
            console.log(err);
        else
            console.log(txHash);
    })
}