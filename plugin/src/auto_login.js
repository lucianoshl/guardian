document.write("getting remote session");
$.getJSON("https://guardianl.herokuapp.com/cookie/latest", function(session){
	extension.redirect_to_session(session, function(){
		window.location.href = session.redirected_page
	});
});