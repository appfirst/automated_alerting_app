// For testing purposes, the function will return an 
// anomaly on false.
function const_req(id){
	var req = $.ajax({
		url: '/init',
		type: 'GET',
		data: 'id=' + id,
		success: function(data){
			if(data==true){
				place_name(null, id);
				console.log("HOLY ANOMALY");

			}
			else if(data==false){
				console.log("all is good");
			}
		}
	})
}

function begin_analysis(id){
	console.log("porcupine")
	setInterval(const_req(id), 60000);
}
