$(document).ready(function(){
  player_hits();
  player_stays();
  dealer_hit();
  toggle_bet();
});

function player_hits() {
  $(document).on('click','#hit input', function(){  
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });
}
  
function player_stays() {
  $(document).on('click','#stay input', function(){  
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });
}
  
function dealer_hit() {
  $(document).on('click','#dealer_btn input', function(){  
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg){
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function toggle_bet() {
  $('#place_bet').click(function(){
    $('#bet').toggleClass('hidden');
    $(this).hide();
    $('#no_bet').hide();
  });
}
