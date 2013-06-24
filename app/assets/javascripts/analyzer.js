// For testing purposes, the function will return an 
// anomaly on false.
function const_req(id){
	$.ajax({
		url: '/init',
		type: 'GET',
		data: 'id=' + id,
		success: function(data){
			console.log(data);
			if(data==true){
				place_name(null, id);
				console.log("HOLY ANOMALY")
			}
			else if(data==false){
				place_name(null, id); //Again, will remove once testing is completed
				console.log("all is good");
			}
		}
	})
}

function begin_analysis(id){
	setInterval(function(){const_req(id)}, 60000);
}
