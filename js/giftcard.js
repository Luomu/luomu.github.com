$(document).ready(function(){
    $("#giftcard-form").submit(function (event) {
        event.preventDefault();
        code = $("#codeInput").val()
        code = code.trim().toUpperCase().substring(0,3)
        code = btoa(code);
        if (code == "WFlQ" || code == "UkFQ") {
            window.location.href = "kmt_card.html?code=" + code
        }
        else {
            $( "span" ).text( "Tuntematon koodi." ).show().fadeOut( 1000 );
        }
    })
});
