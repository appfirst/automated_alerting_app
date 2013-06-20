// For testing purposes, the function will return an 
// anomal on false.
function const_req(){
	var req = $.ajax({
		url: '/init',
		type: 'GET',
		data: 'id=245378',
		success: function(data){
			if(data==true)
				console.log("HOLY ANOMALY");
			else if(data==false){
				place_name(null, '245378');
			}
		}
	})
}
