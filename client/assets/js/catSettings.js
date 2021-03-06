
var colors = Object.values(allColors())

var defaultDNA = {
    "headcolor" : 10,
    "mouthColor" : 13,
    "eyesColor" : 76,
    "earsColor" : 98,
    //Cattributes
    "eyesShape" : 1,
    "decorationPattern" : 1,
    "decorationMidcolor" : 13,
    "decorationSidescolor" : 13,
    "animation" :  1,
    "lastNum" :  1
    }

// when page load
$( document ).ready(function() {
  $('#dnabody').html(defaultDNA.headColor);
  $('#dnamouth').html(defaultDNA.mouthColor);
  $('#dnaeyes').html(defaultDNA.eyesColor);
  $('#dnaears').html(defaultDNA.earsColor);
    
  $('#dnashape').html(defaultDNA.eyesShape)
  $('#dnadecoration').html(defaultDNA.decorationPattern)
  $('#dnadecorationMid').html(defaultDNA.decorationMidcolor)
  $('#dnadecorationSides').html(defaultDNA.decorationSidescolor)
  $('#dnaanimation').html(defaultDNA.animation)
  $('#dnaspecial').html(defaultDNA.lastNum)

  renderCat(defaultDNA)
});

function getDna(){
    var dna = ''
    dna += $('#dnabody').html()
    dna += $('#dnamouth').html()
    dna += $('#dnaeyes').html()
    dna += $('#dnaears').html()
    dna += $('#dnashape').html()
    dna += $('#dnadecoration').html()
    dna += $('#dnadecorationMid').html()
    dna += $('#dnadecorationSides').html()
    dna += $('#dnadanimation').html()
    dna += $('#dnaspecial').html()

    return parseInt(dna)
}

function defaultCat(){
  renderCat(defaultDNA)
}

function randomDNA(){
  var dnaStr = String(Math.floor(Math.random()*1E16))
  //Colors
  var dna = {
    "headcolor" : dnaStr.substring(0, 2),
    "mouthColor" : dnaStr.substring(2, 4),
    "eyesColor" : dnaStr.substring(4, 6),
    "earsColor" : dnaStr.substring(6, 8),
    //Cattributes
    "eyesShape" : dnaStr.substring(8,9) % 8 + 1    ,
    "decorationPattern" : dnaStr.substring(9, 10)  % 8 + 1,
    "decorationMidcolor" : dnaStr.substring(10, 12),
    "decorationSidescolor" : dnaStr.substring(12, 14),
    "animation" :  dnaStr.substring(14, 15) % 6 + 1,
    "lastNum" :  dnaStr.substring(15, 16)
  }
  return dna
}

//Random cat DNA
function randomCat(){
var dna = randomDNA()
  //Rendering Cat
 renderCat(dna)
}

function renderCat(dna){
    headColor(colors[dna.headcolor],dna.headcolor)
    mouthcolor(colors[dna.mouthColor],dna.mouthColor)
    eyescolor(colors[dna.eyesColor],dna.eyesColor)
    earscolor(colors[dna.earsColor],dna.earsColor)
    eyeVariation(dna.eyesShape);
    decorationVariation(dna.decorationPattern);
    midColor(colors[dna.decorationMidcolor],dna.decorationMidcolor)
    SidesColor(colors[dna.decorationSidescolor],dna.decorationSidescolor)
    animationVariation(dna.animation)

    $('#bodycolor').val(dna.headcolor)
    $('#mouthcolor').val(dna.mouthColor)
    $('#eyescolor').val(dna.eyesColor)
    $('#earscolor').val(dna.earsColor)
    $('#eyeshape').val(dna.eyesShape)
    $('#decoration').val(dna.eyesShape)
    $('#decorationmiddle').val(dna.eyesShape)
    $('#decorationsides').val(dna.eyesShape)
    $('#animation').val(dna.animation)
}

// Changing cat colors
$('#bodycolor').change(()=>{
    var colorVal = $('#bodycolor').val()
    headColor(colors[colorVal],colorVal)
})
$('#mouthcolor').change(()=>{
  var colorVal = $('#mouthcolor').val()
  mouthcolor(colors[colorVal],colorVal)
})

$('#eyescolor').change(()=>{
  var colorVal = $('#eyescolor').val()
  eyescolor(colors[colorVal],colorVal)
})

$('#earscolor').change(()=>{
  var colorVal = $('#earscolor').val()
  earscolor(colors[colorVal],colorVal)
})

$('#eyeshape').change(()=>{
  var shape = parseInt($('#eyeshape').val()) // between 1 and 7
  eyeVariation(shape)
})

$('#decoration').change(()=>{
  var decoration = parseInt( $('#decoration').val() )    
  decorationVariation(decoration)
})

$('#decorationmiddle').change(()=>{
  var colorVal = $('#decorationmiddle').val()
  midColor(colors[colorVal],colorVal)   
})

$('#decorationsides').change(()=>{
  var colorVal = $('#decorationsides').val()
  SidesColor(colors[colorVal],colorVal)
})

$('#animation').change(()=>{
  var animationVal = parseInt( $('#animation').val() )
  animationVariation(animationVal)
})

function showColors(){
  $('#catColors').removeClass('hidden')
  $('#cattributes').addClass('hidden')
}

function showCattributes(){
  $('#cattributes').removeClass('hidden')
  $('#catColors').addClass('hidden')
}