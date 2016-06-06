var holder = angular.module('holder', ['ngResource']);

holder.controller('ScreenCtrl', function($scope, $resource) {

	var default_holder = 'http://cookies-holder.herokuapp.com'

	$scope.config = false;

	$scope.data = {
		holder_server: localStorage["holder_server"] ? JSON.parse(localStorage["holder_server"]) : default_holder,
		keys: localStorage["keys"] ? JSON.parse(localStorage["keys"]) : []
	};

	$scope.get_session_url = function(account) {
		return $scope.data.holder_server + '/account/' + account._id.$oid + "/session.json"
	};

	$scope.automatic_login = function(account){
		account.session_url = $scope.get_session_url(account);
		extension.send_message("set_localstorage", {
			key : account.login_page + '_auto_login',
			value : account
		})
	};

	$scope.select_server = function(account) {
		var resource = $scope.get_session_url(account);
		$resource(resource).get(function(session){
			extension.redirect_to_session(session, function(){
				window.location.href = session.redirected_page
			})
		});
	};

	$scope.$watch('data', function() {
		localStorage["holder_server"] = JSON.stringify($scope.data.holder_server);
		localStorage["keys"] = JSON.stringify($scope.data.keys);

		$scope.servers = [];
		for (var i in $scope.data.keys) {
			var item = $scope.data.holder_server + '/account/' + $scope.data.keys[i] + '.json';
			$scope.servers.push($resource(item).get());
		}

	}, true);


	$scope.add = function() {
		$scope.data.keys.push('');
	};

	$scope.remove = function(key) {
		$scope.data.keys.splice($scope.data.keys.indexOf(key), 1);
	};


});