var web3 = new Web3(Web3.givenProvider);

var instance;
var user;
var contractAddress = "0x4ba5f9da260404e4957Bfb4d7b386a8ED3645dE7";

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

async function getKitties(){  

    var arrayId;
    var kitty;
    try{    
      arrayId = await instance.methods.getKittyByOwner(user).call();
    } catch(err){
      console.log(err);
    }
    for (i = 0; i < arrayId.length; i++){
      kitty = await instance.methods.getKitty(arrayId[i]).call();
      appendCat(kitty[0],i, kitty.generation)
    }
    console.log(kitty);
    
}


//Get kittues for breeding that are not selected
async function breedKitties(gender) {
    var arrayId = await instance.methods.getKittyByOwner(user).call();
    for (i = 0; i < arrayId.length; i++) {
      appendBreed(arrayId[i],gender)
    }
}
  
//Appending cats to breed selection
async function appendBreed(id,gender) {
    var kitty = await instance.methods.getKitty(id).call()  
    breedAppend(kitty[0], id, kitty.generation,gender)
}
  
//Appending cats to breed selection
async function breed(dadId,mumId) {
    try {
        var newKitty = await instance.methods.breed(dadId,mumId).send()  
        console.log(newKitty)
        setTimeout(()=>{
            go_to('catalogue.html')
        },2000)
    } catch (err){
        console.log(err)
    }  
}

function go_to(url) {
    window.location.href = url;
}
function empty(str) {
    return (!str || 0 === str.length);
}