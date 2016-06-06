// extension.register_message_listener("get_localstorage",function(){
// 	var raw_json = localStorage["ruby_info"];
// 	return raw_json ? JSON.parse(raw_json) : undefined;
// });

extension.register_message_listener("get_localstorage",function(key){
	return localStorage[key] ? JSON.parse(localStorage[key]) : null;
});


extension.register_message_listener("set_localstorage",function(msg){
	localStorage[msg.key] = JSON.stringify(msg.value);
});

extension.register_message_listener("register_cookies",function(ruby_info){
	for (var i in ruby_info.cookies){
		var cookie = ruby_info.cookies[i];
		chrome.cookies.remove({
			url : cookie.url,
			name : cookie.name
		});
		chrome.cookies.set(cookie)
	}
});